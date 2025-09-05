import { Router } from 'express';
import { UserController } from '../controllers/userController';
import { authenticate } from '../middleware/auth';
import { 
  validateProfileUpdate,
  validateUserSettings 
} from '../middleware/validation';

const router = Router();

// All user routes require authentication
router.use(authenticate);

/**
 * @route PUT /api/user/profile
 * @desc Update user profile
 * @access Private
 */
router.put('/profile', validateProfileUpdate, UserController.updateProfile);

/**
 * @route GET /api/user/settings
 * @desc Get user settings
 * @access Private
 */
router.get('/settings', UserController.getSettings);

/**
 * @route PUT /api/user/settings
 * @desc Update user settings
 * @access Private
 */
router.put('/settings', validateUserSettings, UserController.updateSettings);

/**
 * @route GET /api/user/stats
 * @desc Get user statistics summary
 * @access Private
 */
router.get('/stats', UserController.getStatsSummary);

/**
 * @route DELETE /api/user/account
 * @desc Delete user account
 * @access Private
 */
router.delete('/account', UserController.deleteAccount);

export default router;