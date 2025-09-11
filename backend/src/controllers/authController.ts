import { Request, Response, NextFunction } from 'express';
import { DatabaseService, supabase } from '../utils/database';
import { SupabaseAuthService, AuthenticatedRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { ApiResponse } from '../types';
import { InsertUserProfile, UpdateUserProfile, Database } from '../types/supabase';

export class AuthController {
  // Verify Supabase token and ensure user profile exists
  static async verifyToken(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { token } = req.body;

      if (!token) {
        throw new AppError('Token is required', 400);
      }

      console.log('🔄 Verifying token for user authentication');

      // Verify token with Supabase
      const decoded = await SupabaseAuthService.verifySupabaseToken(token);
      console.log(`✅ Token verified for user: ${decoded.sub}, email: ${decoded.email}`);
      
      // Get or create user profile
      console.log(`🔍 Looking for existing user profile for user ID: ${decoded.sub}`);
      let userProfile = await SupabaseAuthService.getUserProfile(decoded.sub);
      
      if (!userProfile && decoded.email) {
        console.log(`📝 No profile found, attempting to create new profile for: ${decoded.email}`);
        // Create user profile if it doesn't exist (only for new users)
        try {
          const profileData: InsertUserProfile = {
            id: decoded.sub,
            email: decoded.email,
            display_name: decoded.email.split('@')[0], // Default display name
          };
          
          userProfile = await DatabaseService.createUserProfileWithContext(profileData, token);
          console.log(`✅ Successfully created new user profile for: ${decoded.email}`);
        } catch (error: any) {
          console.log(`❌ Profile creation failed: ${error.message}, code: ${error.code}`);
          // If duplicate key error, the user already exists - try to get it again with user context
          if (error.code === '23505') {
            console.log(`🔄 Duplicate key error - trying to fetch existing profile with user context`);
            // Try to get profile using user context instead of service account
            userProfile = await DatabaseService.getUserProfileWithContext(decoded.sub, token);
          } else {
            throw error;
          }
        }
      } else if (userProfile) {
        console.log(`✅ Found existing user profile for: ${decoded.email}`);
      }

      if (!userProfile) {
        console.log(`❌ Still no user profile found after all attempts for user: ${decoded.sub}`);
        throw new AppError('Failed to create or retrieve user profile', 500);
      }

      const response: ApiResponse = {
        success: true,
        data: {
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
      const userToken = req.userToken!;

      console.log(`🔍 Getting profile for user: ${userId}`);
      
      // Try to get user profile with service account first
      let userProfile: Database['public']['Tables']['user_profiles']['Row'] | null = await DatabaseService.getUserProfile(userId);

      // If no profile found with service account, try with user context (for RLS)
      if (!userProfile) {
        console.log(`🔄 No profile found with service account, trying with user context for user: ${userId}`);
        try {
          userProfile = await DatabaseService.getUserProfileWithContext(userId, userToken);
        } catch (contextError: any) {
          console.log(`❌ Failed to get profile with user context: ${contextError.message}`);
        }
      }

      if (!userProfile) {
        console.log(`❌ User profile not found for user: ${userId}`);
        throw new AppError('User profile not found', 404);
      }

      console.log(`✅ Found user profile for: ${userProfile.email}`);

      const response: ApiResponse = {
        success: true,
        data: {
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
        },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      console.log(`❌ Error in getProfile: ${error instanceof Error ? error.message : 'Unknown error'}`);
      next(error);
    }
  }

  // Update user profile
  static async updateProfile(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.id;
      const userToken = req.userToken!;
      const updateData: UpdateUserProfile = req.body;

      // Remove id and timestamps from update data if present
      const { id, created_at, updated_at, ...safeUpdateData } = updateData;

      console.log(`🔄 Updating profile for user: ${userId} with context`);
      const updatedProfile = await DatabaseService.updateUserProfileWithContext(userId, safeUpdateData, userToken);
      console.log(`✅ Profile updated successfully for user: ${userId}`);

      const response: ApiResponse = {
        success: true,
        data: {
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