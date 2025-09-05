import { Response, NextFunction } from 'express';
import path from 'path';
import { prisma } from '../utils/database';
import { AuthenticatedRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { LogFoodData, FoodDetectionResult, ApiResponse } from '../types';
import { getFileUrl, deleteFile } from '../middleware/upload';

export class FoodController {
  // Mock food detection service (replace with actual AI service)
  private static async detectFoodInImage(imagePath: string): Promise<FoodDetectionResult[]> {
    // Mock detection results - in production, this would call Google Vision API or custom ML model
    const mockResults: FoodDetectionResult[] = [
      {
        name: 'Grilled Chicken Breast',
        confidence: 0.92,
        estimatedProtein: 31.0, // protein per 100g
        category: 'protein',
        boundingBox: { x: 10, y: 20, width: 200, height: 150 }
      },
      {
        name: 'Broccoli',
        confidence: 0.88,
        estimatedProtein: 2.8,
        category: 'vegetable',
        boundingBox: { x: 220, y: 50, width: 100, height: 120 }
      }
    ];

    // Simulate processing delay
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return mockResults;
  }

  // Detect food in uploaded image
  static async detectFood(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      
      if (!req.file) {
        throw new AppError('No image file provided', 400);
      }

      const imagePath = req.file.path;
      const imageUrl = getFileUrl(req.file.filename);

      // Perform food detection
      const detectionResults = await FoodController.detectFoodInImage(imagePath);

      // Save detection results to database
      const detectedFood = await prisma.detectedFood.create({
        data: {
          userId,
          imagePath: imageUrl,
          detectionResults: detectionResults as any,
          processingStatus: 'completed',
          processingTime: 1000, // Mock processing time
        },
      });

      const response: ApiResponse = {
        success: true,
        data: {
          id: detectedFood.id,
          imagePath: imageUrl,
          detectedFoods: detectionResults,
        },
        message: 'Food detection completed successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      // Clean up uploaded file on error
      if (req.file) {
        try {
          await deleteFile(req.file.path);
        } catch (deleteError) {
          console.error('Error deleting file:', deleteError);
        }
      }
      next(error);
    }
  }

  // Log food item
  static async logFood(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const logData: LogFoodData = req.body;

      // Get or create food entry
      let foodId = null;
      if (logData.foodName && !logData.isQuickAdd) {
        // Try to find existing food in database
        let food = await prisma.food.findFirst({
          where: {
            name: {
              contains: logData.foodName,
              mode: 'insensitive',
            },
          },
        });

        // Create new food entry if not found
        if (!food) {
          const proteinPer100g = (logData.proteinContent / logData.portionSize) * 100;
          const caloriesPer100g = logData.calories ? (logData.calories / logData.portionSize) * 100 : null;
          
          food = await prisma.food.create({
            data: {
              name: logData.foodName,
              proteinPer100g,
              caloriesPer100g,
              category: 'OTHER', // Default category
              source: 'user',
            },
          });
        }
        
        foodId = food.id;
      }

      // Create food item entry
      const foodItem = await prisma.foodItem.create({
        data: {
          userId,
          foodId,
          customName: logData.customName || logData.foodName,
          portionSize: logData.portionSize,
          proteinContent: logData.proteinContent,
          calories: logData.calories,
          mealType: logData.mealType.toUpperCase() as 'BREAKFAST' | 'LUNCH' | 'DINNER' | 'SNACK',
          imagePath: logData.imagePath,
          isQuickAdd: logData.isQuickAdd || false,
          proteinPer100g: (logData.proteinContent / logData.portionSize) * 100,
        },
        include: {
          food: true,
        },
      });

      // Update daily progress
      await this.updateDailyProgress(userId, logData.mealType, logData.proteinContent);

      const response: ApiResponse = {
        success: true,
        data: {
          foodItem: {
            id: foodItem.id,
            name: foodItem.customName || foodItem.food?.name,
            portionSize: foodItem.portionSize,
            proteinContent: foodItem.proteinContent,
            calories: foodItem.calories,
            mealType: foodItem.mealType.toLowerCase(),
            imagePath: foodItem.imagePath,
            dateLogged: foodItem.dateLogged,
          },
        },
        message: 'Food logged successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Get recent food items
  static async getRecentFoodItems(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const limit = parseInt(req.query.limit as string) || 20;
      const offset = parseInt(req.query.offset as string) || 0;

      const foodItems = await prisma.foodItem.findMany({
        where: { userId },
        include: {
          food: true,
        },
        orderBy: { dateLogged: 'desc' },
        take: limit,
        skip: offset,
      });

      const formattedItems = foodItems.map(item => ({
        id: item.id,
        name: item.customName || item.food?.name || 'Custom Food',
        portionSize: item.portionSize,
        proteinContent: item.proteinContent,
        calories: item.calories,
        mealType: item.mealType.toLowerCase(),
        imagePath: item.imagePath,
        dateLogged: item.dateLogged,
        isQuickAdd: item.isQuickAdd,
        category: item.food?.category?.toLowerCase() || 'other',
      }));

      const response: ApiResponse = {
        success: true,
        data: {
          foodItems: formattedItems,
          pagination: {
            limit,
            offset,
            total: await prisma.foodItem.count({ where: { userId } }),
          },
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Update food item
  static async updateFoodItem(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const itemId = req.params.id;
      const updateData = req.body;

      // Check if food item belongs to user
      const existingItem = await prisma.foodItem.findFirst({
        where: {
          id: itemId,
          userId,
        },
      });

      if (!existingItem) {
        throw new AppError('Food item not found', 404);
      }

      const updatedItem = await prisma.foodItem.update({
        where: { id: itemId },
        data: {
          ...updateData,
          mealType: updateData.mealType?.toUpperCase(),
          proteinPer100g: updateData.proteinContent && updateData.portionSize 
            ? (updateData.proteinContent / updateData.portionSize) * 100 
            : undefined,
        },
        include: {
          food: true,
        },
      });

      // Update daily progress if protein content changed
      if (updateData.proteinContent !== undefined) {
        const proteinDiff = updateData.proteinContent - existingItem.proteinContent;
        await this.updateDailyProgress(userId, updateData.mealType || existingItem.mealType, proteinDiff);
      }

      const response: ApiResponse = {
        success: true,
        data: {
          foodItem: {
            id: updatedItem.id,
            name: updatedItem.customName || updatedItem.food?.name,
            portionSize: updatedItem.portionSize,
            proteinContent: updatedItem.proteinContent,
            calories: updatedItem.calories,
            mealType: updatedItem.mealType.toLowerCase(),
            imagePath: updatedItem.imagePath,
            dateLogged: updatedItem.dateLogged,
          },
        },
        message: 'Food item updated successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Delete food item
  static async deleteFoodItem(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const itemId = req.params.id;

      // Check if food item belongs to user
      const existingItem = await prisma.foodItem.findFirst({
        where: {
          id: itemId,
          userId,
        },
      });

      if (!existingItem) {
        throw new AppError('Food item not found', 404);
      }

      // Delete the food item
      await prisma.foodItem.delete({
        where: { id: itemId },
      });

      // Update daily progress by subtracting the protein
      await this.updateDailyProgress(userId, existingItem.mealType, -existingItem.proteinContent);

      // Clean up image file if exists
      if (existingItem.imagePath) {
        try {
          const filename = path.basename(existingItem.imagePath);
          const filepath = path.join(process.env.UPLOAD_DIR || './uploads', 'food-images', filename);
          await deleteFile(filepath);
        } catch (deleteError) {
          console.error('Error deleting image file:', deleteError);
        }
      }

      const response: ApiResponse = {
        success: true,
        message: 'Food item deleted successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Search food database
  static async searchFoods(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const query = req.query.q as string;
      const limit = parseInt(req.query.limit as string) || 10;

      if (!query || query.length < 2) {
        throw new AppError('Search query must be at least 2 characters long', 400);
      }

      const foods = await prisma.food.findMany({
        where: {
          name: {
            contains: query,
            mode: 'insensitive',
          },
        },
        take: limit,
        orderBy: [
          { isVerified: 'desc' }, // Verified foods first
          { name: 'asc' },
        ],
      });

      const response: ApiResponse = {
        success: true,
        data: {
          foods: foods.map(food => ({
            id: food.id,
            name: food.name,
            category: food.category.toLowerCase(),
            proteinPer100g: food.proteinPer100g,
            caloriesPer100g: food.caloriesPer100g,
            isVerified: food.isVerified,
          })),
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Helper method to update daily progress
  private static async updateDailyProgress(userId: string, mealType: string, proteinAmount: number): Promise<void> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Get user's daily protein target
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { dailyProteinTarget: true },
    });

    const dailyTarget = user?.dailyProteinTarget || 126;

    // Update or create daily progress
    const existingProgress = await prisma.dailyProgress.findUnique({
      where: {
        userId_date: {
          userId,
          date: today,
        },
      },
    });

    if (existingProgress) {
      const newTotalProtein = existingProgress.totalProtein + proteinAmount;
      const goalMet = newTotalProtein >= dailyTarget;

      await prisma.dailyProgress.update({
        where: { id: existingProgress.id },
        data: {
          totalProtein: newTotalProtein,
          goalMet,
          achievementPercentage: (newTotalProtein / dailyTarget) * 100,
        },
      });
    } else {
      const goalMet = proteinAmount >= dailyTarget;
      
      await prisma.dailyProgress.create({
        data: {
          userId,
          date: today,
          totalProtein: proteinAmount,
          dailyTarget,
          goalMet,
          achievementPercentage: (proteinAmount / dailyTarget) * 100,
          streakCount: 1, // This would need more complex logic for actual streaks
        },
      });
    }

    // Update meal progress
    const mealTypeEnum = mealType.toUpperCase() as 'BREAKFAST' | 'LUNCH' | 'DINNER' | 'SNACK';
    const mealTarget = dailyTarget / 4; // Simple equal distribution

    const existingMealProgress = await prisma.mealProgress.findUnique({
      where: {
        userId_date_mealType: {
          userId,
          date: today,
          mealType: mealTypeEnum,
        },
      },
    });

    if (existingMealProgress) {
      await prisma.mealProgress.update({
        where: { id: existingMealProgress.id },
        data: {
          actualProtein: existingMealProgress.actualProtein + proteinAmount,
          itemsCount: existingMealProgress.itemsCount + (proteinAmount > 0 ? 1 : -1),
        },
      });
    } else if (proteinAmount > 0) {
      await prisma.mealProgress.create({
        data: {
          userId,
          date: today,
          mealType: mealTypeEnum,
          targetProtein: mealTarget,
          actualProtein: proteinAmount,
          itemsCount: 1,
          dailyProgressId: existingProgress?.id || (await prisma.dailyProgress.findUnique({
            where: { userId_date: { userId, date: today } }
          }))?.id || '',
        },
      });
    }
  }
}