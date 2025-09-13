import 'package:flutter/foundation.dart';
import '../services/service_locator.dart';
import '../services/meal_service.dart';
import '../models/dto/meal_dto.dart';
import '../models/dto/food_dto.dart';
import 'nutrition_service.dart';

class MealTrackingProvider extends ChangeNotifier {
  List<MealDto> _meals = [];
  NutritionSummaryDto? _todaysSummary;
  bool _isLoading = false;
  String? _error;
  
  final MealService _mealService;

  MealTrackingProvider() : _mealService = ServiceLocator().mealService;

  // Getters
  List<MealDto> get meals => _meals;
  NutritionSummaryDto? get todaysSummary => _todaysSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Daily totals
  double get todaysTotalProtein => _todaysSummary?.totalNutrition.protein ?? 0.0;
  double get todaysTotalCalories => _todaysSummary?.totalNutrition.calories ?? 0.0;
  double get dailyProteinGoal => _todaysSummary?.proteinGoal ?? 100.0;
  double get todaysProgress => _todaysSummary?.proteinProgress ?? 0.0;

  // Meal breakdown for today
  Map<String, dynamic> get mealSummary {
    if (_todaysSummary == null) {
      return {
        'breakfast': {'count': 0, 'protein': 0.0, 'target': 25.0},
        'lunch': {'count': 0, 'protein': 0.0, 'target': 25.0},
        'dinner': {'count': 0, 'protein': 0.0, 'target': 25.0},
        'snack': {'count': 0, 'protein': 0.0, 'target': 25.0},
      };
    }
    
    final breakdown = <String, dynamic>{};
    for (final entry in _todaysSummary!.mealBreakdown.entries) {
      breakdown[entry.key] = {
        'count': 1, // Simplified - would need more data from backend
        'protein': entry.value.protein,
        'target': dailyProteinGoal / 4, // Divide by 4 meals equally
      };
    }
    
    // Ensure all meal types exist
    for (final meal in ['breakfast', 'lunch', 'dinner', 'snack']) {
      breakdown.putIfAbsent(meal, () => {
        'count': 0,
        'protein': 0.0,
        'target': dailyProteinGoal / 4,
      });
    }
    
    return breakdown;
  }

  // Filter meals by type
  List<MealDto> getMealsByType(String mealType) {
    return _meals.where((meal) => meal.mealType.toLowerCase() == mealType.toLowerCase()).toList();
  }

  // Get meals for today
  List<MealDto> get todaysMeals {
    final today = DateTime.now();
    return _meals.where((meal) {
      return meal.timestamp.year == today.year &&
            meal.timestamp.month == today.month &&
            meal.timestamp.day == today.day;
    }).toList();
  }

  // Get meals for a specific date
  List<MealDto> getMealsForDate(DateTime date) {
    return _meals.where((meal) {
      return meal.timestamp.year == date.year &&
            meal.timestamp.month == date.month &&
            meal.timestamp.day == date.day;
    }).toList();
  }

  // Load today's summary
  Future<void> loadTodaysSummary() async {
    _setLoading(true);
    try {
      final response = await _mealService.getTodaysSummary();
      if (response.success) {
        // Always set the summary, even if it has default/empty values
        _todaysSummary = response.data;
        _error = null;
      } else {
        // For API errors, create a default summary to prevent null errors
        _todaysSummary = NutritionSummaryDto.fromJson(null);
        _error = response.error?.message ?? 'Failed to load today\'s summary';
      }
      notifyListeners();
    } catch (e) {
      // For unexpected errors, create a default summary to prevent null errors
      _todaysSummary = NutritionSummaryDto.fromJson(null);
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load meals with optional filtering
  Future<void> loadMeals({
    DateTime? date,
    String? mealType,
    int? limit,
    int? offset,
  }) async {
    _setLoading(true);
    try {
      final response = await _mealService.getMeals(
        date: date,
        mealType: mealType,
        limit: limit,
        offset: offset,
      );
      if (response.success && response.data != null) {
        _meals = response.data!;
        _error = null;
      } else {
        _error = response.error?.message ?? 'Failed to load meals';
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create a new meal
  Future<MealDto?> createMeal({
    required String mealType,
    DateTime? timestamp,
    String? photoUrl,
    String? notes,
    List<MealFoodDto>? foods,
  }) async {
    _setLoading(true);
    try {
      // Create a new MealDto instance
      final newMeal = MealDto(
        id: '', // Will be assigned by backend
        userId: '', // Will be assigned by backend
        mealType: mealType,
        timestamp: timestamp ?? DateTime.now(),
        photoUrl: photoUrl,
        notes: notes,
        foods: foods ?? [],
      );

      final response = await _mealService.createMeal(newMeal);
      
      if (response.success && response.data != null) {
        _meals.insert(0, response.data!); // Add to beginning of list
        _error = null;
        notifyListeners();
        
        // Refresh today's summary
        loadTodaysSummary();
        
        return response.data!;
      } else {
        _error = response.error?.message ?? 'Failed to create meal';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update a meal
  Future<bool> updateMeal(String id, MealDto updatedMeal) async {
    _setLoading(true);
    try {
      final response = await _mealService.updateMeal(id, updatedMeal);
      
      if (response.success && response.data != null) {
        final index = _meals.indexWhere((meal) => meal.id == id);
        if (index != -1) {
          _meals[index] = response.data!;
          notifyListeners();
          
          // Refresh today's summary
          loadTodaysSummary();
        }
        
        _error = null;
        return true;
      } else {
        _error = response.error?.message ?? 'Failed to update meal';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a meal
  Future<bool> deleteMeal(String id) async {
    _setLoading(true);
    try {
      final response = await _mealService.deleteMeal(id);
      
      if (response.success) {
        _meals.removeWhere((meal) => meal.id == id);
        _error = null;
        notifyListeners();
        
        // Refresh today's summary
        loadTodaysSummary();
        
        return true;
      } else {
        _error = response.error?.message ?? 'Failed to delete meal';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load meals for a specific date
  Future<NutritionSummaryDto?> loadMealsForDate(DateTime date) async {
    _setLoading(true);
    try {
      final response = await _mealService.getDateSummary(date);
      if (response.success) {
        _error = null;
        return response.data ?? NutritionSummaryDto.fromJson(null);
      } else {
        _error = response.error?.message ?? 'Failed to load meals for date';
        notifyListeners();
        // Return default summary instead of null to prevent downstream null errors
        return NutritionSummaryDto.fromJson(null);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // Return default summary instead of null to prevent downstream null errors
      return NutritionSummaryDto.fromJson(null);
    } finally {
      _setLoading(false);
    }
  }

  // Calculate nutrition for a portion
  NutritionData calculatePortionNutrition(
    NutritionData nutritionPer100g,
    double quantity,
    String unit,
  ) {
    return NutritionService.calculateNutritionForQuantity(
      nutritionPer100g,
      quantity,
      unit,
    );
  }

  // Get progress for a specific meal type
  double getMealProgress(String mealType) {
    final summary = mealSummary[mealType.toLowerCase()];
    if (summary == null) return 0.0;
    
    final current = (summary['protein'] ?? 0.0).toDouble();
    final target = (summary['target'] ?? 1.0).toDouble();
    
    return target > 0 ? (current / target) : 0.0;
  }

  // Get remaining protein for a meal type
  double getRemainingProtein(String mealType) {
    final summary = mealSummary[mealType.toLowerCase()];
    if (summary == null) return 0.0;
    
    final current = (summary['protein'] ?? 0.0).toDouble();
    final target = (summary['target'] ?? 0.0).toDouble();
    
    return (target - current).clamp(0.0, target);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null; // Clear errors when starting new operation
    }
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadTodaysSummary(),
      loadMeals(),
    ]);
  }

  // Quick add meal (simplified creation)
  Future<MealDto?> quickAddMeal({
    required String mealType,
    required String foodName,
    required double proteinContent,
    required double portionSize,
    double? calories,
  }) async {
    // Create a simplified nutrition data for quick adds
    final nutritionData = NutritionDataDto(
      calories: calories ?? 0,
      protein: proteinContent,
      carbs: 0,
      fat: 0,
      fiber: 0,
      sugar: 0,
      sodium: 0,
    );

    // Create a MealFoodDto for the quick add
    final mealFood = MealFoodDto(
      id: '', // Will be assigned by backend
      mealId: '', // Will be assigned by backend
      foodId: 'quick-add', // Special ID for quick adds
      quantity: portionSize,
      unit: 'grams',
      nutritionData: nutritionData,
    );

    return await createMeal(
      mealType: mealType,
      foods: [mealFood],
    );
  }

  // Get weekly average protein
  double getWeeklyAverageProtein() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: 7));
    
    final weekMeals = _meals.where((meal) => 
      meal.timestamp.isAfter(weekStart) && meal.timestamp.isBefore(now)
    ).toList();
    
    if (weekMeals.isEmpty) return 0.0;
    
    final totalProtein = weekMeals.fold<double>(
      0.0,
      (sum, meal) => sum + (meal.totalNutrition?.protein ?? 0.0),
    );
    
    return totalProtein / 7; // Average per day
  }

  // Get streak of days hitting protein goal
  int getProteinStreak() {
    // This would need to be implemented with daily summary data
    // For now, return a placeholder
    return 0;
  }
}