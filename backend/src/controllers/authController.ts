import { Request, Response, NextFunction } from 'express';
import { DatabaseService, supabase } from '../utils/database';
import { SupabaseAuthService, AuthenticatedRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { ApiResponse } from '../types';
import { InsertUserProfile, UpdateUserProfile } from '../types/supabase';

export class AuthController {
  // Verify Supabase token and ensure user profile exists
  static async verifyToken(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { token } = req.body;

      if (!token) {
        throw new AppError('Token is required', 400);
      }

      // Verify token with Supabase
      const decoded = await SupabaseAuthService.verifySupabaseToken(token);
      
      // Get or create user profile
      let userProfile = await SupabaseAuthService.getUserProfile(decoded.sub);
      
      if (!userProfile && decoded.email) {
        // Create user profile if it doesn't exist
        const profileData: InsertUserProfile = {
          id: decoded.sub,
          email: decoded.email,
          display_name: decoded.email.split('@')[0], // Default display name
        };
        
        userProfile = await DatabaseService.createUserProfile(profileData);
      }

      if (!userProfile) {
        throw new AppError('Failed to create or retrieve user profile', 500);
      }

      const response: ApiResponse = {
        success: true,
        data: {
          user: {
            id: userProfile.id,
            email: userProfile.email,
            display_name: userProfile.display_name,
            age: userProfile.age,
            weight: userProfile.weight,
            height: userProfile.height,
            daily_protein_goal: userProfile.daily_protein_goal,
            activity_level: userProfile.activity_level,
            units: userProfile.units,
            created_at: userProfile.created_at,
          },
          token: token
        },
        message: 'Token verified successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Get current user profile
  static async getProfile(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;

      const userProfile = await DatabaseService.getUserProfile(userId);

      if (!userProfile) {
        throw new AppError('User profile not found', 404);
      }

      const response: ApiResponse = {
        success: true,
        data: {
          user: {
            id: userProfile.id,
            email: userProfile.email,
            display_name: userProfile.display_name,
            age: userProfile.age,
            weight: userProfile.weight,
            height: userProfile.height,
            daily_protein_goal: userProfile.daily_protein_goal,
            activity_level: userProfile.activity_level,
            dietary_restrictions: userProfile.dietary_restrictions,
            units: userProfile.units,
            notifications_enabled: userProfile.notifications_enabled,
            privacy_level: userProfile.privacy_level,
            created_at: userProfile.created_at,
            updated_at: userProfile.updated_at,
          }
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Update user profile
  static async updateProfile(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const updateData: UpdateUserProfile = req.body;

      // Remove id and timestamps from update data if present
      const { id, created_at, updated_at, ...safeUpdateData } = updateData;

      const updatedProfile = await DatabaseService.updateUserProfile(userId, safeUpdateData);

      const response: ApiResponse = {
        success: true,
        data: {
          user: {
            id: updatedProfile.id,
            email: updatedProfile.email,
            display_name: updatedProfile.display_name,
            age: updatedProfile.age,
            weight: updatedProfile.weight,
            height: updatedProfile.height,
            daily_protein_goal: updatedProfile.daily_protein_goal,
            activity_level: updatedProfile.activity_level,
            dietary_restrictions: updatedProfile.dietary_restrictions,
            units: updatedProfile.units,
            notifications_enabled: updatedProfile.notifications_enabled,
            privacy_level: updatedProfile.privacy_level,
            created_at: updatedProfile.created_at,
            updated_at: updatedProfile.updated_at,
          }
        },
        message: 'Profile updated successfully',
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

      // Note: In Supabase, this would typically be handled by calling the Supabase Admin API
      // to delete the user from auth.users, which would cascade delete the profile
      // For now, we'll just delete the profile
      
      const { error } = await supabase.auth.admin.deleteUser(userId);
      
      if (error) {
        throw new AppError('Failed to delete user account', 500);
      }

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
}