import { Router } from 'express';
import { AnalyticsController } from '../controllers/analyticsController';
import { authenticate, requirePremium } from '../middleware/auth';

const router = Router();

// All analytics routes require authentication
router.use(authenticate);

/**
 * @route GET /api/analytics/stats
 * @desc Get comprehensive statistics overview
 * @access Private
 */
router.get('/stats', AnalyticsController.getStatsOverview);

/**
 * @route GET /api/analytics/meal-consistency
 * @desc Get meal consistency breakdown
 * @access Private
 */
router.get('/meal-consistency', AnalyticsController.getMealConsistency);

/**
 * @route GET /api/analytics/weekly-trend
 * @desc Get weekly protein intake trend
 * @access Private
 */
router.get('/weekly-trend', AnalyticsController.getWeeklyTrend);

/**
 * @route GET /api/analytics/export
 * @desc Export user data (Premium feature)
 * @access Private (Premium)
 */
router.get('/export', requirePremium, AnalyticsController.exportData);

export default router;