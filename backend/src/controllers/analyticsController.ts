import { Response, NextFunction } from 'express';
import { prisma } from '../utils/database';
import { AuthenticatedRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { WeeklyStats, MealConsistency, ApiResponse } from '../types';
import { requirePremium } from '../middleware/auth';

export class AnalyticsController {
  // Get comprehensive statistics overview
  static async getStatsOverview(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;

      // Get date range (default to last 30 days)
      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);
      
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 29); // Last 30 days
      startDate.setHours(0, 0, 0, 0);

      // Get all progress data in range
      const progressData = await prisma.dailyProgress.findMany({
        where: {
          userId,
          date: {
            gte: startDate,
            lte: endDate,
          },
        },
        include: {
          mealProgress: true,
        },
        orderBy: { date: 'asc' },
      });

      if (progressData.length === 0) {
        const response: ApiResponse = {
          success: true,
          data: {
            weeklyAverage: 0,
            goalHitPercentage: 0,
            mostConsistentMeal: 'lunch',
            currentStreak: 0,
            longestStreak: 0,
            totalDaysTracked: 0,
            bestDay: null,
            bestDayProtein: 0,
            weeklyTrend: [],
            mealConsistency: {
              breakfast: 0,
              lunch: 0,
              dinner: 0,
              snack: 0,
            },
          },
          timestamp: new Date().toISOString(),
        };

        res.status(200).json(response);
        return;
      }

      // Calculate basic stats
      const totalProtein = progressData.reduce((sum, day) => sum + day.totalProtein, 0);
      const weeklyAverage = totalProtein / progressData.length;
      const goalsMetCount = progressData.filter(day => day.goalMet).length;
      const goalHitPercentage = (goalsMetCount / progressData.length) * 100;

      // Find best day
      const bestDay = progressData.reduce((best, current) => 
        current.totalProtein > best.totalProtein ? current : best
      );

      // Get current and longest streak
      const currentStreak = progressData[progressData.length - 1]?.streakCount || 0;
      const longestStreak = Math.max(...progressData.map(day => day.streakCount));

      // Calculate weekly trend (last 7 days)
      const weeklyTrend = progressData.slice(-7).map(day => day.totalProtein);

      // Calculate meal consistency
      const mealStats = {
        breakfast: { total: 0, count: 0 },
        lunch: { total: 0, count: 0 },
        dinner: { total: 0, count: 0 },
        snack: { total: 0, count: 0 },
      };

      progressData.forEach(day => {
        day.mealProgress.forEach(meal => {
          const mealKey = meal.mealType.toLowerCase() as keyof typeof mealStats;
          if (mealStats[mealKey]) {
            const targetMet = meal.actualProtein >= meal.targetProtein;
            if (targetMet) mealStats[mealKey].total++;
            mealStats[mealKey].count++;
          }
        });
      });

      const mealConsistency: MealConsistency = {
        breakfast: mealStats.breakfast.count > 0 ? (mealStats.breakfast.total / mealStats.breakfast.count) * 100 : 0,
        lunch: mealStats.lunch.count > 0 ? (mealStats.lunch.total / mealStats.lunch.count) * 100 : 0,
        dinner: mealStats.dinner.count > 0 ? (mealStats.dinner.total / mealStats.dinner.count) * 100 : 0,
        snack: mealStats.snack.count > 0 ? (mealStats.snack.total / mealStats.snack.count) * 100 : 0,
      };

      // Find most consistent meal
      const mostConsistentMeal = Object.entries(mealConsistency).reduce((best, [meal, percentage]) => 
        percentage > best.percentage ? { meal, percentage } : best,
        { meal: 'lunch', percentage: 0 }
      ).meal;

      const stats: WeeklyStats = {
        weeklyAverage: Math.round(weeklyAverage * 100) / 100,
        goalHitPercentage: Math.round(goalHitPercentage * 100) / 100,
        mostConsistentMeal,
        currentStreak,
        longestStreak,
        totalDaysTracked: progressData.length,
        weeklyTrend,
      };

      const response: ApiResponse = {
        success: true,
        data: {
          ...stats,
          bestDay: bestDay.date.toISOString().split('T')[0],
          bestDayProtein: bestDay.totalProtein,
          mealConsistency,
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Get meal consistency breakdown
  static async getMealConsistency(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const days = parseInt(req.query.days as string) || 30;

      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);
      
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - (days - 1));
      startDate.setHours(0, 0, 0, 0);

      const mealProgress = await prisma.mealProgress.findMany({
        where: {
          userId,
          date: {
            gte: startDate,
            lte: endDate,
          },
        },
        orderBy: [
          { date: 'desc' },
          { mealType: 'asc' },
        ],
      });

      // Group by meal type and calculate consistency
      const mealStats = {
        breakfast: [] as number[],
        lunch: [] as number[],
        dinner: [] as number[],
        snack: [] as number[],
      };

      mealProgress.forEach(meal => {
        const mealKey = meal.mealType.toLowerCase() as keyof typeof mealStats;
        if (mealStats[mealKey]) {
          const percentage = (meal.actualProtein / meal.targetProtein) * 100;
          mealStats[mealKey].push(Math.min(percentage, 100)); // Cap at 100%
        }
      });

      const consistency = Object.entries(mealStats).reduce((acc, [meal, values]) => {
        const average = values.length > 0 ? values.reduce((sum, val) => sum + val, 0) / values.length : 0;
        acc[meal] = Math.round(average * 100) / 100;
        return acc;
      }, {} as any);

      const response: ApiResponse = {
        success: true,
        data: {
          consistency,
          period: {
            days,
            startDate: startDate.toISOString().split('T')[0],
            endDate: endDate.toISOString().split('T')[0],
          },
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Get weekly protein intake trend
  static async getWeeklyTrend(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const weeks = parseInt(req.query.weeks as string) || 4;

      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);
      
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - (weeks * 7 - 1));
      startDate.setHours(0, 0, 0, 0);

      const progressData = await prisma.dailyProgress.findMany({
        where: {
          userId,
          date: {
            gte: startDate,
            lte: endDate,
          },
        },
        orderBy: { date: 'asc' },
      });

      // Group data by weeks
      const weeklyData: { week: string; average: number; days: number }[] = [];
      const currentWeekData: number[] = [];
      let currentWeekStart = new Date(startDate);

      progressData.forEach(day => {
        const dayDate = new Date(day.date);
        const weekStart = new Date(currentWeekStart);
        const weekEnd = new Date(currentWeekStart);
        weekEnd.setDate(weekEnd.getDate() + 6);

        if (dayDate >= weekStart && dayDate <= weekEnd) {
          currentWeekData.push(day.totalProtein);
        } else {
          // Save current week and start new one
          if (currentWeekData.length > 0) {
            const average = currentWeekData.reduce((sum, val) => sum + val, 0) / currentWeekData.length;
            weeklyData.push({
              week: `${weekStart.toISOString().split('T')[0]} to ${weekEnd.toISOString().split('T')[0]}`,
              average: Math.round(average * 100) / 100,
              days: currentWeekData.length,
            });
            currentWeekData.length = 0; // Clear array
          }
          
          // Update week start
          while (dayDate > weekEnd) {
            currentWeekStart.setDate(currentWeekStart.getDate() + 7);
            weekEnd.setDate(weekEnd.getDate() + 7);
          }
          currentWeekData.push(day.totalProtein);
        }
      });

      // Add final week if there's data
      if (currentWeekData.length > 0) {
        const weekEnd = new Date(currentWeekStart);
        weekEnd.setDate(weekEnd.getDate() + 6);
        const average = currentWeekData.reduce((sum, val) => sum + val, 0) / currentWeekData.length;
        weeklyData.push({
          week: `${currentWeekStart.toISOString().split('T')[0]} to ${weekEnd.toISOString().split('T')[0]}`,
          average: Math.round(average * 100) / 100,
          days: currentWeekData.length,
        });
      }

      const response: ApiResponse = {
        success: true,
        data: {
          weeklyTrend: weeklyData,
          period: {
            weeks,
            startDate: startDate.toISOString().split('T')[0],
            endDate: endDate.toISOString().split('T')[0],
          },
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Export user data (Premium feature)
  static async exportData(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const format = req.query.format as string || 'json';

      if (!['json', 'csv'].includes(format)) {
        throw new AppError('Invalid format. Supported formats: json, csv', 400);
      }

      // Get all user data
      const [user, foodItems, dailyProgress, mealProgress] = await Promise.all([
        prisma.user.findUnique({
          where: { id: userId },
          include: {
            settings: true,
            subscription: true,
          },
        }),
        prisma.foodItem.findMany({
          where: { userId },
          include: { food: true },
          orderBy: { dateLogged: 'desc' },
        }),
        prisma.dailyProgress.findMany({
          where: { userId },
          orderBy: { date: 'desc' },
        }),
        prisma.mealProgress.findMany({
          where: { userId },
          orderBy: [{ date: 'desc' }, { mealType: 'asc' }],
        }),
      ]);

      const exportData = {
        user: {
          id: user?.id,
          email: user?.email,
          name: user?.name,
          height: user?.height,
          weight: user?.weight,
          goal: user?.goal,
          dailyProteinTarget: user?.dailyProteinTarget,
          createdAt: user?.createdAt,
          settings: user?.settings,
        },
        foodItems: foodItems.map(item => ({
          id: item.id,
          name: item.customName || item.food?.name,
          portionSize: item.portionSize,
          proteinContent: item.proteinContent,
          calories: item.calories,
          mealType: item.mealType,
          dateLogged: item.dateLogged,
          isQuickAdd: item.isQuickAdd,
        })),
        dailyProgress: dailyProgress.map(day => ({
          date: day.date,
          totalProtein: day.totalProtein,
          dailyTarget: day.dailyTarget,
          goalMet: day.goalMet,
          streakCount: day.streakCount,
          achievementPercentage: day.achievementPercentage,
        })),
        mealProgress: mealProgress.map(meal => ({
          date: meal.date,
          mealType: meal.mealType,
          targetProtein: meal.targetProtein,
          actualProtein: meal.actualProtein,
          itemsCount: meal.itemsCount,
        })),
        exportedAt: new Date().toISOString(),
      };

      if (format === 'json') {
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', 'attachment; filename="protein-tracker-data.json"');
        res.status(200).json(exportData);
      } else if (format === 'csv') {
        // For CSV, we'll export the food items as the main data
        const csvHeader = 'Date,Food Name,Portion Size (g),Protein (g),Calories,Meal Type,Is Quick Add\n';
        const csvRows = exportData.foodItems.map(item => 
          `${item.dateLogged},${item.name},${item.portionSize},${item.proteinContent},${item.calories || ''},${item.mealType},${item.isQuickAdd}`
        ).join('\n');

        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', 'attachment; filename="protein-tracker-data.csv"');
        res.status(200).send(csvHeader + csvRows);
      }
    } catch (error) {
      next(error);
    }
  }
}