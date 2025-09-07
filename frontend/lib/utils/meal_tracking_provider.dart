import 'package:flutter/foundation.dart';
import 'nutrition_service.dart';

class MealTrackingProvider extends ChangeNotifier {
  List<Meal> _meals = [];
  Map<String, dynamic>? _todaysSummary;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Meal> get meals => _meals;
  Map<String, dynamic>? get todaysSummary => _todaysSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Daily totals
  double get todaysTotalProtein => _todaysSummary?['totalProtein']?.toDouble() ?? 0.0;
  double get todaysTotalCalories => _todaysSummary?['totalCalories']?.toDouble() ?? 0.0;
  double get dailyProteinGoal => _todaysSummary?['dailyGoal']?.toDouble() ?? 100.0;
  int get todaysProgress => _todaysSummary?['progress'] ?? 0;

  // Meal breakdown for today
  Map<String, dynamic> get mealSummary => _todaysSummary?['mealSummary'] ?? {
    'breakfast': {'count': 0, 'protein': 0.0, 'target': 25.0},
    'lunch': {'count': 0, 'protein': 0.0, 'target': 25.0},
    'dinner': {'count': 0, 'protein': 0.0, 'target': 25.0},
    'snack': {'count': 0, 'protein': 0.0, 'target': 25.0},
  };

  // Filter meals by type
  List<Meal> getMealsByType(String mealType) {
    return _meals.where((meal) => meal.mealType.toLowerCase() == mealType.toLowerCase()).toList();
  }

  // Get meals for today
  List<Meal> get todaysMeals {
    final today = DateTime.now();
    return _meals.where((meal) {
      return meal.timestamp.year == today.year &&
             meal.timestamp.month == today.month &&
             meal.timestamp.day == today.day;
    }).toList();
  }

  // Get meals for a specific date
  List<Meal> getMealsForDate(DateTime date) {
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
      _todaysSummary = await NutritionService.getTodaysSummary();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load meals with optional filtering
  Future<void> loadMeals({
    String? startDate,
    String? endDate,
    String? mealType,
  }) async {
    _setLoading(true);
    try {
      _meals = await NutritionService.getUserMeals(
        startDate: startDate,
        endDate: endDate,
        mealType: mealType,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create a new meal
  Future<Meal?> createMeal({
    required String mealType,
    DateTime? timestamp,
    String? photoUrl,
    String? notes,
    List<Map<String, dynamic>>? foods,
  }) async {
    _setLoading(true);
    try {
      final meal = await NutritionService.createMeal(
        mealType: mealType,
        timestamp: timestamp,
        photoUrl: photoUrl,
        notes: notes,
        foods: foods,
      );
      
      _meals.insert(0, meal); // Add to beginning of list
      _error = null;
      notifyListeners();
      
      // Refresh today's summary
      loadTodaysSummary();
      
      return meal;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update a meal
  Future<bool> updateMeal(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    try {
      final updatedMeal = await NutritionService.updateMeal(id, updates);
      
      final index = _meals.indexWhere((meal) => meal.id == id);
      if (index != -1) {
        _meals[index] = updatedMeal;
        notifyListeners();
        
        // Refresh today's summary
        loadTodaysSummary();
      }
      
      _error = null;
      return true;
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
      await NutritionService.deleteMeal(id);
      
      _meals.removeWhere((meal) => meal.id == id);
      _error = null;
      notifyListeners();
      
      // Refresh today's summary
      loadTodaysSummary();
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load meals for a specific date
  Future<Map<String, dynamic>?> loadMealsForDate(DateTime date) async {
    _setLoading(true);
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final result = await NutritionService.getMealsByDate(dateString);
      _error = null;
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
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
  Future<Meal?> quickAddMeal({
    required String mealType,
    required String foodName,
    required double proteinContent,
    required double portionSize,
    double? calories,
  }) async {
    // Create a simplified food entry for quick adds
    final nutritionData = NutritionData(
      calories: calories ?? 0,
      protein: proteinContent,
      carbs: 0,
      fat: 0,
      fiber: 0,
      sugar: 0,
      sodium: 0,
    );

    final foods = [
      {
        'food_id': 'quick-add', // Special ID for quick adds
        'quantity': portionSize,
        'unit': 'grams',
        'nutrition_data': nutritionData.toJson(),
        'custom_name': foodName,
      }
    ];

    return await createMeal(
      mealType: mealType,
      foods: foods,
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
      (sum, meal) => sum + meal.nutrition.protein,
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