import { Router } from 'express';
import { AuthController } from '../controllers/authController';
import { authenticate } from '../middleware/auth';
import { 
  validateUserRegistration, 
  validateUserLogin 
} from '../middleware/validation';

const router = Router();

/**
 * @route POST /api/auth/register
 * @desc Register a new user
 * @access Public
 */
router.post('/register', validateUserRegistration, AuthController.register);

/**
 * @route POST /api/auth/login
 * @desc Login user
 * @access Public
 */
router.post('/login', validateUserLogin, AuthController.login);

/**
 * @route POST /api/auth/refresh
 * @desc Refresh access token
 * @access Public
 */
router.post('/refresh', AuthController.refreshToken);

/**
 * @route GET /api/auth/profile
 * @desc Get current user profile
 * @access Private
 */
router.get('/profile', authenticate, AuthController.getProfile);

/**
 * @route POST /api/auth/google
 * @desc Google OAuth authentication
 * @access Public
 */
router.post('/google', AuthController.googleAuth);

/**
 * @route POST /api/auth/apple
 * @desc Apple Sign In authentication
 * @access Public
 */
router.post('/apple', AuthController.appleAuth);

export default router;