import 'package:flutter/material.dart';
import '../main.dart';

class ProgressUtils {
  static Color getProgressColor(double percentage) {
    if (percentage >= 100) return AppColors.success;
    if (percentage >= 80) return AppColors.warning;
    if (percentage >= 60) return AppColors.primary;
    return AppColors.error;
  }
}
