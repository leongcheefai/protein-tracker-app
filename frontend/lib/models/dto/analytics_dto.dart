import 'food_dto.dart';

class DailyStatsDto {
  final DateTime date;
  final NutritionDataDto nutrition;
  final int mealCount;
  final double proteinGoal;
  final double proteinAchievement;
  final bool goalMet;
  final Map<String, double> mealTypeBreakdown;

  DailyStatsDto({
    required this.date,
    required this.nutrition,
    required this.mealCount,
    required this.proteinGoal,
    required this.proteinAchievement,
    required this.goalMet,
    required this.mealTypeBreakdown,
  });

  factory DailyStatsDto.fromJson(Map<String, dynamic> json) {
    return DailyStatsDto(
      date: DateTime.parse(json['date']),
      nutrition: NutritionDataDto.fromJson(json['nutrition']),
      mealCount: json['meal_count'] ?? 0,
      proteinGoal: json['protein_goal']?.toDouble() ?? 0.0,
      proteinAchievement: json['protein_achievement']?.toDouble() ?? 0.0,
      goalMet: json['goal_met'] ?? false,
      mealTypeBreakdown: json['meal_type_breakdown'] != null
          ? Map<String, double>.from(json['meal_type_breakdown'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'nutrition': nutrition.toJson(),
      'meal_count': mealCount,
      'protein_goal': proteinGoal,
      'protein_achievement': proteinAchievement,
      'goal_met': goalMet,
      'meal_type_breakdown': mealTypeBreakdown,
    };
  }
}

class WeeklyStatsDto {
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final List<DailyStatsDto> dailyStats;
  final NutritionDataDto averageNutrition;
  final double averageProteinAchievement;
  final int goalMetDays;
  final int totalDays;
  final Map<String, double> trends;

  WeeklyStatsDto({
    required this.weekStartDate,
    required this.weekEndDate,
    required this.dailyStats,
    required this.averageNutrition,
    required this.averageProteinAchievement,
    required this.goalMetDays,
    required this.totalDays,
    required this.trends,
  });

  factory WeeklyStatsDto.fromJson(Map<String, dynamic> json) {
    return WeeklyStatsDto(
      weekStartDate: DateTime.parse(json['week_start_date']),
      weekEndDate: DateTime.parse(json['week_end_date']),
      dailyStats: (json['daily_stats'] as List)
          .map((d) => DailyStatsDto.fromJson(d))
          .toList(),
      averageNutrition: NutritionDataDto.fromJson(json['average_nutrition']),
      averageProteinAchievement:
          json['average_protein_achievement']?.toDouble() ?? 0.0,
      goalMetDays: json['goal_met_days'] ?? 0,
      totalDays: json['total_days'] ?? 0,
      trends: json['trends'] != null
          ? Map<String, double>.from(json['trends'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_start_date': weekStartDate.toIso8601String().split('T')[0],
      'week_end_date': weekEndDate.toIso8601String().split('T')[0],
      'daily_stats': dailyStats.map((d) => d.toJson()).toList(),
      'average_nutrition': averageNutrition.toJson(),
      'average_protein_achievement': averageProteinAchievement,
      'goal_met_days': goalMetDays,
      'total_days': totalDays,
      'trends': trends,
    };
  }

  double get successRate => totalDays > 0 ? goalMetDays / totalDays : 0.0;
}

class MonthlyStatsDto {
  final DateTime monthDate;
  final List<WeeklyStatsDto> weeklyStats;
  final NutritionDataDto averageNutrition;
  final double averageProteinAchievement;
  final int goalMetDays;
  final int totalDays;
  final Map<String, double> monthlyTrends;
  final List<String> topFoods;

  MonthlyStatsDto({
    required this.monthDate,
    required this.weeklyStats,
    required this.averageNutrition,
    required this.averageProteinAchievement,
    required this.goalMetDays,
    required this.totalDays,
    required this.monthlyTrends,
    required this.topFoods,
  });

  factory MonthlyStatsDto.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsDto(
      monthDate: DateTime.parse(json['month_date']),
      weeklyStats: (json['weekly_stats'] as List)
          .map((w) => WeeklyStatsDto.fromJson(w))
          .toList(),
      averageNutrition: NutritionDataDto.fromJson(json['average_nutrition']),
      averageProteinAchievement:
          json['average_protein_achievement']?.toDouble() ?? 0.0,
      goalMetDays: json['goal_met_days'] ?? 0,
      totalDays: json['total_days'] ?? 0,
      monthlyTrends: json['monthly_trends'] != null
          ? Map<String, double>.from(json['monthly_trends'])
          : {},
      topFoods: json['top_foods'] != null
          ? List<String>.from(json['top_foods'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month_date': monthDate.toIso8601String().split('T')[0],
      'weekly_stats': weeklyStats.map((w) => w.toJson()).toList(),
      'average_nutrition': averageNutrition.toJson(),
      'average_protein_achievement': averageProteinAchievement,
      'goal_met_days': goalMetDays,
      'total_days': totalDays,
      'monthly_trends': monthlyTrends,
      'top_foods': topFoods,
    };
  }

  double get successRate => totalDays > 0 ? goalMetDays / totalDays : 0.0;
}

class InsightDto {
  final String id;
  final String title;
  final String message;
  final String type;
  final String category;
  final double priority;
  final Map<String, dynamic>? data;
  final DateTime generatedAt;

  InsightDto({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.priority,
    this.data,
    required this.generatedAt,
  });

  factory InsightDto.fromJson(Map<String, dynamic> json) {
    return InsightDto(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      priority: json['priority']?.toDouble() ?? 0.0,
      data: json['data'] as Map<String, dynamic>?,
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'category': category,
      'priority': priority,
      'data': data,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

class StreakDataDto {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastGoalMet;
  final List<StreakMilestoneDto> milestones;
  final Map<String, int> streakTypes;

  StreakDataDto({
    required this.currentStreak,
    required this.longestStreak,
    this.lastGoalMet,
    required this.milestones,
    required this.streakTypes,
  });

  factory StreakDataDto.fromJson(Map<String, dynamic> json) {
    return StreakDataDto(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastGoalMet: json['last_goal_met'] != null
          ? DateTime.parse(json['last_goal_met'])
          : null,
      milestones: json['milestones'] != null
          ? (json['milestones'] as List)
              .map((m) => StreakMilestoneDto.fromJson(m))
              .toList()
          : [],
      streakTypes: json['streak_types'] != null
          ? Map<String, int>.from(json['streak_types'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_goal_met': lastGoalMet?.toIso8601String(),
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'streak_types': streakTypes,
    };
  }
}

class StreakMilestoneDto {
  final int days;
  final String title;
  final String description;
  final bool achieved;
  final DateTime? achievedAt;

  StreakMilestoneDto({
    required this.days,
    required this.title,
    required this.description,
    required this.achieved,
    this.achievedAt,
  });

  factory StreakMilestoneDto.fromJson(Map<String, dynamic> json) {
    return StreakMilestoneDto(
      days: json['days'] ?? 0,
      title: json['title'] as String,
      description: json['description'] as String,
      achieved: json['achieved'] ?? false,
      achievedAt: json['achieved_at'] != null
          ? DateTime.parse(json['achieved_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'title': title,
      'description': description,
      'achieved': achieved,
      'achieved_at': achievedAt?.toIso8601String(),
    };
  }
}

class BadgeDto {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category;
  final bool earned;
  final DateTime? earnedAt;
  final Map<String, dynamic>? criteria;
  final double progress;

  BadgeDto({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.earned,
    this.earnedAt,
    this.criteria,
    required this.progress,
  });

  factory BadgeDto.fromJson(Map<String, dynamic> json) {
    return BadgeDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String,
      category: json['category'] as String,
      earned: json['earned'] ?? false,
      earnedAt: json['earned_at'] != null
          ? DateTime.parse(json['earned_at'])
          : null,
      criteria: json['criteria'] as Map<String, dynamic>?,
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'category': category,
      'earned': earned,
      'earned_at': earnedAt?.toIso8601String(),
      'criteria': criteria,
      'progress': progress,
    };
  }
}