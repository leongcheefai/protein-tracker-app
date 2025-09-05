import { Response, NextFunction } from 'express';
import { prisma } from '../utils/database';
import { AuthenticatedRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { UpdateUserProfile, UserSettings, ApiResponse } from '../types';

export class UserController {
  // Update user profile
  static async updateProfile(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const updateData: UpdateUserProfile = req.body;

      // Calculate new daily protein target if weight or training multiplier changed
      if (updateData.weight || updateData.trainingMultiplier || updateData.goal) {
        const currentUser = await prisma.user.findUnique({
          where: { id: userId },
          select: { weight: true, trainingMultiplier: true, goal: true },
        });

        if (currentUser) {
          const weight = updateData.weight ?? currentUser.weight ?? 70;
          const multiplier = updateData.trainingMultiplier ?? currentUser.trainingMultiplier ?? 1.8;
          const goal = updateData.goal ?? currentUser.goal.toLowerCase();

          let baseTarget = weight * multiplier;
          
          // Apply goal modifier
          switch (goal) {
            case 'bulk':
              baseTarget *= 1.1; // 10% increase for bulking
              break;
            case 'cut':
              baseTarget *= 0.9; // 10% decrease for cutting
              break;
            default: // maintain
              break;
          }

          updateData.dailyProteinTarget = Math.round(baseTarget * 100) / 100; // Round to 2 decimal places
        }
      }

      const updatedUser = await prisma.user.update({
        where: { id: userId },
        data: {
          ...updateData,
          goal: updateData.goal?.toUpperCase() as 'MAINTAIN' | 'BULK' | 'CUT' | undefined,
        },
        include: {
          settings: true,
          subscription: true,
        },
      });

      const userResponse = {
        id: updatedUser.id,
        email: updatedUser.email,
        name: updatedUser.name,
        profileImageUrl: updatedUser.profileImageUrl,
        height: updatedUser.height,
        weight: updatedUser.weight,
        trainingMultiplier: updatedUser.trainingMultiplier,
        goal: updatedUser.goal.toLowerCase(),
        dailyProteinTarget: updatedUser.dailyProteinTarget,
        settings: updatedUser.settings,
        subscription: updatedUser.subscription ? {
          planType: updatedUser.subscription.planType.toLowerCase(),
          status: updatedUser.subscription.status.toLowerCase(),
        } : null,
        updatedAt: updatedUser.updatedAt,
      };

      const response: ApiResponse = {
        success: true,
        data: { user: userResponse },
        message: 'Profile updated successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Update user settings
  static async updateSettings(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const settingsData: Partial<UserSettings> = req.body;

      // Check if user settings exist, create if not
      const existingSettings = await prisma.userSettings.findUnique({
        where: { userId },
      });

      let updatedSettings;
      if (existingSettings) {
        updatedSettings = await prisma.userSettings.update({
          where: { userId },
          data: settingsData,
        });
      } else {
        updatedSettings = await prisma.userSettings.create({
          data: {
            userId,
            ...settingsData,
          },
        });
      }

      const response: ApiResponse = {
        success: true,
        data: { settings: updatedSettings },
        message: 'Settings updated successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Get user settings
  static async getSettings(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;

      let settings = await prisma.userSettings.findUnique({
        where: { userId },
      });

      // Create default settings if none exist
      if (!settings) {
        settings = await prisma.userSettings.create({
          data: {
            userId,
            // Default values will be applied by Prisma schema
          },
        });
      }

      const response: ApiResponse = {
        success: true,
        data: { settings },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Delete user account
  static async deleteAccount(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const { password } = req.body;

      if (!password) {
        throw new AppError('Password is required to delete account', 400);
      }

      // Verify password
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { password: true },
      });

      if (!user || !user.password) {
        throw new AppError('Unable to verify account', 400);
      }

      // For OAuth users without password, we might need a different verification method
      const bcrypt = await import('bcrypt');
      const isValidPassword = await bcrypt.compare(password, user.password);
      
      if (!isValidPassword) {
        throw new AppError('Invalid password', 401);
      }

      // Delete user (cascade will delete related records)
      await prisma.user.delete({
        where: { id: userId },
      });

      const response: ApiResponse = {
        success: true,
        message: 'Account deleted successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Get user statistics summary
  static async getStatsSummary(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;

      // Get basic stats
      const [totalFoodItems, totalDaysTracked, currentStreak, longestStreak] = await Promise.all([
        prisma.foodItem.count({
          where: { userId },
        }),
        prisma.dailyProgress.count({
          where: { userId },
        }),
        // Get current streak (simplified - just count recent consecutive days with goal met)
        prisma.dailyProgress.count({
          where: {
            userId,
            goalMet: true,
            date: {
              gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Last 7 days
            },
          },
        }),
        // Get longest streak (simplified - just get the highest streak count)
        prisma.dailyProgress.findFirst({
          where: { userId },
          orderBy: { streakCount: 'desc' },
          select: { streakCount: true },
        }),
      ]);

      const response: ApiResponse = {
        success: true,
        data: {
          totalFoodItems,
          totalDaysTracked,
          currentStreak,
          longestStreak: longestStreak?.streakCount || 0,
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}