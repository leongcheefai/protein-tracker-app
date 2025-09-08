import 'package:flutter/foundation.dart';
import '../services/service_locator.dart';
import '../services/analytics_service.dart';
import '../models/dto/analytics_dto.dart';

class ProgressProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService;
  
  // Analytics data
  DailyStatsDto? _todaysStats;
  WeeklyStatsDto? _weeklyStats;
  MonthlyStatsDto? _monthlyStats;
  List<InsightDto> _insights = [];
  StreakDataDto? _streaks;
  List<BadgeDto> _badges = [];
  
  // Progress data
  List<NutritionTrendData> _nutritionTrends = [];
  List<FoodFrequencyData> _foodFrequency = [];
  GoalProgressData? _goalProgress;
  
  // State management
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  ProgressProvider() : _analyticsService = ServiceLocator().analyticsService;

  // Getters
  DailyStatsDto? get todaysStats => _todaysStats;
  WeeklyStatsDto? get weeklyStats => _weeklyStats;
  MonthlyStatsDto? get monthlyStats => _monthlyStats;
  List<InsightDto> get insights => _insights;
  StreakDataDto? get streaks => _streaks;
  List<BadgeDto> get badges => _badges;
  List<NutritionTrendData> get nutritionTrends => _nutritionTrends;
  List<FoodFrequencyData> get foodFrequency => _foodFrequency;
  GoalProgressData? get goalProgress => _goalProgress;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  
  // Convenience getters
  bool get hasTodaysStats => _todaysStats != null;
  bool get hasWeeklyStats => _weeklyStats != null;
  double get todaysProteinGoal => _todaysStats?.proteinGoal ?? 100.0;
  double get todaysProteinAchievement => _todaysStats?.proteinAchievement ?? 0.0;
  bool get isTodaysGoalMet => _todaysStats?.goalMet ?? false;
  int get currentStreak => _streaks?.currentStreak ?? 0;
  int get longestStreak => _streaks?.longestStreak ?? 0;
  
  // Main data loading methods
  Future<void> loadProgressData() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadTodaysStats(),
        loadWeeklyStats(),
        loadInsights(),
        loadStreaks(),
        loadBadges(),
      ]);
      _lastUpdated = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshStats() async {
    await loadProgressData();
  }

  // Individual data loading methods
  Future<void> loadTodaysStats() async {
    try {
      final response = await _analyticsService.getDailyStats(DateTime.now());
      if (response.success && response.data != null) {
        _todaysStats = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load today\'s stats');
      }
    } catch (e) {
      _error = 'Failed to load today\'s stats: $e';
      notifyListeners();
    }
  }

  Future<void> loadWeeklyStats() async {
    try {
      final response = await _analyticsService.getWeeklyStats();
      if (response.success && response.data != null) {
        _weeklyStats = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load weekly stats');
      }
    } catch (e) {
      _error = 'Failed to load weekly stats: $e';
      notifyListeners();
    }
  }

  Future<void> loadMonthlyStats() async {
    try {
      final response = await _analyticsService.getMonthlyStats();
      if (response.success && response.data != null) {
        _monthlyStats = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load monthly stats');
      }
    } catch (e) {
      _error = 'Failed to load monthly stats: $e';
      notifyListeners();
    }
  }

  Future<void> loadInsights({String? category, int? limit}) async {
    try {
      final response = await _analyticsService.getPersonalizedInsights(
        category: category,
        limit: limit,
      );
      if (response.success && response.data != null) {
        _insights = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load insights');
      }
    } catch (e) {
      _error = 'Failed to load insights: $e';
      notifyListeners();
    }
  }

  Future<void> loadStreaks() async {
    try {
      final response = await _analyticsService.getStreaks();
      if (response.success && response.data != null) {
        _streaks = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load streaks');
      }
    } catch (e) {
      _error = 'Failed to load streaks: $e';
      notifyListeners();
    }
  }

  Future<void> loadBadges({String? category, bool? earnedOnly}) async {
    try {
      final response = await _analyticsService.getBadges(
        category: category,
        earnedOnly: earnedOnly,
      );
      if (response.success && response.data != null) {
        _badges = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load badges');
      }
    } catch (e) {
      _error = 'Failed to load badges: $e';
      notifyListeners();
    }
  }

  Future<void> loadNutritionTrends({
    DateTime? startDate,
    DateTime? endDate,
    String period = 'daily',
  }) async {
    try {
      final response = await _analyticsService.getNutritionTrends(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );
      if (response.success && response.data != null) {
        _nutritionTrends = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load nutrition trends');
      }
    } catch (e) {
      _error = 'Failed to load nutrition trends: $e';
      notifyListeners();
    }
  }

  Future<void> loadFoodFrequency({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final response = await _analyticsService.getFoodFrequency(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      if (response.success && response.data != null) {
        _foodFrequency = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load food frequency');
      }
    } catch (e) {
      _error = 'Failed to load food frequency: $e';
      notifyListeners();
    }
  }

  Future<void> loadGoalProgress({
    String? goalType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _analyticsService.getGoalProgress(
        goalType: goalType,
        startDate: startDate,
        endDate: endDate,
      );
      if (response.success && response.data != null) {
        _goalProgress = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load goal progress');
      }
    } catch (e) {
      _error = 'Failed to load goal progress: $e';
      notifyListeners();
    }
  }

  // Export functionality
  Future<String?> exportData(ExportFormat format) async {
    try {
      final response = await _analyticsService.exportData(format);
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.error?.message ?? 'Failed to export data');
      }
    } catch (e) {
      _error = 'Failed to export data: $e';
      notifyListeners();
      return null;
    }
  }

  // Date-specific loading methods
  Future<void> loadStatsForDate(DateTime date) async {
    try {
      final response = await _analyticsService.getDailyStats(date);
      if (response.success && response.data != null) {
        // Could extend to store historical stats if needed
        if (date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day) {
          _todaysStats = response.data!;
        }
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load stats for date');
      }
    } catch (e) {
      _error = 'Failed to load stats for date: $e';
      notifyListeners();
    }
  }

  Future<void> loadStatsForWeek(DateTime weekStartDate) async {
    try {
      final response = await _analyticsService.getWeeklyStats(
        weekStartDate: weekStartDate,
      );
      if (response.success && response.data != null) {
        _weeklyStats = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load weekly stats');
      }
    } catch (e) {
      _error = 'Failed to load weekly stats: $e';
      notifyListeners();
    }
  }

  Future<void> loadStatsForMonth(DateTime monthDate) async {
    try {
      final response = await _analyticsService.getMonthlyStats(
        monthDate: monthDate,
      );
      if (response.success && response.data != null) {
        _monthlyStats = response.data!;
        notifyListeners();
      } else {
        throw Exception(response.error?.message ?? 'Failed to load monthly stats');
      }
    } catch (e) {
      _error = 'Failed to load monthly stats: $e';
      notifyListeners();
    }
  }

  // Helper methods
  List<InsightDto> getInsightsByCategory(String category) {
    return _insights.where((insight) => insight.category == category).toList();
  }

  List<BadgeDto> getEarnedBadges() {
    return _badges.where((badge) => badge.earned).toList();
  }

  List<BadgeDto> getAvailableBadges() {
    return _badges.where((badge) => !badge.earned).toList();
  }

  double getWeeklyAverage(String metric) {
    if (_weeklyStats == null) return 0.0;
    
    switch (metric.toLowerCase()) {
      case 'protein':
        return _weeklyStats!.averageNutrition.protein;
      case 'calories':
        return _weeklyStats!.averageNutrition.calories;
      case 'carbs':
        return _weeklyStats!.averageNutrition.carbs;
      case 'fat':
        return _weeklyStats!.averageNutrition.fat;
      default:
        return 0.0;
    }
  }

  double getMonthlyAverage(String metric) {
    if (_monthlyStats == null) return 0.0;
    
    switch (metric.toLowerCase()) {
      case 'protein':
        return _monthlyStats!.averageNutrition.protein;
      case 'calories':
        return _monthlyStats!.averageNutrition.calories;
      case 'carbs':
        return _monthlyStats!.averageNutrition.carbs;
      case 'fat':
        return _monthlyStats!.averageNutrition.fat;
      default:
        return 0.0;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Cache management
  bool get needsRefresh {
    if (_lastUpdated == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);
    return difference.inMinutes > 30; // Refresh every 30 minutes
  }

  void clearCache() {
    _todaysStats = null;
    _weeklyStats = null;
    _monthlyStats = null;
    _insights.clear();
    _streaks = null;
    _badges.clear();
    _nutritionTrends.clear();
    _foodFrequency.clear();
    _goalProgress = null;
    _lastUpdated = null;
    _error = null;
    notifyListeners();
  }
}