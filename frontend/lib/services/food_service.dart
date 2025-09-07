import 'dart:io';
import 'api_service.dart';
import '../models/api_response.dart';
import '../models/dto/food_dto.dart';

class FoodService {
  final ApiService _apiService;

  FoodService(this._apiService);

  Future<ApiResponse<FoodDetectionResultDto>> detectFoodFromImage(
    File image, {
    Function(int sent, int total)? onProgress,
  }) async {
    return await _apiService.uploadFile<FoodDetectionResultDto>(
      '/food/detect',
      image,
      fromJson: (json) => FoodDetectionResultDto.fromJson(json),
      onSendProgress: onProgress,
    );
  }

  Future<ApiResponse<List<FoodDto>>> searchFoods(
    String query, {
    String? category,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
      if (category != null) 'category': category,
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
    };

    final response = await _apiService.get<Map<String, dynamic>>(
      '/food/search',
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      final foods = (response.data!['foods'] as List)
          .map((f) => FoodDto.fromJson(f))
          .toList();
      return ApiResponse.success(foods, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Search failed'),
      );
    }
  }

  Future<ApiResponse<FoodDto>> createCustomFood(FoodDto food) async {
    return await _apiService.post<FoodDto>(
      '/food/custom',
      food.toJson(),
      fromJson: (json) => FoodDto.fromJson(json),
    );
  }

  Future<ApiResponse<FoodDto>> updateFood(String foodId, FoodDto food) async {
    return await _apiService.put<FoodDto>(
      '/food/$foodId',
      food.toJson(),
      fromJson: (json) => FoodDto.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteFood(String foodId) async {
    return await _apiService.delete<void>('/food/$foodId');
  }

  Future<ApiResponse<List<FoodDto>>> getRecentFoods({
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _apiService.get<Map<String, dynamic>>(
      '/food/recent',
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      final foods = (response.data!['foods'] as List)
          .map((f) => FoodDto.fromJson(f))
          .toList();
      return ApiResponse.success(foods, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get recent foods'),
      );
    }
  }

  Future<ApiResponse<FoodDto>> getFoodDetails(String foodId) async {
    return await _apiService.get<FoodDto>(
      '/food/$foodId',
      fromJson: (json) => FoodDto.fromJson(json),
    );
  }

  Future<ApiResponse<List<FoodDto>>> getFoodsByCategory(String category) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/food/category/$category',
    );

    if (response.success && response.data != null) {
      final foods = (response.data!['foods'] as List)
          .map((f) => FoodDto.fromJson(f))
          .toList();
      return ApiResponse.success(foods, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get foods by category'),
      );
    }
  }

  Future<ApiResponse<List<String>>> getFoodCategories() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/food/categories',
    );

    if (response.success && response.data != null) {
      final categories = List<String>.from(response.data!['categories']);
      return ApiResponse.success(categories, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get food categories'),
      );
    }
  }

  Future<ApiResponse<FoodDto>> getFoodByBarcode(String barcode) async {
    return await _apiService.get<FoodDto>(
      '/food/barcode/$barcode',
      fromJson: (json) => FoodDto.fromJson(json),
    );
  }

  // Helper method to calculate nutrition for a specific quantity
  NutritionDataDto calculateNutritionForQuantity(
    FoodDto food,
    double quantity,
    String unit,
  ) {
    double scaleFactor = 1.0;

    if (unit == 'grams' || unit == 'g') {
      scaleFactor = quantity / 100.0; // nutrition is per 100g
    } else {
      // Check for common portions
      final portion = food.commonPortions?.firstWhere(
        (p) => p.name.toLowerCase() == unit.toLowerCase(),
        orElse: () => PortionDto(name: unit, grams: quantity),
      );
      
      if (portion != null) {
        scaleFactor = portion.grams / 100.0;
      }
    }

    return food.nutritionPer100g.scale(scaleFactor);
  }
}