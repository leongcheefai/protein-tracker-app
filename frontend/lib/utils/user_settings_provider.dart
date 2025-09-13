import 'package:flutter/foundation.dart';
import '../services/service_locator.dart';
import '../models/dto/user_profile_dto.dart';
import '../services/user_service.dart';
import '../models/meal_config.dart';

class UserSettingsProvider with ChangeNotifier {
  final UserService _userService = ServiceLocator().userService;
  
  // Profile settings - now synced with backend
  String? _displayName;
  double _height = 170.0;
  double _weight = 70.0;
  int? _age;
  double _trainingMultiplier = 1.8;
  String _goal = 'maintain';
  double _dailyProteinTarget = 126.0; // 70kg * 1.8g/kg
  String _activityLevel = 'moderately_active';
  List<String> _dietaryRestrictions = [];
  String _units = 'metric';

  // Meal preferences - which meal types are enabled for the user
  List<String> _enabledMealTypes = List<String>.from(MealConfig.defaultEnabledMeals);

  // Notification settings - synced with backend
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _privacyLevel = 'private';
  bool _shareProgress = false;
  String _language = 'en';
  String _timeZone = 'UTC';
  
  // Local notification settings (not in backend yet)
  Map<String, String> _mealReminderTimes = {
    'breakfast': '08:00',
    'lunch': '12:30',
    'snack': '16:00',
    'dinner': '19:00',
  };
  String _doNotDisturbStart = '22:00';
  String _doNotDisturbEnd = '07:00';
  bool _nightlySummaryEnabled = true;

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters - Profile
  String? get displayName => _displayName;
  double get height => _height;
  double get weight => _weight;
  int? get age => _age;
  double get trainingMultiplier => _trainingMultiplier;
  String get goal => _goal;
  double get dailyProteinTarget => _dailyProteinTarget;
  String get activityLevel => _activityLevel;
  List<String> get dietaryRestrictions => _dietaryRestrictions;
  String get units => _units;
  
  // Getters - Meal preferences
  List<String> get enabledMealTypes => _enabledMealTypes;
  List<MealType> get enabledMealTypeObjects => MealConfig.getEnabledMealTypes(_enabledMealTypes);
  bool isMealTypeEnabled(String mealTypeId) => _enabledMealTypes.contains(mealTypeId);
  
  // Getters - Settings
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emailNotifications => _emailNotifications;
  bool get pushNotifications => _pushNotifications;
  String get privacyLevel => _privacyLevel;
  bool get shareProgress => _shareProgress;
  String get language => _language;
  String get timeZone => _timeZone;
  
  // Getters - Local settings
  Map<String, String> get mealReminderTimes => _mealReminderTimes;
  String get doNotDisturbStart => _doNotDisturbStart;
  String get doNotDisturbEnd => _doNotDisturbEnd;
  bool get nightlySummaryEnabled => _nightlySummaryEnabled;
  
  // Getters - State
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user profile from backend
  Future<bool> loadUserProfile() async {
    try {
      _setLoading(true);
      final response = await _userService.getProfile();
      
      if (response.success && response.data != null) {
        _updateFromUserProfile(response.data!);
        _clearError();
        return true;
      } else {
        _setError('Failed to load user profile');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile and sync with backend
  Future<bool> updateProfile({
    String? displayName,
    double? height,
    double? weight,
    int? age,
    double? dailyProteinTarget,
    String? activityLevel,
    List<String>? dietaryRestrictions,
    String? units,
  }) async {
    try {
      _setLoading(true);
      
      // Create updated profile DTO
      final updatedProfile = UserProfileDto(
        id: '', // Will be set by backend
        displayName: displayName ?? _displayName,
        height: height ?? _height,
        weight: weight ?? _weight,
        age: age ?? _age,
        dailyProteinGoal: dailyProteinTarget ?? _dailyProteinTarget,
        activityLevel: activityLevel ?? _activityLevel,
        dietaryRestrictions: dietaryRestrictions ?? _dietaryRestrictions,
        units: units ?? _units,
        notificationsEnabled: _notificationsEnabled,
        privacyLevel: _privacyLevel,
      );
      
      final response = await _userService.updateProfile(updatedProfile);
      
      if (response.success && response.data != null) {
        _updateFromUserProfile(response.data!);
        _clearError();
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

  // Update notification settings and sync with backend
  Future<bool> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? privacyLevel,
    bool? shareProgress,
    String? language,
    String? timeZone,
  }) async {
    try {
      _setLoading(true);
      
      final settings = UserSettings(
        notificationsEnabled: notificationsEnabled ?? _notificationsEnabled,
        emailNotifications: emailNotifications ?? _emailNotifications,
        pushNotifications: pushNotifications ?? _pushNotifications,
        privacyLevel: privacyLevel ?? _privacyLevel,
        shareProgress: shareProgress ?? _shareProgress,
        units: _units,
        language: language ?? _language,
        timeZone: timeZone ?? _timeZone,
      );
      
      final response = await _userService.updateSettings(settings);
      
      if (response.success && response.data != null) {
        _updateFromUserSettings(response.data!);
        _clearError();
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

  // Update local notification settings (not synced with backend yet)
  void updateLocalNotificationSettings({
    Map<String, String>? mealReminderTimes,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
    bool? nightlySummaryEnabled,
  }) {
    if (mealReminderTimes != null) _mealReminderTimes = mealReminderTimes;
    if (doNotDisturbStart != null) _doNotDisturbStart = doNotDisturbStart;
    if (doNotDisturbEnd != null) _doNotDisturbEnd = doNotDisturbEnd;
    if (nightlySummaryEnabled != null) _nightlySummaryEnabled = nightlySummaryEnabled;
    
    notifyListeners();
  }

  // Update specific meal reminder time
  void updateMealReminderTime(String meal, String time) {
    _mealReminderTimes[meal] = time;
    notifyListeners();
  }

  // Meal preference management
  void enableMealType(String mealTypeId) {
    if (MealConfig.isValidMealId(mealTypeId) && !_enabledMealTypes.contains(mealTypeId)) {
      _enabledMealTypes.add(mealTypeId);
      notifyListeners();
    }
  }
  
  void disableMealType(String mealTypeId) {
    if (_enabledMealTypes.contains(mealTypeId)) {
      _enabledMealTypes.remove(mealTypeId);
      notifyListeners();
    }
  }
  
  void setEnabledMealTypes(List<String> mealTypeIds) {
    final validIds = mealTypeIds.where(MealConfig.isValidMealId).toList();
    _enabledMealTypes = validIds;
    notifyListeners();
  }
  
  void toggleMealType(String mealTypeId) {
    if (_enabledMealTypes.contains(mealTypeId)) {
      disableMealType(mealTypeId);
    } else {
      enableMealType(mealTypeId);
    }
  }
  
  void resetMealTypesToDefault() {
    _enabledMealTypes = List<String>.from(MealConfig.defaultEnabledMeals);
    notifyListeners();
  }

  // Calculate daily protein target based on current settings
  void recalculateDailyTarget() {
    _dailyProteinTarget = _weight * _trainingMultiplier;
    
    // Apply goal multiplier
    switch (_goal) {
      case 'bulk':
        _dailyProteinTarget *= 1.1; // 10% increase for bulking
        break;
      case 'cut':
        _dailyProteinTarget *= 0.9; // 10% decrease for cutting
        break;
      default: // maintain
        break;
    }
    
    notifyListeners();
  }

  // Helper method to update local state from backend profile
  void _updateFromUserProfile(UserProfileDto profile) {
    _displayName = profile.displayName;
    _height = profile.height ?? _height;
    _weight = profile.weight ?? _weight;
    _age = profile.age;
    _dailyProteinTarget = profile.dailyProteinGoal ?? _dailyProteinTarget;
    _activityLevel = profile.activityLevel ?? _activityLevel;
    _dietaryRestrictions = profile.dietaryRestrictions ?? [];
    _units = profile.units ?? _units;
    _notificationsEnabled = profile.notificationsEnabled;
    _privacyLevel = profile.privacyLevel ?? _privacyLevel;
    
    notifyListeners();
  }

  // Helper method to update local state from backend settings
  void _updateFromUserSettings(UserSettings settings) {
    _notificationsEnabled = settings.notificationsEnabled;
    _emailNotifications = settings.emailNotifications;
    _pushNotifications = settings.pushNotifications;
    _privacyLevel = settings.privacyLevel;
    _shareProgress = settings.shareProgress;
    _units = settings.units;
    _language = settings.language;
    _timeZone = settings.timeZone;
    
    notifyListeners();
  }

  // Loading and error state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Reset to default values (local only, doesn't sync with backend)
  void resetToDefaults() {
    _displayName = null;
    _height = 170.0;
    _weight = 70.0;
    _age = null;
    _trainingMultiplier = 1.8;
    _goal = 'maintain';
    _dailyProteinTarget = 126.0;
    _activityLevel = 'moderately_active';
    _dietaryRestrictions = [];
    _units = 'metric';
    
    // Reset meal preferences
    _enabledMealTypes = List<String>.from(MealConfig.defaultEnabledMeals);
    
    _notificationsEnabled = true;
    _emailNotifications = true;
    _pushNotifications = true;
    _privacyLevel = 'private';
    _shareProgress = false;
    _language = 'en';
    _timeZone = 'UTC';
    
    _mealReminderTimes = {
      'breakfast': '08:00',
      'lunch': '12:30',
      'snack': '16:00',
      'dinner': '19:00',
    };
    _doNotDisturbStart = '22:00';
    _doNotDisturbEnd = '07:00';
    _nightlySummaryEnabled = true;
    
    _clearError();
    notifyListeners();
  }

  // Initialize from authenticated user
  Future<void> initializeFromAuth(UserProfileDto? userProfile) async {
    if (userProfile != null) {
      _updateFromUserProfile(userProfile);
    } else {
      await loadUserProfile();
    }
  }
}
