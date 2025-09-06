import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { supabase, DatabaseService } from '../utils/database';
import { AppError } from './errorHandler';

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    email: string;
    display_name?: string;
  };
}

export interface SupabaseJWTPayload {
  sub: string; // user ID
  email?: string;
  aud: string;
  role: string;
  iat: number;
  exp: number;
}

export class SupabaseAuthService {
  private static get JWT_SECRET(): string {
    const secret = process.env.SUPABASE_JWT_SECRET;
    if (!secret) {
      // Fallback to Supabase anon key for JWT verification
      const anonKey = process.env.SUPABASE_ANON_KEY;
      if (!anonKey) throw new Error('SUPABASE_JWT_SECRET or SUPABASE_ANON_KEY is required');
      return anonKey;
    }
    return secret;
  }

  static async verifySupabaseToken(token: string): Promise<SupabaseJWTPayload> {
    try {
      // Verify the JWT token using Supabase's built-in verification
      const { data: { user }, error } = await supabase.auth.getUser(token);
      
      if (error || !user) {
        throw new AppError('Invalid or expired token', 401);
      }

      return {
        sub: user.id,
        email: user.email,
        aud: 'authenticated',
        role: user.role || 'authenticated',
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + 3600 // 1 hour
      };
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError('Token verification failed', 401);
    }
  }

  static async getUserProfile(userId: string) {
    try {
      return await DatabaseService.getUserProfile(userId);
    } catch (error) {
      return null;
    }
  }
}

// Middleware to authenticate requests using Supabase Auth
export const authenticate = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      throw new AppError('No authorization header provided', 401);
    }

    const token = authHeader.startsWith('Bearer ') 
      ? authHeader.substring(7) 
      : authHeader;

    if (!token) {
      throw new AppError('No token provided', 401);
    }

    // Verify token with Supabase
    const decoded = await SupabaseAuthService.verifySupabaseToken(token);
    
    // Get user profile from database (or create if doesn't exist)
    let userProfile = await SupabaseAuthService.getUserProfile(decoded.sub);
    
    if (!userProfile && decoded.email) {
      // Auto-create user profile if it doesn't exist
      try {
        userProfile = await DatabaseService.createUserProfile({
          id: decoded.sub,
          email: decoded.email,
          display_name: decoded.email.split('@')[0] // Default display name
        });
      } catch (createError) {
        console.error('Failed to create user profile:', createError);
      }
    }

    req.user = {
      id: decoded.sub,
      email: decoded.email || '',
      display_name: userProfile?.display_name || undefined,
    };
    
    next();
  } catch (error) {
    next(error);
  }
};

// Optional authentication middleware (doesn't throw error if no token)
export const optionalAuth = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    
    if (authHeader) {
      const token = authHeader.startsWith('Bearer ') 
        ? authHeader.substring(7) 
        : authHeader;

      if (token) {
        try {
          const decoded = await SupabaseAuthService.verifySupabaseToken(token);
          const userProfile = await SupabaseAuthService.getUserProfile(decoded.sub);

          if (userProfile) {
            req.user = {
              id: decoded.sub,
              email: decoded.email || '',
              display_name: userProfile.display_name || undefined,
            };
          }
        } catch (error) {
          // Ignore auth errors in optional auth
        }
      }
    }
    
    next();
  } catch (error) {
    // For optional auth, we don't pass errors to the error handler
    // Just continue without setting req.user
    next();
  }
};

// Middleware to ensure user is authenticated (simple check)
export const requireAuth = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  if (!req.user) {
    throw new AppError('Authentication required', 401);
  }
  next();
};