import 'package:flutter/cupertino.dart';
import '../models/meal_config.dart';

class MealUtils {
  /// Get icon for meal type (backward compatibility)
  /// 
  /// This method is deprecated. Use MealConfig.getIconForMealType() instead.
  @Deprecated('Use MealConfig.getIconForMealType() or MealConfig.getMealTypeById().icon instead')
  static IconData getMealIcon(String mealName) {
    // Try to get from new config system first
    final mealType = MealConfig.getMealTypeByName(mealName);
    if (mealType != null) {
      return mealType.icon;
    }
    
    // Fallback to old behavior for backward compatibility
    switch (mealName) {
      case 'Breakfast':
        return CupertinoIcons.sun_max;
      case 'Lunch':
        return CupertinoIcons.house;
      case 'Dinner':
        return CupertinoIcons.moon;
      case 'Snack':
        return CupertinoIcons.circle;
      default:
        return CupertinoIcons.house;
    }
  }
  
  /// Get icon for meal type using the new config system
  static IconData getMealIconById(String mealId) {
    return MealConfig.getIconForMealType(mealId);
  }
  
  /// Get display name for meal type using the new config system
  static String getMealDisplayName(String mealId) {
    return MealConfig.getDisplayNameForMealType(mealId);
  }
  
  /// Check if a meal type is valid
  static bool isValidMealType(String mealId) {
    return MealConfig.isValidMealId(mealId);
  }
  
  /// Get all available meal types
  static List<MealType> getAllMealTypes() {
    return MealConfig.allMealTypes;
  }
  
  /// Convert legacy meal map to new format
  static List<String> convertLegacyMealsToIds(Map<String, bool> legacyMeals) {
    return legacyMeals.entries
        .where((entry) => entry.value) // Only enabled meals
        .map((entry) => entry.key.toLowerCase())
        .where(MealConfig.isValidMealId) // Only valid IDs
        .toList();
  }
  
  /// Convert new meal IDs to legacy format
  static Map<String, bool> convertMealIdsToLegacy(List<String> mealIds) {
    return {
      'Breakfast': mealIds.contains('breakfast'),
      'Lunch': mealIds.contains('lunch'),
      'Dinner': mealIds.contains('dinner'),
      'Snack': mealIds.contains('snack'),
    };
  }

  static String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
