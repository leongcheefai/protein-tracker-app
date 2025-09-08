import 'package:flutter/foundation.dart';
import '../services/service_locator.dart';
import '../models/dto/user_profile_dto.dart';
import '../services/user_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserService _userService = ServiceLocator().userService;
  
  UserProfileDto? _profile;
  UserSettings? _settings;
  UserGoals? _goals;
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfileDto? get profile => _profile;
  UserSettings? get settings => _settings;
  UserGoals? get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Profile convenience getters
  String? get displayName => _profile?.displayName;
  String? get email => _profile?.email;
  int? get age => _profile?.age;
  double? get weight => _profile?.weight;
  double? get height => _profile?.height;
  double? get dailyProteinGoal => _profile?.dailyProteinGoal;
  String? get activityLevel => _profile?.activityLevel;
  List<String>? get dietaryRestrictions => _profile?.dietaryRestrictions;
  String? get units => _profile?.units;
  bool get notificationsEnabled => _profile?.notificationsEnabled ?? true;
  String? get privacyLevel => _profile?.privacyLevel;

  // Settings convenience getters
  bool get emailNotifications => _settings?.emailNotifications ?? true;
  bool get pushNotifications => _settings?.pushNotifications ?? true;
  bool get shareProgress => _settings?.shareProgress ?? false;
  String get language => _settings?.language ?? 'en';
  String get timeZone => _settings?.timeZone ?? 'UTC';

  // Goals convenience getters
  double get dailyCalorieGoal => _goals?.dailyCalorieGoal ?? 0.0;
  double get dailyCarbGoal => _goals?.dailyCarbGoal ?? 0.0;
  double get dailyFatGoal => _goals?.dailyFatGoal ?? 0.0;
  double get dailyFiberGoal => _goals?.dailyFiberGoal ?? 0.0;
  double get targetWeight => _goals?.targetWeight ?? 0.0;
  String get weightGoalType => _goals?.weightGoalType ?? 'maintain';
  double get weeklyWeightGoal => _goals?.weeklyWeightGoal ?? 0.0;

  // Profile management methods
  Future<bool> loadProfile() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _userService.getProfile();
      
      if (response.success && response.data != null) {
        _profile = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to load profile');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(UserProfileDto updatedProfile) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _userService.updateProfile(updatedProfile);
      
      if (response.success && response.data != null) {
        _profile = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBasicProfile({
    String? displayName,
    int? age,
    double? weight,
    double? height,
    double? dailyProteinGoal,
    String? activityLevel,
    List<String>? dietaryRestrictions,
    String? units,
  }) async {
    if (_profile == null) return false;

    final updatedProfile = _profile!.copyWith(
      displayName: displayName,
      age: age,
      weight: weight,
      height: height,
      dailyProteinGoal: dailyProteinGoal,
      activityLevel: activityLevel,
      dietaryRestrictions: dietaryRestrictions,
      units: units,
    );

    return await updateProfile(updatedProfile);
  }

  // Settings management methods
  Future<bool> loadSettings() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _userService.getSettings();
      
      if (response.success && response.data != null) {
        _settings = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to load settings');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateSettings(UserSettings updatedSettings) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _userService.updateSettings(updatedSettings);
      
      if (response.success && response.data != null) {
        _settings = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to update settings');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    if (_settings == null) {
      await loadSettings();
    }

    final currentSettings = _settings ?? UserSettings(
      notificationsEnabled: true,
      emailNotifications: true,
      pushNotifications: true,
      privacyLevel: 'private',
      shareProgress: false,
      units: 'metric',
      language: 'en',
      timeZone: 'UTC',
    );

    final updatedSettings = currentSettings.copyWith(
      notificationsEnabled: notificationsEnabled,
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
    );

    // Also update profile if notifications enabled changed
    if (notificationsEnabled != null && _profile != null) {
      final updatedProfile = _profile!.copyWith(
        notificationsEnabled: notificationsEnabled,
      );
      await updateProfile(updatedProfile);
    }

    return await updateSettings(updatedSettings);
  }

  Future<bool> updatePrivacySettings({
    String? privacyLevel,
    bool? shareProgress,
  }) async {
    if (_settings == null) {
      await loadSettings();
    }

    final currentSettings = _settings ?? UserSettings(
      notificationsEnabled: true,
      emailNotifications: true,
      pushNotifications: true,
      privacyLevel: 'private',
      shareProgress: false,
      units: 'metric',
      language: 'en',
      timeZone: 'UTC',
    );

    final updatedSettings = currentSettings.copyWith(
      privacyLevel: privacyLevel,
      shareProgress: shareProgress,
    );

    // Also update profile privacy level
    if (privacyLevel != null && _profile != null) {
      final updatedProfile = _profile!.copyWith(
        privacyLevel: privacyLevel,
      );
      await updateProfile(updatedProfile);
    }

    return await updateSettings(updatedSettings);
  }

  // Goals management methods
  Future<bool> loadGoals() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _userService.getGoals();
      
      if (response.success && response.data != null) {
        _goals = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to load goals');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateGoals(UserGoals updatedGoals) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _userService.updateGoals(updatedGoals);
      
      if (response.success && response.data != null) {
        _goals = response.data;
        
        // Also update the daily protein goal in profile for consistency
        if (_profile != null && updatedGoals.dailyProteinGoal != _profile!.dailyProteinGoal) {
          final updatedProfile = _profile!.copyWith(
            dailyProteinGoal: updatedGoals.dailyProteinGoal,
          );
          _profile = updatedProfile;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to update goals');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Comprehensive data loading
  Future<bool> loadAllData() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Load profile, settings, and goals in parallel
      final results = await Future.wait([
        loadProfile(),
        loadSettings(),
        loadGoals(),
      ]);
      
      // Return true if at least profile loaded successfully
      return results[0];
    } finally {
      _setLoading(false);
    }
  }

  // Sync with backend (refresh all data)
  Future<bool> syncWithBackend() async {
    return await loadAllData();
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _userService.deleteAccount();
      
      if (response.success) {
        // Clear all local data
        _profile = null;
        _settings = null;
        _goals = null;
        notifyListeners();
        return true;
      } else {
        _setError(response.error?.message ?? 'Failed to delete account');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  bool get hasCompleteProfile {
    if (_profile == null) return false;
    return _profile!.displayName != null &&
           _profile!.age != null &&
           _profile!.weight != null &&
           _profile!.height != null &&
           _profile!.dailyProteinGoal != null;
  }

  double calculateBMI() {
    if (_profile?.weight == null || _profile?.height == null) return 0.0;
    final heightInMeters = _profile!.height! / 100;
    return _profile!.weight! / (heightInMeters * heightInMeters);
  }

  String getBMICategory() {
    final bmi = calculateBMI();
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Initialize from auth provider (when user logs in)
  void initializeFromAuth(UserProfileDto? userProfile) {
    _profile = userProfile;
    if (userProfile != null) {
      // Load additional data
      loadSettings();
      loadGoals();
    }
    notifyListeners();
  }

  // State management
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearError() {
    _clearError();
  }

  // Clear all data (on logout)
  void clear() {
    _profile = null;
    _settings = null;
    _goals = null;
    _clearError();
    notifyListeners();
  }
}