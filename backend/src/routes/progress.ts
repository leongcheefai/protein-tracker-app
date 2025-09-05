import { Router } from 'express';
import { ProgressController } from '../controllers/progressController';
import { authenticate } from '../middleware/auth';
import { validateDateRange } from '../middleware/validation';

const router = Router();

// All progress routes require authentication
router.use(authenticate);

/**
 * @route GET /api/progress/daily
 * @desc Get daily progress (defaults to today)
 * @access Private
 */
router.get('/daily', ProgressController.getDailyProgress);

/**
 * @route GET /api/progress/daily/:date
 * @desc Get daily progress for specific date (YYYY-MM-DD)
 * @access Private
 */
router.get('/daily/:date', ProgressController.getDailyProgress);

/**
 * @route GET /api/progress/history
 * @desc Get historical progress data
 * @access Private
 */
router.get('/history', validateDateRange, ProgressController.getHistoryData);

/**
 * @route GET /api/progress/streak
 * @desc Get current and longest streak information
 * @access Private
 */
router.get('/streak', ProgressController.getStreakInfo);

/**
 * @route GET /api/progress/weekly
 * @desc Get weekly summary for the last 7 days
 * @access Private
 */
router.get('/weekly', ProgressController.getWeeklySummary);

export default router;