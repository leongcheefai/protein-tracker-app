import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { Request, Response } from 'express';

const router = Router();

// All user routes require authentication
router.use(authenticate);

/**
 * @route PUT /api/user/profile
 * @desc Update user profile (Use /api/auth/profile instead)
 * @access Private
 */
router.put('/profile', (req: Request, res: Response) => {
  res.status(301).json({
    success: false,
    message: 'Profile updates moved to /api/auth/profile',
    redirectTo: '/api/auth/profile',
    timestamp: new Date().toISOString()
  });
});

/**
 * @route GET /api/user/settings
 * @desc Get user settings (TODO: Implement with Supabase)
 * @access Private
 */
router.get('/settings', (req: Request, res: Response) => {
  res.status(501).json({
    success: false,
    message: 'User settings feature coming soon',
    timestamp: new Date().toISOString()
  });
});

/**
 * @route PUT /api/user/settings
 * @desc Update user settings (TODO: Implement with Supabase)
 * @access Private
 */
router.put('/settings', (req: Request, res: Response) => {
  res.status(501).json({
    success: false,
    message: 'User settings update feature coming soon',
    timestamp: new Date().toISOString()
  });
});

/**
 * @route GET /api/user/stats
 * @desc Get user statistics summary (TODO: Implement with Supabase)
 * @access Private
 */
router.get('/stats', (req: Request, res: Response) => {
  res.status(501).json({
    success: false,
    message: 'User stats feature coming soon - Phase 5 implementation',
    timestamp: new Date().toISOString()
  });
});

/**
 * @route DELETE /api/user/account
 * @desc Delete user account (Use /api/auth/account instead)
 * @access Private
 */
router.delete('/account', (req: Request, res: Response) => {
  res.status(301).json({
    success: false,
    message: 'Account deletion moved to /api/auth/account',
    redirectTo: '/api/auth/account',
    timestamp: new Date().toISOString()
  });
});

export default router;