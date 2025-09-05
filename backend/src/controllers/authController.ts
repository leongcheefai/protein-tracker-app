import { Request, Response, NextFunction } from 'express';
import { prisma } from '../utils/database';
import { AuthService, AuthenticatedRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { CreateUserData, ApiResponse } from '../types';

export class AuthController {
  // Register a new user
  static async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { email, password, name }: CreateUserData = req.body;

      // Check if user already exists
      const existingUser = await prisma.user.findUnique({
        where: { email },
      });

      if (existingUser) {
        throw new AppError('User with this email already exists', 409);
      }

      // Hash password
      const hashedPassword = await AuthService.hashPassword(password!);

      // Create user
      const user = await prisma.user.create({
        data: {
          email,
          password: hashedPassword,
          name,
          settings: {
            create: {
              // Default settings will be applied by Prisma schema defaults
            },
          },
        },
        include: {
          settings: true,
        },
      });

      // Generate tokens
      const { accessToken, refreshToken } = AuthService.generateTokens(user.id, user.email);

      // Create user response (without password)
      const userResponse = {
        id: user.id,
        email: user.email,
        name: user.name,
        profileImageUrl: user.profileImageUrl,
        height: user.height,
        weight: user.weight,
        trainingMultiplier: user.trainingMultiplier,
        goal: user.goal.toLowerCase(),
        dailyProteinTarget: user.dailyProteinTarget,
        createdAt: user.createdAt,
      };

      const response: ApiResponse = {
        success: true,
        data: {
          user: userResponse,
          accessToken,
          refreshToken,
        },
        message: 'User registered successfully',
        timestamp: new Date().toISOString(),
      };

      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Login user
  static async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { email, password } = req.body;

      // Find user
      const user = await prisma.user.findUnique({
        where: { email },
        include: {
          settings: true,
          subscription: true,
        },
      });

      if (!user || !user.password) {
        throw new AppError('Invalid email or password', 401);
      }

      // Verify password
      const isValidPassword = await AuthService.comparePassword(password, user.password);
      
      if (!isValidPassword) {
        throw new AppError('Invalid email or password', 401);
      }

      // Update last login
      await prisma.user.update({
        where: { id: user.id },
        data: { lastLoginAt: new Date() },
      });

      // Generate tokens
      const { accessToken, refreshToken } = AuthService.generateTokens(user.id, user.email);

      // Create user response (without password)
      const userResponse = {
        id: user.id,
        email: user.email,
        name: user.name,
        profileImageUrl: user.profileImageUrl,
        height: user.height,
        weight: user.weight,
        trainingMultiplier: user.trainingMultiplier,
        goal: user.goal.toLowerCase(),
        dailyProteinTarget: user.dailyProteinTarget,
        settings: user.settings,
        subscription: user.subscription ? {
          planType: user.subscription.planType.toLowerCase(),
          status: user.subscription.status.toLowerCase(),
          trialEnd: user.subscription.trialEnd,
        } : null,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
      };

      const response: ApiResponse = {
        success: true,
        data: {
          user: userResponse,
          accessToken,
          refreshToken,
        },
        message: 'Login successful',
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Refresh tokens
  static async refreshToken(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        throw new AppError('Refresh token is required', 400);
      }

      // Verify refresh token
      const decoded = AuthService.verifyRefreshToken(refreshToken);

      // Get user to ensure they still exist
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
      });

      if (!user) {
        throw new AppError('User not found', 404);
      }

      // Generate new tokens
      const tokens = AuthService.generateTokens(user.id, user.email);

      const response: ApiResponse = {
        success: true,
        data: tokens,
        message: 'Tokens refreshed successfully',
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

      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          settings: true,
          subscription: true,
        },
      });

      if (!user) {
        throw new AppError('User not found', 404);
      }

      const userResponse = {
        id: user.id,
        email: user.email,
        name: user.name,
        profileImageUrl: user.profileImageUrl,
        height: user.height,
        weight: user.weight,
        trainingMultiplier: user.trainingMultiplier,
        goal: user.goal.toLowerCase(),
        dailyProteinTarget: user.dailyProteinTarget,
        settings: user.settings,
        subscription: user.subscription ? {
          planType: user.subscription.planType.toLowerCase(),
          status: user.subscription.status.toLowerCase(),
          trialEnd: user.subscription.trialEnd,
        } : null,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
      };

      const response: ApiResponse = {
        success: true,
        data: { user: userResponse },
        timestamp: new Date().toISOString(),
      };

      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Google OAuth (placeholder for future implementation)
  static async googleAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { idToken } = req.body;
      
      if (!idToken) {
        throw new AppError('Google ID token is required', 400);
      }

      // TODO: Implement Google OAuth verification
      // For now, return error indicating feature is not implemented
      throw new AppError('Google OAuth not implemented yet', 501);
    } catch (error) {
      next(error);
    }
  }

  // Apple Sign In (placeholder for future implementation)
  static async appleAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { identityToken, user } = req.body;
      
      if (!identityToken) {
        throw new AppError('Apple identity token is required', 400);
      }

      // TODO: Implement Apple Sign In verification
      // For now, return error indicating feature is not implemented
      throw new AppError('Apple Sign In not implemented yet', 501);
    } catch (error) {
      next(error);
    }
  }
}