import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { AnalyticsController } from '../controllers/analyticsController';

const router = Router();

// All analytics routes require authentication
router.use(authenticate);

/**
 * @route GET /api/analytics/overview
 * @desc Get comprehensive analytics overview
 * @query period - Predefined period (7d, 30d, 90d, 1y)
 * @query startDate - Custom start date (YYYY-MM-DD)
 * @query endDate - Custom end date (YYYY-MM-DD)
 * @access Private
 */
router.get('/overview', AnalyticsController.getStatsOverview);

/**
 * @route GET /api/analytics/daily
 * @desc Get daily breakdown for specific date range
 * @query startDate - Start date (required, YYYY-MM-DD)
 * @query endDate - End date (required, YYYY-MM-DD)
 * @access Private
 */
router.get('/daily', AnalyticsController.getDailyBreakdown);

/**
 * @route GET /api/analytics/weekly
 * @desc Get weekly trend analysis
 * @query weeks - Number of weeks to analyze (default: 8)
 * @access Private
 */
router.get('/weekly', AnalyticsController.getWeeklyTrend);

/**
 * @route GET /api/analytics/streaks
 * @desc Get streak information and history
 * @access Private
 */
router.get('/streaks', AnalyticsController.getStreaks);

/**
 * @route GET /api/analytics/insights
 * @desc Get personalized nutrition insights
 * @access Private
 */
router.get('/insights', AnalyticsController.getInsights);

/**
 * @route GET /api/analytics/achievements
 * @desc Get user achievements and badges
 * @access Private
 */
router.get('/achievements', AnalyticsController.getAchievements);

/**
 * @route GET /api/analytics/meal-consistency
 * @desc Get meal consistency analysis
 * @query days - Number of days to analyze (default: 30)
 * @access Private
 */
router.get('/meal-consistency', AnalyticsController.getMealConsistency);

/**
 * @route GET /api/analytics/recommendations
 * @desc Get personalized nutrition recommendations
 * @access Private
 */
router.get('/recommendations', AnalyticsController.getNutritionRecommendations);

/**
 * @route GET /api/analytics/comparative
 * @desc Get comparative analysis (current vs previous period)
 * @query period - Period to compare (7d, 30d, 90d) - default: 30d
 * @access Private
 */
router.get('/comparative', AnalyticsController.getComparative);

/**
 * @route GET /api/analytics/export
 * @desc Export user data in JSON or CSV format
 * @query format - Export format (json, csv) - default: json
 * @query startDate - Optional start date for export range
 * @query endDate - Optional end date for export range
 * @access Private
 */
router.get('/export', AnalyticsController.exportData);

export default router;