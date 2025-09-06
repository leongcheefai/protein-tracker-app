import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { Request, Response } from 'express';

const router = Router();

// All progress routes require authentication
router.use(authenticate);

/**
 * @route GET /api/progress/daily
 * @desc Get daily progress (TODO: Implement with Supabase)
 * @access Private
 */
router.get('/daily', (req: Request, res: Response) => {
  res.status(501).json({
    success: false,
    message: 'Daily progress tracking coming soon - Phase 5 implementation',
    timestamp: new Date().toISOString()
  });
});

/**
 * @route GET /api/progress/daily/:date
 * @desc Get daily progress for specific date (TODO: Implement with Supabase)
 * @access Private
 */
router.get('/daily/:date', (req: Request, res: Response) => {
  res.status(501).json({
    success: false,
    message: 'Daily progress tracking coming soon - Phase 5 implementation',
    timestamp: new Date().toISOString()
  });
});

/**
 * @route GET /api/progress/history
 * @desc Get historical progress data (TODO: Implement with Supabase)
 * @access Private
 */
router.get('/history', (req: Request, res: Response) => {
  res.status(501).json({
    success: false,
    message: 'Progress history coming soon - Phase 5 implementation',
    timestamp: new Date().toISOString()
  });
});

/**
 * @route GET /api/progress/streak
 * @desc Get current and longest streak information (TODO: Implement with Supabase)
 * @access Private
 */
router.get('/streak', (req: Request, res: Response) => {
  res.status(501).json({
    success: false,
    message: 'Streak tracking coming soon - Phase 5 implementation',
    timestamp: new Date().toISOString()
  });
});

/**
 * @route GET /api/progress/weekly
 * @desc Get weekly summary for the last 7 days (TODO: Implement with Supabase)
 * @access Private
 */
router.get('/weekly', (req: Request, res: Response) => {
  res.status(501).json({
    success: false,
    message: 'Weekly progress summary coming soon - Phase 5 implementation',
    timestamp: new Date().toISOString()
  });
});

export default router;