import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';

export interface ApiError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export class AppError extends Error implements ApiError {
  statusCode: number;
  isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

export const createError = (message: string, statusCode: number = 500): AppError => {
  return new AppError(message, statusCode);
};

export const errorHandler = (
  err: ApiError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  if (process.env.NODE_ENV === 'development') {
    console.error('Error:', err);
  }

  // Prisma errors
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    switch (err.code) {
      case 'P2002':
        error = createError('Duplicate field value entered', 400);
        break;
      case 'P2014':
        error = createError('Invalid ID provided', 400);
        break;
      case 'P2003':
        error = createError('Invalid input data', 400);
        break;
      case 'P2025':
        error = createError('Record not found', 404);
        break;
      default:
        error = createError('Database error', 400);
    }
  }

  // Prisma validation errors
  if (err instanceof Prisma.PrismaClientValidationError) {
    error = createError('Invalid request data', 400);
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    error = createError('Invalid token', 401);
  }

  if (err.name === 'TokenExpiredError') {
    error = createError('Token expired', 401);
  }

  // Multer errors (file upload)
  if (err.name === 'MulterError') {
    if (err.message.includes('File too large')) {
      error = createError('File size too large', 413);
    } else {
      error = createError('File upload error', 400);
    }
  }

  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === 'development' && {
      stack: err.stack,
      details: err
    }),
    timestamp: new Date().toISOString()
  });
};