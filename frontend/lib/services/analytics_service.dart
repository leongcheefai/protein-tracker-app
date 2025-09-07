import 'api_service.dart';
import '../models/api_response.dart';
import '../models/dto/analytics_dto.dart';

class AnalyticsService {
  final ApiService _apiService;

  AnalyticsService(this._apiService);

  Future<ApiResponse<DailyStatsDto>> getDailyStats(DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];
    return await _apiService.get<DailyStatsDto>(
      '/analytics/daily/$dateString',
      fromJson: (json) => DailyStatsDto.fromJson(json),
    );
  }

  Future<ApiResponse<WeeklyStatsDto>> getWeeklyStats({
    DateTime? weekStartDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (weekStartDate != null) {
      queryParams['week_start'] = weekStartDate.toIso8601String().split('T')[0];
    }

    return await _apiService.get<WeeklyStatsDto>(
      '/analytics/weekly',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) => WeeklyStatsDto.fromJson(json),
    );
  }

  Future<ApiResponse<MonthlyStatsDto>> getMonthlyStats({
    DateTime? monthDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (monthDate != null) {
      queryParams['month'] = monthDate.toIso8601String().split('T')[0];
    }

    return await _apiService.get<MonthlyStatsDto>(
      '/analytics/monthly',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) => MonthlyStatsDto.fromJson(json),
    );
  }

  Future<ApiResponse<List<InsightDto>>> getPersonalizedInsights({
    String? category,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{
      if (category != null) 'category': category,
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _apiService.get<Map<String, dynamic>>(
      '/analytics/insights',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.success && response.data != null) {
      final insights = (response.data!['insights'] as List)
          .map((i) => InsightDto.fromJson(i))
          .toList();
      return ApiResponse.success(insights, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get insights'),
      );
    }
  }

  Future<ApiResponse<StreakDataDto>> getStreaks() async {
    return await _apiService.get<StreakDataDto>(
      '/analytics/streaks',
      fromJson: (json) => StreakDataDto.fromJson(json),
    );
  }

  Future<ApiResponse<List<BadgeDto>>> getBadges({
    String? category,
    bool? earnedOnly,
  }) async {
    final queryParams = <String, dynamic>{
      if (category != null) 'category': category,
      if (earnedOnly != null) 'earned_only': earnedOnly.toString(),
    };

    final response = await _apiService.get<Map<String, dynamic>>(
      '/analytics/badges',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.success && response.data != null) {
      final badges = (response.data!['badges'] as List)
          .map((b) => BadgeDto.fromJson(b))
          .toList();
      return ApiResponse.success(badges, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get badges'),
      );
    }
  }

  Future<ApiResponse<String>> exportData(ExportFormat format) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/analytics/export',
      queryParameters: {'format': format.toString().split('.').last},
    );

    if (response.success && response.data != null) {
      final downloadUrl = response.data!['download_url'] as String;
      return ApiResponse.success(downloadUrl, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to export data'),
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getProgressReport({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? metrics,
  }) async {
    final queryParams = <String, dynamic>{
      if (startDate != null) 
        'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 
        'end_date': endDate.toIso8601String().split('T')[0],
      if (metrics != null && metrics.isNotEmpty) 
        'metrics': metrics.join(','),
    };

    return await _apiService.get<Map<String, dynamic>>(
      '/analytics/progress-report',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  Future<ApiResponse<List<NutritionTrendData>>> getNutritionTrends({
    DateTime? startDate,
    DateTime? endDate,
    String period = 'daily', // daily, weekly, monthly
  }) async {
    final queryParams = <String, dynamic>{
      'period': period,
      if (startDate != null) 
        'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 
        'end_date': endDate.toIso8601String().split('T')[0],
    };

    final response = await _apiService.get<Map<String, dynamic>>(
      '/analytics/trends',
      queryParameters: queryParams,
    );

    if (response.success && response.data != null) {
      final trends = (response.data!['trends'] as List)
          .map((t) => NutritionTrendData.fromJson(t))
          .toList();
      return ApiResponse.success(trends, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get nutrition trends'),
      );
    }
  }

  Future<ApiResponse<List<FoodFrequencyData>>> getFoodFrequency({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{
      if (startDate != null) 
        'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 
        'end_date': endDate.toIso8601String().split('T')[0],
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _apiService.get<Map<String, dynamic>>(
      '/analytics/food-frequency',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.success && response.data != null) {
      final frequencies = (response.data!['foods'] as List)
          .map((f) => FoodFrequencyData.fromJson(f))
          .toList();
      return ApiResponse.success(frequencies, message: response.message);
    } else {
      return ApiResponse.error(
        response.error ?? ApiError.server('Failed to get food frequency data'),
      );
    }
  }

  Future<ApiResponse<GoalProgressData>> getGoalProgress({
    String? goalType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      if (goalType != null) 'goal_type': goalType,
      if (startDate != null) 
        'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 
        'end_date': endDate.toIso8601String().split('T')[0],
    };

    return await _apiService.get<GoalProgressData>(
      '/analytics/goal-progress',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) => GoalProgressData.fromJson(json),
    );
  }
}

enum ExportFormat {
  csv,
  json,
  pdf,
}

class NutritionTrendData {
  final DateTime date;
  final String period;
  final Map<String, double> values;
  final Map<String, double> averages;

  NutritionTrendData({
    required this.date,
    required this.period,
    required this.values,
    required this.averages,
  });

  factory NutritionTrendData.fromJson(Map<String, dynamic> json) {
    return NutritionTrendData(
      date: DateTime.parse(json['date']),
      period: json['period'] as String,
      values: Map<String, double>.from(json['values']),
      averages: Map<String, double>.from(json['averages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'period': period,
      'values': values,
      'averages': averages,
    };
  }
}

class FoodFrequencyData {
  final String foodId;
  final String foodName;
  final String? category;
  final int count;
  final double frequency;
  final double totalQuantity;
  final String unit;

  FoodFrequencyData({
    required this.foodId,
    required this.foodName,
    this.category,
    required this.count,
    required this.frequency,
    required this.totalQuantity,
    required this.unit,
  });

  factory FoodFrequencyData.fromJson(Map<String, dynamic> json) {
    return FoodFrequencyData(
      foodId: json['food_id'] as String,
      foodName: json['food_name'] as String,
      category: json['category'] as String?,
      count: json['count'] ?? 0,
      frequency: json['frequency']?.toDouble() ?? 0.0,
      totalQuantity: json['total_quantity']?.toDouble() ?? 0.0,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'category': category,
      'count': count,
      'frequency': frequency,
      'total_quantity': totalQuantity,
      'unit': unit,
    };
  }
}

class GoalProgressData {
  final String goalType;
  final double currentValue;
  final double targetValue;
  final double progress;
  final bool achieved;
  final DateTime? achievedAt;
  final List<ProgressDataPoint> history;

  GoalProgressData({
    required this.goalType,
    required this.currentValue,
    required this.targetValue,
    required this.progress,
    required this.achieved,
    this.achievedAt,
    required this.history,
  });

  factory GoalProgressData.fromJson(Map<String, dynamic> json) {
    return GoalProgressData(
      goalType: json['goal_type'] as String,
      currentValue: json['current_value']?.toDouble() ?? 0.0,
      targetValue: json['target_value']?.toDouble() ?? 0.0,
      progress: json['progress']?.toDouble() ?? 0.0,
      achieved: json['achieved'] ?? false,
      achievedAt: json['achieved_at'] != null
          ? DateTime.parse(json['achieved_at'])
          : null,
      history: (json['history'] as List)
          .map((h) => ProgressDataPoint.fromJson(h))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goal_type': goalType,
      'current_value': currentValue,
      'target_value': targetValue,
      'progress': progress,
      'achieved': achieved,
      'achieved_at': achievedAt?.toIso8601String(),
      'history': history.map((h) => h.toJson()).toList(),
    };
  }
}

class ProgressDataPoint {
  final DateTime date;
  final double value;
  final double progress;

  ProgressDataPoint({
    required this.date,
    required this.value,
    required this.progress,
  });

  factory ProgressDataPoint.fromJson(Map<String, dynamic> json) {
    return ProgressDataPoint(
      date: DateTime.parse(json['date']),
      value: json['value']?.toDouble() ?? 0.0,
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'value': value,
      'progress': progress,
    };
  }
}