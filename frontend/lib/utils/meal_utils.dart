import 'package:flutter/cupertino.dart';

class MealUtils {
  static IconData getMealIcon(String mealName) {
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

  static String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
