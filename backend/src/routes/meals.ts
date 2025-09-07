import { Router } from 'express';
import { MealController } from '../controllers/mealController';
import { authenticate } from '../middleware/auth';
import { 
  validateMealCreation,
  validateMealUpdate,
  validateId 
} from '../middleware/validation';

const router = Router();

// All meal routes require authentication
router.use(authenticate);

/**
 * @route GET /api/meals
 * @desc Get user's meals with optional date filtering
 * @access Private
 */
router.get('/', MealController.getUserMeals);

/**
 * @route GET /api/meals/:id
 * @desc Get a specific meal by ID
 * @access Private
 */
router.get('/:id', validateId, MealController.getMealById);

/**
 * @route POST /api/meals
 * @desc Create a new meal
 * @access Private
 */
router.post('/', validateMealCreation, MealController.createMeal);

/**
 * @route PUT /api/meals/:id
 * @desc Update a meal
 * @access Private
 */
router.put('/:id', validateId, validateMealUpdate, MealController.updateMeal);

/**
 * @route DELETE /api/meals/:id
 * @desc Delete a meal
 * @access Private
 */
router.delete('/:id', validateId, MealController.deleteMeal);

/**
 * @route GET /api/meals/date/:date
 * @desc Get meals for a specific date
 * @access Private
 */
router.get('/date/:date', MealController.getMealsByDate);

/**
 * @route GET /api/meals/today/summary
 * @desc Get today's meal summary with nutrition totals
 * @access Private
 */
router.get('/today/summary', MealController.getTodaysSummary);

export default router;