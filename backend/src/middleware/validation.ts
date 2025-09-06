import { Request, Response, NextFunction } from 'express';
import { body, param, query, validationResult } from 'express-validator';
import { AppError } from './errorHandler';

// Utility function to handle validation results
export const handleValidationErrors = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(error => ({
      field: error.type === 'field' ? error.path : 'unknown',
      message: error.msg,
      value: error.type === 'field' ? error.value : undefined,
    }));
    
    throw new AppError(
      `Validation failed: ${errorMessages.map(err => err.message).join(', ')}`,
      400
    );
  }
  
  next();
};

// User validation rules
export const validateUserRegistration = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one lowercase letter, one uppercase letter, and one number'),
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters'),
  handleValidationErrors,
];

export const validateUserLogin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  handleValidationErrors,
];

export const validateProfileUpdate = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters'),
  body('height')
    .optional()
    .isFloat({ min: 100, max: 250 })
    .withMessage('Height must be between 100 and 250 cm'),
  body('weight')
    .optional()
    .isFloat({ min: 30, max: 300 })
    .withMessage('Weight must be between 30 and 300 kg'),
  body('trainingMultiplier')
    .optional()
    .isFloat({ min: 1.0, max: 3.0 })
    .withMessage('Training multiplier must be between 1.0 and 3.0'),
  body('goal')
    .optional()
    .isIn(['maintain', 'bulk', 'cut'])
    .withMessage('Goal must be one of: maintain, bulk, cut'),
  body('dailyProteinTarget')
    .optional()
    .isFloat({ min: 50, max: 400 })
    .withMessage('Daily protein target must be between 50 and 400 grams'),
  handleValidationErrors,
];

// Food validation rules
export const validateFoodLogging = [
  body('foodName')
    .optional()
    .trim()
    .isLength({ min: 1, max: 200 })
    .withMessage('Food name must be between 1 and 200 characters'),
  body('customName')
    .optional()
    .trim()
    .isLength({ min: 1, max: 200 })
    .withMessage('Custom name must be between 1 and 200 characters'),
  body('portionSize')
    .isFloat({ min: 1, max: 2000 })
    .withMessage('Portion size must be between 1 and 2000 grams'),
  body('proteinContent')
    .isFloat({ min: 0, max: 200 })
    .withMessage('Protein content must be between 0 and 200 grams'),
  body('mealType')
    .isIn(['breakfast', 'lunch', 'dinner', 'snack'])
    .withMessage('Meal type must be one of: breakfast, lunch, dinner, snack'),
  body('calories')
    .optional()
    .isFloat({ min: 0, max: 2000 })
    .withMessage('Calories must be between 0 and 2000'),
  body('isQuickAdd')
    .optional()
    .isBoolean()
    .withMessage('isQuickAdd must be a boolean'),
  handleValidationErrors,
];

export const validateFoodItemUpdate = [
  param('id')
    .isString()
    .notEmpty()
    .withMessage('Food item ID is required'),
  body('portionSize')
    .optional()
    .isFloat({ min: 1, max: 2000 })
    .withMessage('Portion size must be between 1 and 2000 grams'),
  body('proteinContent')
    .optional()
    .isFloat({ min: 0, max: 200 })
    .withMessage('Protein content must be between 0 and 200 grams'),
  body('mealType')
    .optional()
    .isIn(['breakfast', 'lunch', 'dinner', 'snack'])
    .withMessage('Meal type must be one of: breakfast, lunch, dinner, snack'),
  body('calories')
    .optional()
    .isFloat({ min: 0, max: 2000 })
    .withMessage('Calories must be between 0 and 2000'),
  handleValidationErrors,
];

// Progress validation rules
export const validateDateRange = [
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid ISO 8601 date'),
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid ISO 8601 date'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  query('offset')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Offset must be a non-negative integer'),
  handleValidationErrors,
];

// Settings validation rules
export const validateUserSettings = [
  body('notificationsEnabled')
    .optional()
    .isBoolean()
    .withMessage('notificationsEnabled must be a boolean'),
  body('mealReminderTimes')
    .optional()
    .isObject()
    .withMessage('mealReminderTimes must be an object'),
  body('mealReminderTimes.breakfast')
    .optional()
    .matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Breakfast time must be in HH:MM format'),
  body('mealReminderTimes.lunch')
    .optional()
    .matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Lunch time must be in HH:MM format'),
  body('mealReminderTimes.snack')
    .optional()
    .matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Snack time must be in HH:MM format'),
  body('mealReminderTimes.dinner')
    .optional()
    .matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Dinner time must be in HH:MM format'),
  body('doNotDisturbStart')
    .optional()
    .matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Do not disturb start time must be in HH:MM format'),
  body('doNotDisturbEnd')
    .optional()
    .matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Do not disturb end time must be in HH:MM format'),
  body('nightlySummaryEnabled')
    .optional()
    .isBoolean()
    .withMessage('nightlySummaryEnabled must be a boolean'),
  handleValidationErrors,
];

// Token verification validation
export const validateTokenVerification = [
  body('token')
    .isString()
    .notEmpty()
    .withMessage('Token is required'),
  handleValidationErrors,
];

// Generic ID validation
export const validateId = [
  param('id')
    .isString()
    .notEmpty()
    .withMessage('ID parameter is required'),
  handleValidationErrors,
];