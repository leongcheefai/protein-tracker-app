import 'api_service.dart';
import '../models/api_response.dart';
import '../models/dto/meal_dto.dart';

class MealService {
  final ApiService _apiService;

  MealService(this._apiService);

  Future<ApiResponse<List<MealDto>>> getMeals({
    DateTime? date,
    String? mealType,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{
      if (date != null) 'date': date.toIso8601String().split('T')[0],
      if (mealType != null) 'meal_type': mealType,
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
    };

    final response = await _apiService.get<List<dynamic>>(
      '/meals',
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      final meals = response.data!
          .map((m) => MealDto.fromJson(m))
          .toList();
      return ApiResponse.success(meals, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get meals'),
      );
    }
  }

  Future<ApiResponse<MealDto>> createMeal(MealDto meal) async {
    return await _apiService.post<MealDto>(
      '/meals',
      meal.toJson(),
      fromJson: (json) => MealDto.fromJson(json),
    );
  }

  Future<ApiResponse<MealDto>> updateMeal(String mealId, MealDto meal) async {
    return await _apiService.put<MealDto>(
      '/meals/$mealId',
      meal.toJson(),
      fromJson: (json) => MealDto.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteMeal(String mealId) async {
    return await _apiService.delete<void>('/meals/$mealId');
  }

  Future<ApiResponse<NutritionSummaryDto>> getTodaysSummary() async {
    return await _apiService.get<NutritionSummaryDto>(
      '/meals/today/summary',
      fromJson: (json) => NutritionSummaryDto.fromJson(json),
    );
  }

  Future<ApiResponse<NutritionSummaryDto>> getDateSummary(DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];
    return await _apiService.get<NutritionSummaryDto>(
      '/meals/date/$dateString',
      fromJson: (json) => NutritionSummaryDto.fromJson(json),
    );
  }

  Future<ApiResponse<MealDto>> addFoodToMeal(
    String mealId,
    MealFoodDto mealFood,
  ) async {
    return await _apiService.post<MealDto>(
      '/meals/$mealId/foods',
      mealFood.toJson(),
      fromJson: (json) => MealDto.fromJson(json),
    );
  }

  Future<ApiResponse<MealDto>> updateMealFood(
    String mealId,
    String mealFoodId,
    MealFoodDto mealFood,
  ) async {
    return await _apiService.put<MealDto>(
      '/meals/$mealId/foods/$mealFoodId',
      mealFood.toJson(),
      fromJson: (json) => MealDto.fromJson(json),
    );
  }

  Future<ApiResponse<MealDto>> removeFoodFromMeal(
    String mealId,
    String mealFoodId,
  ) async {
    return await _apiService.delete<MealDto>(
      '/meals/$mealId/foods/$mealFoodId',
      fromJson: (json) => MealDto.fromJson(json),
    );
  }

  Future<ApiResponse<List<MealDto>>> bulkCreateMeals(List<MealDto> meals) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/meals/bulk',
      {'meals': meals.map((m) => m.toJson()).toList()},
    );

    if (response.success && response.data != null) {
      final createdMeals = (response.data!['meals'] as List)
          .map((m) => MealDto.fromJson(m))
          .toList();
      return ApiResponse.success(createdMeals, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Bulk meal creation failed'),
      );
    }
  }

  // Helper methods for meal management
  Future<ApiResponse<List<MealDto>>> getMealsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final queryParams = <String, dynamic>{
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
    };

    final response = await _apiService.get<Map<String, dynamic>>(
      '/meals',
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      final meals = (response.data!['meals'] as List)
          .map((m) => MealDto.fromJson(m))
          .toList();
      return ApiResponse.success(meals, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get meals for date range'),
      );
    }
  }

  Future<ApiResponse<Map<String, NutritionSummaryDto>>> getWeeklySummaries(
    DateTime weekStartDate,
  ) async {
    final dateString = weekStartDate.toIso8601String().split('T')[0];
    final response = await _apiService.get<Map<String, dynamic>>(
      '/meals/week/$dateString/summaries',
    );

    if (response.success && response.data != null) {
      final summaries = <String, NutritionSummaryDto>{};
      response.data!['summaries'].forEach((key, value) {
        summaries[key] = NutritionSummaryDto.fromJson(value);
      });
      return ApiResponse.success(summaries, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get weekly summaries'),
      );
    }
  }

  // Quick meal creation from food detection results
  Future<ApiResponse<List<MealDto>>> createMealsFromDetection(
    String detectionId,
    Map<String, MealCreationData> mealAssignments,
  ) async {
    final data = {
      'detection_id': detectionId,
      'meal_assignments': mealAssignments.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };

    final response = await _apiService.post<Map<String, dynamic>>(
      '/meals/from-detection',
      data,
    );

    if (response.success && response.data != null) {
      final meals = (response.data!['meals'] as List)
          .map((m) => MealDto.fromJson(m))
          .toList();
      return ApiResponse.success(meals, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to create meals from detection'),
      );
    }
  }
}

class MealCreationData {
  final String mealType;
  final DateTime timestamp;
  final List<DetectedFoodAssignment> foods;
  final String? notes;

  MealCreationData({
    required this.mealType,
    required this.timestamp,
    required this.foods,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'meal_type': mealType,
      'timestamp': timestamp.toIso8601String(),
      'foods': foods.map((f) => f.toJson()).toList(),
      'notes': notes,
    };
  }
}

class DetectedFoodAssignment {
  final String detectedFoodName;
  final double quantity;
  final String unit;
  final String? matchedFoodId;

  DetectedFoodAssignment({
    required this.detectedFoodName,
    required this.quantity,
    required this.unit,
    this.matchedFoodId,
  });

  Map<String, dynamic> toJson() {
    return {
      'detected_food_name': detectedFoodName,
      'quantity': quantity,
      'unit': unit,
      'matched_food_id': matchedFoodId,
    };
  }
}