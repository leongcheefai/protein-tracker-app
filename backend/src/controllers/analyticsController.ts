import { Response, NextFunction } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { ApiResponse } from '../types';
import { AnalyticsService } from '../services/analyticsService';

export class AnalyticsController {
  /**
   * Get comprehensive analytics overview
   */
  static async getStatsOverview(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { startDate, endDate, period } = req.query;

      let start: Date | undefined;
      let end: Date | undefined;

      // Parse date parameters
      if (startDate && typeof startDate === 'string') {
        start = new Date(startDate);
        if (isNaN(start.getTime())) {
          throw new AppError('Invalid start date format', 400);
        }
      }

      if (endDate && typeof endDate === 'string') {
        end = new Date(endDate);
        if (isNaN(end.getTime())) {
          throw new AppError('Invalid end date format', 400);
        }
      }

      // Handle predefined periods
      if (period && typeof period === 'string') {
        end = new Date();
        end.setHours(23, 59, 59, 999);
        start = new Date();

        switch (period) {
          case '7d':
            start.setDate(start.getDate() - 6);
            break;
          case '30d':
            start.setDate(start.getDate() - 29);
            break;
          case '90d':
            start.setDate(start.getDate() - 89);
            break;
          case '1y':
            start.setFullYear(start.getFullYear() - 1);
            break;
          default:
            throw new AppError('Invalid period. Use 7d, 30d, 90d, or 1y', 400);
        }
        start.setHours(0, 0, 0, 0);
      }

      const analytics = await AnalyticsService.getAnalyticsOverview(userId, start, end);

      const response: ApiResponse<typeof analytics> = {
        success: true,
        data: analytics,
        message: 'Analytics overview retrieved successfully',
        timestamp: new Date().toISOString()
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get meal consistency analysis
   */
  static async getMealConsistency(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { days = 30 } = req.query;

      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - (parseInt(days as string) - 1));
      startDate.setHours(0, 0, 0, 0);

      const analytics = await AnalyticsService.getAnalyticsOverview(userId, startDate, endDate);

      const response: ApiResponse<typeof analytics.mealTimingAnalysis> = {
        success: true,
        data: analytics.mealTimingAnalysis,
        message: 'Meal consistency analysis retrieved successfully',
        timestamp: new Date().toISOString()
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get weekly trends
   */
  static async getWeeklyTrend(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { weeks = 8 } = req.query;

      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - (parseInt(weeks as string) * 7 - 1));
      startDate.setHours(0, 0, 0, 0);

      const analytics = await AnalyticsService.getAnalyticsOverview(userId, startDate, endDate);

      const response: ApiResponse<typeof analytics.weeklyStats> = {
        success: true,
        data: analytics.weeklyStats,
        message: 'Weekly trend analysis retrieved successfully',
        timestamp: new Date().toISOString()
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get streak information
   */
  static async getStreaks(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;

      // Get last 90 days for accurate streak calculation
      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 89);
      startDate.setHours(0, 0, 0, 0);

      const analytics = await AnalyticsService.getAnalyticsOverview(userId, startDate, endDate);

      const response: ApiResponse<typeof analytics.streakData> = {
        success: true,
        data: analytics.streakData,
        message: 'Streak information retrieved successfully',
        timestamp: new Date().toISOString()
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get personalized insights
   */
  static async getInsights(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;

      // Get last 30 days for insights
      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 29);
      startDate.setHours(0, 0, 0, 0);

      const analytics = await AnalyticsService.getAnalyticsOverview(userId, startDate, endDate);

      const response: ApiResponse<typeof analytics.insights> = {
        success: true,
        data: analytics.insights,
        message: 'Personalized insights retrieved successfully',
        timestamp: new Date().toISOString()
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get user achievements
   */
  static async getAchievements(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;

      // Get last 90 days for achievements
      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 89);
      startDate.setHours(0, 0, 0, 0);

      const analytics = await AnalyticsService.getAnalyticsOverview(userId, startDate, endDate);

      const response: ApiResponse<typeof analytics.achievements> = {
        success: true,
        data: analytics.achievements,
        message: 'User achievements retrieved successfully',
        timestamp: new Date().toISOString()
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get daily breakdown for a specific date range
   */
  static async getDailyBreakdown(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { startDate, endDate } = req.query;

      if (!startDate || !endDate) {
        throw new AppError('Start date and end date are required', 400);
      }

      const start = new Date(startDate as string);
      const end = new Date(endDate as string);

      if (isNaN(start.getTime()) || isNaN(end.getTime())) {
        throw new AppError('Invalid date format', 400);
      }

      // Limit to 90 days max
      const diffTime = Math.abs(end.getTime() - start.getTime());
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      
      if (diffDays > 90) {
        throw new AppError('Date range cannot exceed 90 days', 400);
      }

      const analytics = await AnalyticsService.getAnalyticsOverview(userId, start, end);

      const response: ApiResponse<typeof analytics.dailyStats> = {
        success: true,
        data: analytics.dailyStats,
        message: 'Daily breakdown retrieved successfully',
        timestamp: new Date().toISOString()
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Export user data
   */
  static async exportData(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { format = 'json', startDate, endDate } = req.query;

      if (!['json', 'csv'].includes(format as string)) {
        throw new AppError('Invalid format. Use json or csv', 400);
      }

      let start: Date | undefined;
      let end: Date | undefined;

      if (startDate && typeof startDate === 'string') {
        start = new Date(startDate);
        if (isNaN(start.getTime())) {
          throw new AppError('Invalid start date format', 400);
        }
      }

      if (endDate && typeof endDate === 'string') {
        end = new Date(endDate);
        if (isNaN(end.getTime())) {
          throw new AppError('Invalid end date format', 400);
        }
      }

      const exportData = await AnalyticsService.exportUserData(
        userId,
        format as 'json' | 'csv',
        start,
        end
      );

      res.setHeader('Content-Type', exportData.contentType);
      res.setHeader('Content-Disposition', `attachment; filename="${exportData.filename}"`);
      res.send(exportData.data);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get nutrition recommendations based on patterns
   */
  static async getNutritionRecommendations(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;

      // Get last 14 days for pattern analysis
      const endDate = new Date();
      endDate.setHours(23, 59, 59, 999);

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 13);
      startDate.setHours(0, 0, 0, 0);

      const analytics = await AnalyticsService.getAnalyticsOverview(userId, startDate, endDate);

      // Filter for actionable recommendations
      const recommendations = analytics.insights.filter(insight => 
        insight.actionable && ['recommendation', 'warning'].includes(insight.type)
      );

      const response: ApiResponse<typeof recommendations> = {
        success: true,
        data: recommendations,
        message: 'Nutrition recommendations retrieved successfully',
        timestamp: new Date().toISOString()
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get comparative analysis (current vs previous period)
   */
  static async getComparative(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { period = '30d' } = req.query;

      let days: number;
      switch (period) {
        case '7d': days = 7; break;
        case '30d': days = 30; break;
        case '90d': days = 90; break;
        default: days = 30;
      }

      // Current period
      const currentEnd = new Date();
      currentEnd.setHours(23, 59, 59, 999);
      const currentStart = new Date();
      currentStart.setDate(currentStart.getDate() - (days - 1));
      currentStart.setHours(0, 0, 0, 0);

      // Previous period
      const previousEnd = new Date(currentStart);
      previousEnd.setDate(previousEnd.getDate() - 1);
      previousEnd.setHours(23, 59, 59, 999);
      const previousStart = new Date(previousEnd);
      previousStart.setDate(previousStart.getDate() - (days - 1));
      previousStart.setHours(0, 0, 0, 0);

      const [currentAnalytics, previousAnalytics] = await Promise.all([
        AnalyticsService.getAnalyticsOverview(userId, currentStart, currentEnd),
        AnalyticsService.getAnalyticsOverview(userId, previousStart, previousEnd),
      ]);

      // Calculate comparisons
      const currentAvg = currentAnalytics.dailyStats.reduce((sum, day) => sum + day.totalProtein, 0) / currentAnalytics.dailyStats.length || 0;
      const previousAvg = previousAnalytics.dailyStats.reduce((sum, day) => sum + day.totalProtein, 0) / previousAnalytics.dailyStats.length || 0;
      
      const proteinChange = previousAvg > 0 ? ((currentAvg - previousAvg) / previousAvg) * 100 : 0;
      
      const currentGoalMet = currentAnalytics.dailyStats.filter(day => day.goalMet).length;
      const previousGoalMet = previousAnalytics.dailyStats.filter(day => day.goalMet).length;
      const goalMetChange = previousGoalMet > 0 ? ((currentGoalMet - previousGoalMet) / previousGoalMet) * 100 : 0;

      const comparison = {
        current: {
          period: currentAnalytics.period,
          averageProtein: Math.round(currentAvg * 10) / 10,
          daysWithGoalMet: currentGoalMet,
          totalDays: currentAnalytics.dailyStats.length,
          streak: currentAnalytics.streakData.currentStreak,
        },
        previous: {
          period: previousAnalytics.period,
          averageProtein: Math.round(previousAvg * 10) / 10,
          daysWithGoalMet: previousGoalMet,
          totalDays: previousAnalytics.dailyStats.length,
        },
        changes: {
          proteinChange: Math.round(proteinChange * 10) / 10,
          goalMetChange: Math.round(goalMetChange * 10) / 10,
          trend: proteinChange > 5 ? 'improving' : proteinChange < -5 ? 'declining' : 'stable',
        }
      };

      const response: ApiResponse<typeof comparison> = {
        success: true,
        data: comparison,
        message: 'Comparative analysis retrieved successfully',
        timestamp: new Date().toISOString()
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}