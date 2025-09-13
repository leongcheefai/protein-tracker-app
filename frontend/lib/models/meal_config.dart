import 'package:flutter/cupertino.dart';

/// Represents a meal type with its display configuration
class MealType {
  final String id;
  final String displayName;
  final IconData icon;
  final String defaultReminderTime;
  final int sortOrder;

  const MealType({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.defaultReminderTime,
    required this.sortOrder,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealType &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MealType($id)';

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'defaultReminderTime': defaultReminderTime,
    'sortOrder': sortOrder,
  };

  /// Create from JSON
  static MealType fromJson(Map<String, dynamic> json, IconData defaultIcon) => MealType(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    icon: defaultIcon, // Icons can't be serialized easily, use default mapping
    defaultReminderTime: json['defaultReminderTime'] as String,
    sortOrder: json['sortOrder'] as int,
  );
}

/// Central configuration for all meal types and settings
class MealConfig {
  /// All available meal types in the application
  static const List<MealType> allMealTypes = [
    MealType(
      id: 'breakfast',
      displayName: 'Breakfast',
      icon: CupertinoIcons.sun_max,
      defaultReminderTime: '08:00',
      sortOrder: 1,
    ),
    MealType(
      id: 'lunch',
      displayName: 'Lunch',
      icon: CupertinoIcons.house,
      defaultReminderTime: '12:30',
      sortOrder: 2,
    ),
    MealType(
      id: 'dinner',
      displayName: 'Dinner',
      icon: CupertinoIcons.moon,
      defaultReminderTime: '19:00',
      sortOrder: 3,
    ),
    MealType(
      id: 'snack',
      displayName: 'Snack',
      icon: CupertinoIcons.circle,
      defaultReminderTime: '16:00',
      sortOrder: 4,
    ),
  ];

  /// Default enabled meal types for new users
  static const List<String> defaultEnabledMeals = [
    'breakfast',
    'lunch', 
    'dinner',
    'snack',
  ];

  /// Get a meal type by its ID
  static MealType? getMealTypeById(String id) {
    try {
      return allMealTypes.firstWhere(
        (mealType) => mealType.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get a meal type by display name
  static MealType? getMealTypeByName(String name) {
    try {
      return allMealTypes.firstWhere(
        (mealType) => mealType.displayName.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get meal types that are enabled based on user preferences
  static List<MealType> getEnabledMealTypes(List<String> enabledMealIds) {
    return allMealTypes
        .where((mealType) => enabledMealIds.contains(mealType.id))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Get all meal type IDs
  static List<String> get allMealIds => allMealTypes.map((m) => m.id).toList();

  /// Get all meal display names
  static List<String> get allMealNames => allMealTypes.map((m) => m.displayName).toList();

  /// Validate if a meal ID is valid
  static bool isValidMealId(String id) {
    return allMealTypes.any((mealType) => mealType.id.toLowerCase() == id.toLowerCase());
  }

  /// Get icon for meal type (backward compatibility)
  static IconData getIconForMealType(String mealId) {
    final mealType = getMealTypeById(mealId);
    return mealType?.icon ?? CupertinoIcons.house; // Default fallback
  }

  /// Get display name for meal type (backward compatibility)
  static String getDisplayNameForMealType(String mealId) {
    final mealType = getMealTypeById(mealId);
    return mealType?.displayName ?? mealId; // Fallback to ID
  }
}

/// Helper extensions for working with meal configurations
extension MealConfigExtensions on List<String> {
  /// Filter to only valid meal IDs
  List<String> get validMealIds => where(MealConfig.isValidMealId).toList();
  
  /// Get MealType objects for these IDs
  List<MealType> get asMealTypes => MealConfig.getEnabledMealTypes(this);
}