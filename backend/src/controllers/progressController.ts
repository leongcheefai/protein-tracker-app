import { Response, NextFunction } from 'express';
import { prisma } from '../utils/database';
import { AuthenticatedRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { DailyProgress, ApiResponse } from '../types';

export class ProgressController {
  // Get daily progress for a specific date
  static async getDailyProgress(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const dateStr = req.params.date || new Date().toISOString().split('T')[0];
      const date = new Date(dateStr!);
      date.setHours(0, 0, 0, 0);

      // Get daily progress
      const dailyProgress = await prisma.dailyProgress.findUnique({
        where: {
          userId_date: {
            userId,
            date,
          },
        },
        include: {
          mealProgress: {
            orderBy: [
              { mealType: 'asc' },
            ],
          },
        },
      });

      if (!dailyProgress) {
        // Return default structure if no progress found
        const user = await prisma.user.findUnique({
          where: { id: userId },
          select: { dailyProteinTarget: true },
        });

        const dailyTarget = user?.dailyProteinTarget || 126;
        const mealTarget = dailyTarget / 4;

        const response: ApiResponse = {
          success: true,
          data: {
            date: dateStr!,
            totalProtein: 0,
            dailyTarget,
            goalMet: false,
            streakCount: 0,
            achievementPercentage: 0,
            mealBreakdown: {
              breakfast: { target: mealTarget, actual: 0, items: 0 },
              lunch: { target: mealTarget, actual: 0, items: 0 },
              dinner: { target: mealTarget, actual: 0, items: 0 },
              snack: { target: mealTarget, actual: 0, items: 0 },
            },
          },
          timestamp: new Date().toISOString(),
        };

        res.status(200).json(response);
        return;
      }

      // Build meal breakdown
      const mealBreakdown: any = {
        breakfast: { target: 0, actual: 0, items: 0 },
        lunch: { target: 0, actual: 0, items: 0 },
        dinner: { target: 0, actual: 0, items: 0 },
        snack: { target: 0, actual: 0, items: 0 },
      };

      dailyProgress.mealProgress.forEach(meal => {
        const mealKey = meal.mealType.toLowerCase();
        mealBreakdown[mealKey] = {
          target: meal.targetProtein,
          actual: meal.actualProtein,
          items: meal.itemsCount,
        };
      });

      const progressData: DailyProgress = {
        date: dateStr!,
        totalProtein: dailyProgress.totalProtein,
        dailyTarget: dailyProgress.dailyTarget,
        goalMet: dailyProgress.goalMet,
        streakCount: dailyProgress.streakCount,
        mealBreakdown,
      };

      const response: ApiResponse = {
        success: true,
        data: progressData,
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Get historical progress data
  static async getHistoryData(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const limit = parseInt(req.query.limit as string) || 30;
      const offset = parseInt(req.query.offset as string) || 0;

      // Date range filters
      let startDate: Date | undefined;
      let endDate: Date | undefined;

      if (req.query.startDate) {
        startDate = new Date(req.query.startDate as string);
        startDate.setHours(0, 0, 0, 0);
      }

      if (req.query.endDate) {
        endDate = new Date(req.query.endDate as string);
        endDate.setHours(23, 59, 59, 999);
      }

      // Build where clause
      const whereClause: any = { userId };
      if (startDate || endDate) {
        whereClause.date = {};
        if (startDate) whereClause.date.gte = startDate;
        if (endDate) whereClause.date.lte = endDate;
      }

      // Get progress data
      const progressData = await prisma.dailyProgress.findMany({
        where: whereClause,
        include: {
          mealProgress: {
            orderBy: [{ mealType: 'asc' }],
          },
        },
        orderBy: { date: 'desc' },
        take: limit,
        skip: offset,
      });

      // Format response data
      const formattedData = progressData.map(day => {
        const mealBreakdown: any = {
          breakfast: { target: 0, actual: 0, items: 0 },
          lunch: { target: 0, actual: 0, items: 0 },
          dinner: { target: 0, actual: 0, items: 0 },
          snack: { target: 0, actual: 0, items: 0 },
        };

        day.mealProgress.forEach(meal => {
          const mealKey = meal.mealType.toLowerCase();
          mealBreakdown[mealKey] = {
            target: meal.targetProtein,
            actual: meal.actualProtein,
            items: meal.itemsCount,
          };
        });

        return {
          date: day.date.toISOString().split('T')[0],
          totalProtein: day.totalProtein,
          dailyTarget: day.dailyTarget,
          goalMet: day.goalMet,
          streakCount: day.streakCount,
          achievementPercentage: day.achievementPercentage,
          mealBreakdown,
        };
      });

      const total = await prisma.dailyProgress.count({
        where: whereClause,
      });

      const response: ApiResponse = {
        success: true,
        data: {
          history: formattedData,
          pagination: {
            limit,
            offset,
            total,
          },
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Get current streak information
  static async getStreakInfo(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;

      // Get the most recent progress record for current streak
      const latestProgress = await prisma.dailyProgress.findFirst({
        where: { userId },
        orderBy: { date: 'desc' },
        select: { streakCount: true, goalMet: true, date: true },
      });

      // Get the longest streak
      const longestStreak = await prisma.dailyProgress.findFirst({
        where: { userId },
        orderBy: { streakCount: 'desc' },
        select: { streakCount: true },
      });

      // Calculate current streak (simplified logic)
      let currentStreak = 0;
      if (latestProgress) {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const progressDate = new Date(latestProgress.date);
        progressDate.setHours(0, 0, 0, 0);

        // If the latest progress is from today or yesterday and goal was met
        const daysDiff = Math.floor((today.getTime() - progressDate.getTime()) / (1000 * 60 * 60 * 24));
        if (daysDiff <= 1 && latestProgress.goalMet) {
          currentStreak = latestProgress.streakCount;
        }
      }

      const response: ApiResponse = {
        success: true,
        data: {
          currentStreak,
          longestStreak: longestStreak?.streakCount || 0,
          lastProgressDate: latestProgress?.date || null,
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Get weekly summary
  static async getWeeklySummary(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      
      // Calculate dates for the last 7 days
      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);
      
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 6); // Last 7 days including today
      startDate.setHours(0, 0, 0, 0);

      // Get progress data for the last 7 days
      const weeklyData = await prisma.dailyProgress.findMany({
        where: {
          userId,
          date: {
            gte: startDate,
            lte: endDate,
          },
        },
        orderBy: { date: 'asc' },
      });

      // Calculate summary stats
      let totalProtein = 0;
      let goalsMetCount = 0;
      const dailyValues: number[] = [];

      weeklyData.forEach(day => {
        totalProtein += day.totalProtein;
        if (day.goalMet) goalsMetCount++;
        dailyValues.push(day.totalProtein);
      });

      const weeklyAverage = weeklyData.length > 0 ? totalProtein / weeklyData.length : 0;
      const goalHitPercentage = weeklyData.length > 0 ? (goalsMetCount / weeklyData.length) * 100 : 0;

      const response: ApiResponse = {
        success: true,
        data: {
          weeklyAverage: Math.round(weeklyAverage * 100) / 100,
          goalHitPercentage: Math.round(goalHitPercentage * 100) / 100,
          totalDaysTracked: weeklyData.length,
          dailyValues,
          startDate: startDate.toISOString().split('T')[0],
          endDate: endDate.toISOString().split('T')[0],
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}