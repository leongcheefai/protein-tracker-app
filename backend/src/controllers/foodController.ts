import { Response, NextFunction } from 'express';
import path from 'path';
import { DatabaseService, supabase } from '../utils/database';
import { AuthenticatedRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { LogFoodData, FoodDetectionResult, ApiResponse } from '../types';
import { getFileUrl, deleteFile } from '../middleware/upload';
import { InsertFoodDetection, InsertMeal, InsertMealFood, NutritionData } from '../types/supabase';

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
      const detectionData: InsertFoodDetection = {
        user_id: userId,
        image_url: imageUrl,
        detected_foods: detectionResults as any,
        confidence_scores: detectionResults.map(r => ({ name: r.name, confidence: r.confidence })) as any,
        status: 'completed'
      };

      const detectedFood = await DatabaseService.createFoodDetection(detectionData);

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

  // Log food item (simplified for new schema)
  static async logFood(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const logData: LogFoodData = req.body;

      // Get or create food entry
      let food = null;
      if (logData.foodName && !logData.isQuickAdd) {
        // Search for existing food
        const searchResults = await DatabaseService.searchFoods(logData.foodName, 1);
        
        if (searchResults && searchResults.length > 0) {
          food = searchResults[0];
        } else {
          // Create new food entry
          const nutritionData: NutritionData = {
            calories: logData.calories || 0,
            protein: (logData.proteinContent / logData.portionSize) * 100,
            carbs: 0,
            fat: 0
          };

          food = await DatabaseService.createFood({
            name: logData.foodName,
            category: 'other',
            nutrition_per_100g: nutritionData as any,
            verified: false,
            user_id: userId
          });
        }
      }

      // Create meal entry
      const mealData: InsertMeal = {
        user_id: userId,
        meal_type: logData.mealType.toLowerCase(),
        timestamp: new Date().toISOString(),
        photo_url: logData.imagePath
      };

      const meal = await DatabaseService.createMeal(mealData);

      // Create meal food entry if we have a food
      let mealFood = null;
      if (food) {
        const mealFoodData: InsertMealFood = {
          meal_id: meal.id,
          food_id: food.id,
          quantity: logData.portionSize,
          unit: 'grams',
          nutrition_data: {
            calories: logData.calories || 0,
            protein: logData.proteinContent,
            carbs: 0,
            fat: 0
          } as any
        };

        mealFood = await DatabaseService.createMealFood(mealFoodData);
      }

      // Update daily progress
      await this.updateDailyProgress(userId, logData.mealType, logData.proteinContent);

      const response: ApiResponse = {
        success: true,
        data: {
          meal: {
            id: meal.id,
            name: logData.customName || logData.foodName,
            portionSize: logData.portionSize,
            proteinContent: logData.proteinContent,
            calories: logData.calories,
            mealType: logData.mealType.toLowerCase(),
            imagePath: logData.imagePath,
            timestamp: meal.timestamp,
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

  // Get recent food items (now returns recent meals)
  static async getRecentFoodItems(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const limit = parseInt(req.query.limit as string) || 20;
      
      // Get recent meals with their foods
      const meals = await DatabaseService.getUserMeals(userId);
      const recentMeals = meals.slice(0, limit);

      const formattedItems = recentMeals.map(meal => ({
        id: meal.id,
        name: `${meal.meal_type} meal`,
        mealType: meal.meal_type,
        imagePath: meal.photo_url,
        timestamp: meal.timestamp,
        notes: meal.notes,
        totalNutrition: meal.total_nutrition,
        foods: meal.meal_foods || []
      }));

      const response: ApiResponse = {
        success: true,
        data: {
          meals: formattedItems,
          pagination: {
            limit,
            total: meals.length,
          },
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Update food item (simplified - updates meal)
  static async updateFoodItem(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const mealId = req.params.id;
      const updateData = req.body;

      // Check if meal belongs to user and update it
      const { data: existingMeal, error: fetchError } = await supabase
        .from('meals')
        .select('*')
        .eq('id', mealId)
        .eq('user_id', userId)
        .single();

      if (fetchError || !existingMeal) {
        throw new AppError('Meal not found', 404);
      }

      const { data: updatedMeal, error: updateError } = await supabase
        .from('meals')
        .update({
          meal_type: updateData.mealType?.toLowerCase(),
          notes: updateData.notes,
          photo_url: updateData.imagePath,
          updated_at: new Date().toISOString()
        })
        .eq('id', mealId)
        .select()
        .single();

      if (updateError) throw updateError;

      const response: ApiResponse = {
        success: true,
        data: {
          meal: {
            id: updatedMeal.id,
            mealType: updatedMeal.meal_type,
            notes: updatedMeal.notes,
            imagePath: updatedMeal.photo_url,
            timestamp: updatedMeal.timestamp,
          },
        },
        message: 'Meal updated successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Delete food item (deletes meal)
  static async deleteFoodItem(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const mealId = req.params.id;

      // Check if meal belongs to user
      const { data: existingMeal, error: fetchError } = await supabase
        .from('meals')
        .select('*')
        .eq('id', mealId)
        .eq('user_id', userId)
        .single();

      if (fetchError || !existingMeal) {
        throw new AppError('Meal not found', 404);
      }

      // Delete the meal (meal_foods will be cascade deleted)
      const { error: deleteError } = await supabase
        .from('meals')
        .delete()
        .eq('id', mealId);

      if (deleteError) throw deleteError;

      // Clean up image file if exists
      if (existingMeal.photo_url) {
        try {
          const filename = path.basename(existingMeal.photo_url);
          const filepath = path.join(process.env.UPLOAD_DIR || './uploads', 'food-images', filename);
          await deleteFile(filepath);
        } catch (deleteError) {
          console.error('Error deleting image file:', deleteError);
        }
      }

      const response: ApiResponse = {
        success: true,
        message: 'Meal deleted successfully',
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

      const foods = await DatabaseService.searchFoods(query, limit);

      const response: ApiResponse = {
        success: true,
        data: {
          foods: foods.map(food => ({
            id: food.id,
            name: food.name,
            category: food.category,
            nutritionPer100g: food.nutrition_per_100g,
            isVerified: food.verified,
          })),
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Helper method to update daily progress (TODO: implement with analytics schema)
  private static async updateDailyProgress(userId: string, mealType: string, proteinAmount: number): Promise<void> {
    // TODO: Implement daily progress tracking with Supabase
    // This would require additional tables for daily_progress and meal_progress
    console.log(`Daily progress update for user ${userId}: ${proteinAmount}g protein from ${mealType}`);
  }
}