import 'package:flutter/foundation.dart';

class UserSettingsProvider with ChangeNotifier {
  // Profile settings
  double _height = 170.0;
  double _weight = 70.0;
  double _trainingMultiplier = 1.8;
  String _goal = 'maintain';
  double _dailyProteinTarget = 126.0; // 70kg * 1.8g/kg

  // Notification settings
  bool _notificationsEnabled = true;
  Map<String, String> _mealReminderTimes = {
    'breakfast': '08:00',
    'lunch': '12:30',
    'snack': '16:00',
    'dinner': '19:00',
  };
  String _doNotDisturbStart = '22:00';
  String _doNotDisturbEnd = '07:00';
  bool _nightlySummaryEnabled = true;

  // Getters
  double get height => _height;
  double get weight => _weight;
  double get trainingMultiplier => _trainingMultiplier;
  String get goal => _goal;
  double get dailyProteinTarget => _dailyProteinTarget;
  
  bool get notificationsEnabled => _notificationsEnabled;
  Map<String, String> get mealReminderTimes => _mealReminderTimes;
  String get doNotDisturbStart => _doNotDisturbStart;
  String get doNotDisturbEnd => _doNotDisturbEnd;
  bool get nightlySummaryEnabled => _nightlySummaryEnabled;

  // Profile update methods
  void updateProfile({
    double? height,
    double? weight,
    double? trainingMultiplier,
    String? goal,
    double? dailyProteinTarget,
  }) {
    if (height != null) _height = height;
    if (weight != null) _weight = weight;
    if (trainingMultiplier != null) _trainingMultiplier = trainingMultiplier;
    if (goal != null) _goal = goal;
    if (dailyProteinTarget != null) _dailyProteinTarget = dailyProteinTarget;
    
    notifyListeners();
  }

  // Notification update methods
  void updateNotificationSettings({
    bool? notificationsEnabled,
    Map<String, String>? mealReminderTimes,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
    bool? nightlySummaryEnabled,
  }) {
    if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled;
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

  // Reset to default values
  void resetToDefaults() {
    _height = 170.0;
    _weight = 70.0;
    _trainingMultiplier = 1.8;
    _goal = 'maintain';
    _dailyProteinTarget = 126.0;
    _notificationsEnabled = true;
    _mealReminderTimes = {
      'breakfast': '08:00',
      'lunch': '12:30',
      'snack': '16:00',
      'dinner': '19:00',
    };
    _doNotDisturbStart = '22:00';
    _doNotDisturbEnd = '07:00';
    _nightlySummaryEnabled = true;
    
    notifyListeners();
  }
}
