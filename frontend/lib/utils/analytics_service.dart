import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class DailyStats {
  final String date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final bool goalMet;
  final int mealsCount;
  final MealBreakdown mealBreakdown;

  DailyStats({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.goalMet,
    required this.mealsCount,
    required this.mealBreakdown,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] ?? '',
      totalCalories: (json['totalCalories'] ?? 0.0).toDouble(),
      totalProtein: (json['totalProtein'] ?? 0.0).toDouble(),
      totalCarbs: (json['totalCarbs'] ?? 0.0).toDouble(),
      totalFat: (json['totalFat'] ?? 0.0).toDouble(),
      totalFiber: (json['totalFiber'] ?? 0.0).toDouble(),
      goalMet: json['goalMet'] ?? false,
      mealsCount: json['mealsCount'] ?? 0,
      mealBreakdown: MealBreakdown.fromJson(json['mealBreakdown'] ?? {}),
    );
  }
}

class MealBreakdown {
  final MealData breakfast;
  final MealData lunch;
  final MealData dinner;
  final MealData snack;

  MealBreakdown({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
  });

  factory MealBreakdown.fromJson(Map<String, dynamic> json) {
    return MealBreakdown(
      breakfast: MealData.fromJson(json['breakfast'] ?? {}),
      lunch: MealData.fromJson(json['lunch'] ?? {}),
      dinner: MealData.fromJson(json['dinner'] ?? {}),
      snack: MealData.fromJson(json['snack'] ?? {}),
    );
  }
}

class MealData {
  final double protein;
  final double calories;
  final int count;

  MealData({
    required this.protein,
    required this.calories,
    required this.count,
  });

  factory MealData.fromJson(Map<String, dynamic> json) {
    return MealData(
      protein: (json['protein'] ?? 0.0).toDouble(),
      calories: (json['calories'] ?? 0.0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class WeeklyStats {
  final String weekStart;
  final String weekEnd;
  final AverageDaily averageDaily;
  final int daysWithGoalMet;
  final int totalDaysTracked;
  final int goalHitPercentage;
  final String trend;

  WeeklyStats({
    required this.weekStart,
    required this.weekEnd,
    required this.averageDaily,
    required this.daysWithGoalMet,
    required this.totalDaysTracked,
    required this.goalHitPercentage,
    required this.trend,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      weekStart: json['weekStart'] ?? '',
      weekEnd: json['weekEnd'] ?? '',
      averageDaily: AverageDaily.fromJson(json['averageDaily'] ?? {}),
      daysWithGoalMet: json['daysWithGoalMet'] ?? 0,
      totalDaysTracked: json['totalDaysTracked'] ?? 0,
      goalHitPercentage: json['goalHitPercentage'] ?? 0,
      trend: json['trend'] ?? 'stable',
    );
  }
}

class AverageDaily {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  AverageDaily({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory AverageDaily.fromJson(Map<String, dynamic> json) {
    return AverageDaily(
      calories: (json['calories'] ?? 0.0).toDouble(),
      protein: (json['protein'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
    );
  }
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final String? lastStreakDate;
  final List<StreakHistory> streakHistory;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastStreakDate,
    required this.streakHistory,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastStreakDate: json['lastStreakDate'],
      streakHistory: (json['streakHistory'] as List<dynamic>? ?? [])
          .map((e) => StreakHistory.fromJson(e))
          .toList(),
    );
  }
}

class StreakHistory {
  final String startDate;
  final String endDate;
  final int length;

  StreakHistory({
    required this.startDate,
    required this.endDate,
    required this.length,
  });

  factory StreakHistory.fromJson(Map<String, dynamic> json) {
    return StreakHistory(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      length: json['length'] ?? 0,
    );
  }
}

class NutritionInsight {
  final String type;
  final String title;
  final String description;
  final Map<String, dynamic>? data;
  final String priority;
  final bool actionable;

  NutritionInsight({
    required this.type,
    required this.title,
    required this.description,
    this.data,
    required this.priority,
    required this.actionable,
  });

  factory NutritionInsight.fromJson(Map<String, dynamic> json) {
    return NutritionInsight(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      data: json['data'],
      priority: json['priority'] ?? 'low',
      actionable: json['actionable'] ?? false,
    );
  }

  Color get priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFFFF3B30); // Red
      case 'medium':
        return const Color(0xFFFF9500); // Orange
      default:
        return const Color(0xFF007AFF); // Blue
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'achievement':
        return Icons.emoji_events;
      case 'recommendation':
        return Icons.lightbulb_outline;
      case 'warning':
        return Icons.warning_outlined;
      case 'pattern':
        return Icons.trending_up;
      default:
        return Icons.info_outline;
    }
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String dateEarned;
  final String category;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.dateEarned,
    required this.category,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dateEarned: json['dateEarned'] ?? '',
      category: json['category'] ?? '',
    );
  }

  IconData get categoryIcon {
    switch (category) {
      case 'streak':
        return Icons.local_fire_department;
      case 'goal':
        return Icons.flag;
      case 'consistency':
        return Icons.schedule;
      case 'milestone':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'streak':
        return const Color(0xFFFF6B35);
      case 'goal':
        return const Color(0xFF32D74B);
      case 'consistency':
        return const Color(0xFF5AC8FA);
      case 'milestone':
        return const Color(0xFFFFD60A);
      default:
        return const Color(0xFF007AFF);
    }
  }
}

class MealTimingAnalysis {
  final Map<String, String?> averageMealTimes;
  final Map<String, int> mealConsistency;
  final List<TimingSuggestion> optimalTimingSuggestions;

  MealTimingAnalysis({
    required this.averageMealTimes,
    required this.mealConsistency,
    required this.optimalTimingSuggestions,
  });

  factory MealTimingAnalysis.fromJson(Map<String, dynamic> json) {
    return MealTimingAnalysis(
      averageMealTimes: Map<String, String?>.from(json['averageMealTimes'] ?? {}),
      mealConsistency: Map<String, int>.from(json['mealConsistency'] ?? {}),
      optimalTimingSuggestions: (json['optimalTimingSuggestions'] as List<dynamic>? ?? [])
          .map((e) => TimingSuggestion.fromJson(e))
          .toList(),
    );
  }
}

class TimingSuggestion {
  final String meal;
  final String suggestedTime;
  final String reason;

  TimingSuggestion({
    required this.meal,
    required this.suggestedTime,
    required this.reason,
  });

  factory TimingSuggestion.fromJson(Map<String, dynamic> json) {
    return TimingSuggestion(
      meal: json['meal'] ?? '',
      suggestedTime: json['suggestedTime'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class AnalyticsOverview {
  final String period;
  final List<DailyStats> dailyStats;
  final List<WeeklyStats> weeklyStats;
  final StreakData streakData;
  final MealTimingAnalysis mealTimingAnalysis;
  final List<NutritionInsight> insights;
  final List<Achievement> achievements;

  AnalyticsOverview({
    required this.period,
    required this.dailyStats,
    required this.weeklyStats,
    required this.streakData,
    required this.mealTimingAnalysis,
    required this.insights,
    required this.achievements,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      period: json['period'] ?? '',
      dailyStats: (json['dailyStats'] as List<dynamic>? ?? [])
          .map((e) => DailyStats.fromJson(e))
          .toList(),
      weeklyStats: (json['weeklyStats'] as List<dynamic>? ?? [])
          .map((e) => WeeklyStats.fromJson(e))
          .toList(),
      streakData: StreakData.fromJson(json['streakData'] ?? {}),
      mealTimingAnalysis: MealTimingAnalysis.fromJson(json['mealTimingAnalysis'] ?? {}),
      insights: (json['insights'] as List<dynamic>? ?? [])
          .map((e) => NutritionInsight.fromJson(e))
          .toList(),
      achievements: (json['achievements'] as List<dynamic>? ?? [])
          .map((e) => Achievement.fromJson(e))
          .toList(),
    );
  }
}

class ComparativeAnalysis {
  final PeriodData current;
  final PeriodData previous;
  final ChangeData changes;

  ComparativeAnalysis({
    required this.current,
    required this.previous,
    required this.changes,
  });

  factory ComparativeAnalysis.fromJson(Map<String, dynamic> json) {
    return ComparativeAnalysis(
      current: PeriodData.fromJson(json['current'] ?? {}),
      previous: PeriodData.fromJson(json['previous'] ?? {}),
      changes: ChangeData.fromJson(json['changes'] ?? {}),
    );
  }
}

class PeriodData {
  final String period;
  final double averageProtein;
  final int daysWithGoalMet;
  final int totalDays;
  final int? streak;

  PeriodData({
    required this.period,
    required this.averageProtein,
    required this.daysWithGoalMet,
    required this.totalDays,
    this.streak,
  });

  factory PeriodData.fromJson(Map<String, dynamic> json) {
    return PeriodData(
      period: json['period'] ?? '',
      averageProtein: (json['averageProtein'] ?? 0.0).toDouble(),
      daysWithGoalMet: json['daysWithGoalMet'] ?? 0,
      totalDays: json['totalDays'] ?? 0,
      streak: json['streak'],
    );
  }
}

class ChangeData {
  final double proteinChange;
  final double goalMetChange;
  final String trend;

  ChangeData({
    required this.proteinChange,
    required this.goalMetChange,
    required this.trend,
  });

  factory ChangeData.fromJson(Map<String, dynamic> json) {
    return ChangeData(
      proteinChange: (json['proteinChange'] ?? 0.0).toDouble(),
      goalMetChange: (json['goalMetChange'] ?? 0.0).toDouble(),
      trend: json['trend'] ?? 'stable',
    );
  }

  Color get trendColor {
    switch (trend) {
      case 'improving':
        return const Color(0xFF32D74B);
      case 'declining':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  IconData get trendIcon {
    switch (trend) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
}

class AnalyticsService {
  static String get baseUrl => '${ApiService.baseUrl}/analytics';
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  /// Get comprehensive analytics overview
  static Future<AnalyticsOverview> getOverview({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (period != null) queryParams['period'] = period;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('$baseUrl/overview').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return AnalyticsOverview.fromJson(data['data']);
      }
    }
    
    throw Exception('Failed to load analytics overview');
  }

  /// Get daily breakdown
  static Future<List<DailyStats>> getDailyBreakdown({
    required String startDate,
    required String endDate,
  }) async {
    final uri = Uri.parse('$baseUrl/daily').replace(queryParameters: {
      'startDate': startDate,
      'endDate': endDate,
    });
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>)
            .map((e) => DailyStats.fromJson(e))
            .toList();
      }
    }
    
    throw Exception('Failed to load daily breakdown');
  }

  /// Get weekly trends
  static Future<List<WeeklyStats>> getWeeklyTrend({int weeks = 8}) async {
    final uri = Uri.parse('$baseUrl/weekly').replace(queryParameters: {
      'weeks': weeks.toString(),
    });
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>)
            .map((e) => WeeklyStats.fromJson(e))
            .toList();
      }
    }
    
    throw Exception('Failed to load weekly trends');
  }

  /// Get streak data
  static Future<StreakData> getStreaks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/streaks'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return StreakData.fromJson(data['data']);
      }
    }
    
    throw Exception('Failed to load streak data');
  }

  /// Get personalized insights
  static Future<List<NutritionInsight>> getInsights() async {
    final response = await http.get(
      Uri.parse('$baseUrl/insights'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>)
            .map((e) => NutritionInsight.fromJson(e))
            .toList();
      }
    }
    
    throw Exception('Failed to load insights');
  }

  /// Get achievements
  static Future<List<Achievement>> getAchievements() async {
    final response = await http.get(
      Uri.parse('$baseUrl/achievements'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>)
            .map((e) => Achievement.fromJson(e))
            .toList();
      }
    }
    
    throw Exception('Failed to load achievements');
  }

  /// Get meal consistency analysis
  static Future<MealTimingAnalysis> getMealConsistency({int days = 30}) async {
    final uri = Uri.parse('$baseUrl/meal-consistency').replace(queryParameters: {
      'days': days.toString(),
    });
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return MealTimingAnalysis.fromJson(data['data']);
      }
    }
    
    throw Exception('Failed to load meal consistency');
  }

  /// Get nutrition recommendations
  static Future<List<NutritionInsight>> getRecommendations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>)
            .map((e) => NutritionInsight.fromJson(e))
            .toList();
      }
    }
    
    throw Exception('Failed to load recommendations');
  }

  /// Get comparative analysis
  static Future<ComparativeAnalysis> getComparative({String period = '30d'}) async {
    final uri = Uri.parse('$baseUrl/comparative').replace(queryParameters: {
      'period': period,
    });
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return ComparativeAnalysis.fromJson(data['data']);
      }
    }
    
    throw Exception('Failed to load comparative analysis');
  }

  /// Export data
  static Future<String> exportData({
    String format = 'json',
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{'format': format};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('$baseUrl/export').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return response.body;
    }
    
    throw Exception('Failed to export data');
  }
}