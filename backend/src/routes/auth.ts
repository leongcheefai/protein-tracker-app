import { Router } from 'express';
import { AuthController } from '../controllers/authController';
import { authenticate } from '../middleware/auth';
import { 
  validateTokenVerification,
  validateProfileUpdate,
  validateId 
} from '../middleware/validation';

const router = Router();

/**
 * @route POST /api/auth/verify
 * @desc Verify Supabase token and ensure user profile exists
 * @access Public
 */
router.post('/verify', validateTokenVerification, AuthController.verifyToken);

/**
 * @route GET /api/auth/profile
 * @desc Get current user profile
 * @access Private
 */
router.get('/profile', authenticate, AuthController.getProfile);

/**
 * @route PUT /api/auth/profile
 * @desc Update user profile
 * @access Private
 */
router.put('/profile', authenticate, validateProfileUpdate, AuthController.updateProfile);

/**
 * @route DELETE /api/auth/account
 * @desc Delete user account
 * @access Private
 */
router.delete('/account', authenticate, AuthController.deleteAccount);

export default router;