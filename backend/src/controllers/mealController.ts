import { Response, NextFunction } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { DatabaseService } from '../utils/database';
import { ApiResponse, NutritionData } from '../types';
import { InsertMeal, InsertMealFood, Meal, MealFood } from '../types/supabase';

export class MealController {
  /**
   * Get user's meals with optional filtering
   */
  static async getUserMeals(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { startDate, endDate, mealType } = req.query;

      let meals = await DatabaseService.getUserMeals(
        userId,
        startDate as string,
        endDate as string
      );

      // Filter by meal type if provided
      if (mealType) {
        meals = meals.filter(meal => meal.meal_type === mealType);
      }

      // Calculate nutrition totals for each meal
      const mealsWithNutrition = await Promise.all(
        meals.map(async (meal) => {
          const mealFoods = await DatabaseService.getMealFoods(meal.id);
          const nutritionTotal = MealController.calculateMealNutrition(mealFoods);
          
          return {
            ...meal,
            foods: mealFoods,
            nutrition: nutritionTotal
          };
        })
      );

      const response: ApiResponse<any> = {
        success: true,
        data: mealsWithNutrition,
        message: 'Meals retrieved successfully'
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get a specific meal by ID
   */
  static async getMealById(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { id } = req.params;

      const meals = await DatabaseService.getUserMeals(userId);
      const meal = meals.find(m => m.id === id);

      if (!meal) {
        const response: ApiResponse<null> = {
          success: false,
          data: null,
          message: 'Meal not found or you do not have access to this meal'
        };
        res.status(404).json(response);
        return;
      }

      // Get meal foods and calculate nutrition
      const mealFoods = await DatabaseService.getMealFoods(meal.id);
      const nutritionTotal = MealController.calculateMealNutrition(mealFoods);

      const response: ApiResponse<any> = {
        success: true,
        data: {
          ...meal,
          foods: mealFoods,
          nutrition: nutritionTotal
        },
        message: 'Meal retrieved successfully'
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Create a new meal
   */
  static async createMeal(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { meal_type, timestamp, photo_url, notes, foods } = req.body;

      // Create the meal
      const mealData: InsertMeal = {
        user_id: userId,
        meal_type,
        timestamp: timestamp || new Date().toISOString(),
        photo_url,
        notes
      };

      const meal = await DatabaseService.createMeal(mealData);

      // Add foods to the meal if provided
      let mealFoods: MealFood[] = [];
      if (foods && Array.isArray(foods)) {
        mealFoods = await Promise.all(
          foods.map(async (food: any) => {
            const mealFoodData: InsertMealFood = {
              meal_id: meal.id,
              food_id: food.food_id,
              quantity: food.quantity,
              unit: food.unit,
              nutrition_data: food.nutrition_data
            };
            return await DatabaseService.createMealFood(mealFoodData);
          })
        );
      }

      // Calculate total nutrition and update meal
      const nutritionTotal = MealController.calculateMealNutrition(mealFoods);

      const response: ApiResponse<any> = {
        success: true,
        data: {
          ...meal,
          foods: mealFoods,
          nutrition: nutritionTotal
        },
        message: 'Meal created successfully'
      };

      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update a meal
   */
  static async updateMeal(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      const updateData = req.body;

      // Verify user owns this meal
      const meals = await DatabaseService.getUserMeals(userId);
      const meal = meals.find(m => m.id === id);

      if (!meal) {
        const response: ApiResponse<null> = {
          success: false,
          data: null,
          message: 'Meal not found or you do not have access to this meal'
        };
        res.status(404).json(response);
        return;
      }

      // Update the meal
      const updatedMeal = await DatabaseService.updateMeal(id, updateData);
      
      const response: ApiResponse<any> = {
        success: true,
        data: updatedMeal,
        message: 'Meal updated successfully'
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete a meal
   */
  static async deleteMeal(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { id } = req.params;

      // Verify user owns this meal
      const meals = await DatabaseService.getUserMeals(userId);
      const meal = meals.find(m => m.id === id);

      if (!meal) {
        const response: ApiResponse<null> = {
          success: false,
          data: null,
          message: 'Meal not found or you do not have access to this meal'
        };
        res.status(404).json(response);
        return;
      }

      // Delete meal
      await DatabaseService.deleteMeal(id);
      
      const response: ApiResponse<null> = {
        success: true,
        data: null,
        message: 'Meal deleted successfully'
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get meals for a specific date
   */
  static async getMealsByDate(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { date } = req.params;

      const startDate = new Date(date);
      const endDate = new Date(date);
      endDate.setDate(endDate.getDate() + 1);

      const meals = await DatabaseService.getUserMeals(
        userId,
        startDate.toISOString(),
        endDate.toISOString()
      );

      // Group meals by meal type and calculate nutrition
      const mealsByType: Record<string, any[]> = {};
      let totalNutrition: NutritionData = {
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        fiber: 0,
        sugar: 0,
        sodium: 0
      };

      for (const meal of meals) {
        const mealFoods = await DatabaseService.getMealFoods(meal.id);
        const mealNutrition = MealController.calculateMealNutrition(mealFoods);

        // Add to totals
        Object.keys(totalNutrition).forEach(key => {
          totalNutrition[key as keyof NutritionData] += mealNutrition[key as keyof NutritionData];
        });

        const mealWithData = {
          ...meal,
          foods: mealFoods,
          nutrition: mealNutrition
        };

        if (!mealsByType[meal.meal_type]) {
          mealsByType[meal.meal_type] = [];
        }
        mealsByType[meal.meal_type].push(mealWithData);
      }

      const response: ApiResponse<any> = {
        success: true,
        data: {
          date,
          totalNutrition,
          mealsByType
        },
        message: `Meals for ${date} retrieved successfully`
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get today's meal summary
   */
  static async getTodaysSummary(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const today = new Date().toISOString().split('T')[0];

      // Get user's daily protein goal
      const user = await DatabaseService.getUserProfile(userId);
      const dailyGoal = user?.daily_protein_goal || 100;

      const startDate = new Date(today);
      const endDate = new Date(today);
      endDate.setDate(endDate.getDate() + 1);

      const meals = await DatabaseService.getUserMeals(
        userId,
        startDate.toISOString(),
        endDate.toISOString()
      );

      // Calculate summary by meal type
      const mealSummary = {
        breakfast: { count: 0, protein: 0, target: dailyGoal / 4 },
        lunch: { count: 0, protein: 0, target: dailyGoal / 4 },
        dinner: { count: 0, protein: 0, target: dailyGoal / 4 },
        snack: { count: 0, protein: 0, target: dailyGoal / 4 }
      };

      let totalProtein = 0;
      let totalCalories = 0;

      for (const meal of meals) {
        const mealFoods = await DatabaseService.getMealFoods(meal.id);
        const mealNutrition = MealController.calculateMealNutrition(mealFoods);

        totalProtein += mealNutrition.protein;
        totalCalories += mealNutrition.calories;

        if (mealSummary[meal.meal_type as keyof typeof mealSummary]) {
          mealSummary[meal.meal_type as keyof typeof mealSummary].count++;
          mealSummary[meal.meal_type as keyof typeof mealSummary].protein += mealNutrition.protein;
        }
      }

      const response: ApiResponse<any> = {
        success: true,
        data: {
          date: today,
          totalProtein,
          totalCalories,
          dailyGoal,
          progress: Math.round((totalProtein / dailyGoal) * 100),
          mealSummary
        },
        message: "Today's meal summary retrieved successfully"
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Helper method to calculate total nutrition for a meal
   */
  private static calculateMealNutrition(mealFoods: MealFood[]): NutritionData {
    const totalNutrition: NutritionData = {
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      sugar: 0,
      sodium: 0
    };

    mealFoods.forEach(mealFood => {
      if (mealFood.nutrition_data && typeof mealFood.nutrition_data === 'object') {
        const nutrition = mealFood.nutrition_data as NutritionData;
        Object.keys(totalNutrition).forEach(key => {
          if (nutrition[key as keyof NutritionData]) {
            totalNutrition[key as keyof NutritionData] += nutrition[key as keyof NutritionData];
          }
        });
      }
    });

    // Round to 2 decimal places
    Object.keys(totalNutrition).forEach(key => {
      totalNutrition[key as keyof NutritionData] = Math.round(totalNutrition[key as keyof NutritionData] * 100) / 100;
    });

    return totalNutrition;
  }
}