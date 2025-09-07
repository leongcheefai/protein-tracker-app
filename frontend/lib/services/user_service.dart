import 'api_service.dart';
import '../models/api_response.dart';
import '../models/dto/user_profile_dto.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<ApiResponse<UserProfileDto>> getProfile() async {
    return await _apiService.get<UserProfileDto>(
      '/users/profile',
      fromJson: (json) => UserProfileDto.fromJson(json),
    );
  }

  Future<ApiResponse<UserProfileDto>> updateProfile(UserProfileDto profile) async {
    return await _apiService.put<UserProfileDto>(
      '/users/profile',
      profile.toJson(),
      fromJson: (json) => UserProfileDto.fromJson(json),
    );
  }

  Future<ApiResponse<UserSettings>> getSettings() async {
    return await _apiService.get<UserSettings>(
      '/users/settings',
      fromJson: (json) => UserSettings.fromJson(json),
    );
  }

  Future<ApiResponse<UserSettings>> updateSettings(UserSettings settings) async {
    return await _apiService.put<UserSettings>(
      '/users/settings',
      settings.toJson(),
      fromJson: (json) => UserSettings.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteAccount() async {
    return await _apiService.delete<void>('/users/account');
  }

  Future<ApiResponse<UserGoals>> getGoals() async {
    return await _apiService.get<UserGoals>(
      '/users/goals',
      fromJson: (json) => UserGoals.fromJson(json),
    );
  }

  Future<ApiResponse<UserGoals>> updateGoals(UserGoals goals) async {
    return await _apiService.put<UserGoals>(
      '/users/goals',
      goals.toJson(),
      fromJson: (json) => UserGoals.fromJson(json),
    );
  }
}

class UserSettings {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final String privacyLevel;
  final bool shareProgress;
  final String units;
  final String language;
  final String timeZone;

  UserSettings({
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.privacyLevel,
    required this.shareProgress,
    required this.units,
    required this.language,
    required this.timeZone,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notifications_enabled'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      pushNotifications: json['push_notifications'] ?? true,
      privacyLevel: json['privacy_level'] ?? 'private',
      shareProgress: json['share_progress'] ?? false,
      units: json['units'] ?? 'metric',
      language: json['language'] ?? 'en',
      timeZone: json['time_zone'] ?? 'UTC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'privacy_level': privacyLevel,
      'share_progress': shareProgress,
      'units': units,
      'language': language,
      'time_zone': timeZone,
    };
  }

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? privacyLevel,
    bool? shareProgress,
    String? units,
    String? language,
    String? timeZone,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      shareProgress: shareProgress ?? this.shareProgress,
      units: units ?? this.units,
      language: language ?? this.language,
      timeZone: timeZone ?? this.timeZone,
    );
  }
}

class UserGoals {
  final double dailyProteinGoal;
  final double dailyCalorieGoal;
  final double dailyCarbGoal;
  final double dailyFatGoal;
  final double dailyFiberGoal;
  final double targetWeight;
  final String weightGoalType; // 'lose', 'gain', 'maintain'
  final double weeklyWeightGoal;

  UserGoals({
    required this.dailyProteinGoal,
    required this.dailyCalorieGoal,
    required this.dailyCarbGoal,
    required this.dailyFatGoal,
    required this.dailyFiberGoal,
    required this.targetWeight,
    required this.weightGoalType,
    required this.weeklyWeightGoal,
  });

  factory UserGoals.fromJson(Map<String, dynamic> json) {
    return UserGoals(
      dailyProteinGoal: json['daily_protein_goal']?.toDouble() ?? 0.0,
      dailyCalorieGoal: json['daily_calorie_goal']?.toDouble() ?? 0.0,
      dailyCarbGoal: json['daily_carb_goal']?.toDouble() ?? 0.0,
      dailyFatGoal: json['daily_fat_goal']?.toDouble() ?? 0.0,
      dailyFiberGoal: json['daily_fiber_goal']?.toDouble() ?? 0.0,
      targetWeight: json['target_weight']?.toDouble() ?? 0.0,
      weightGoalType: json['weight_goal_type'] ?? 'maintain',
      weeklyWeightGoal: json['weekly_weight_goal']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_protein_goal': dailyProteinGoal,
      'daily_calorie_goal': dailyCalorieGoal,
      'daily_carb_goal': dailyCarbGoal,
      'daily_fat_goal': dailyFatGoal,
      'daily_fiber_goal': dailyFiberGoal,
      'target_weight': targetWeight,
      'weight_goal_type': weightGoalType,
      'weekly_weight_goal': weeklyWeightGoal,
    };
  }

  UserGoals copyWith({
    double? dailyProteinGoal,
    double? dailyCalorieGoal,
    double? dailyCarbGoal,
    double? dailyFatGoal,
    double? dailyFiberGoal,
    double? targetWeight,
    String? weightGoalType,
    double? weeklyWeightGoal,
  }) {
    return UserGoals(
      dailyProteinGoal: dailyProteinGoal ?? this.dailyProteinGoal,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyCarbGoal: dailyCarbGoal ?? this.dailyCarbGoal,
      dailyFatGoal: dailyFatGoal ?? this.dailyFatGoal,
      dailyFiberGoal: dailyFiberGoal ?? this.dailyFiberGoal,
      targetWeight: targetWeight ?? this.targetWeight,
      weightGoalType: weightGoalType ?? this.weightGoalType,
      weeklyWeightGoal: weeklyWeightGoal ?? this.weeklyWeightGoal,
    );
  }
}