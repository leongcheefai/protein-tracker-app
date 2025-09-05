import { Router } from 'express';
import { FoodController } from '../controllers/foodController';
import { authenticate } from '../middleware/auth';
import { uploadFoodImage, handleUploadError } from '../middleware/upload';
import { 
  validateFoodLogging,
  validateFoodItemUpdate,
  validateId 
} from '../middleware/validation';

const router = Router();

// All food routes require authentication
router.use(authenticate);

/**
 * @route POST /api/food/detect
 * @desc Upload image and detect food items
 * @access Private
 */
router.post('/detect', uploadFoodImage, handleUploadError, FoodController.detectFood);

/**
 * @route POST /api/food/log
 * @desc Log a food item (from detection or quick add)
 * @access Private
 */
router.post('/log', validateFoodLogging, FoodController.logFood);

/**
 * @route GET /api/food/recent
 * @desc Get recent food items
 * @access Private
 */
router.get('/recent', FoodController.getRecentFoodItems);

/**
 * @route GET /api/food/search
 * @desc Search food database
 * @access Private
 */
router.get('/search', FoodController.searchFoods);

/**
 * @route PUT /api/food/item/:id
 * @desc Update a food item
 * @access Private
 */
router.put('/item/:id', validateFoodItemUpdate, FoodController.updateFoodItem);

/**
 * @route DELETE /api/food/item/:id
 * @desc Delete a food item
 * @access Private
 */
router.delete('/item/:id', validateId, FoodController.deleteFoodItem);

export default router;