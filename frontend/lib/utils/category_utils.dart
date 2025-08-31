import 'package:flutter/cupertino.dart';
import '../main.dart';

class CategoryUtils {
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return AppColors.error; // Red for protein
      case 'carbohydrate':
        return AppColors.warning; // Orange for carbs
      case 'vegetable':
        return AppColors.success; // Green for vegetables
      case 'fruit':
        return AppColors.secondary; // Fresh green for fruits
      case 'dairy':
        return AppColors.primary; // Sage green for dairy
      case 'fat':
        return AppColors.warning; // Warm amber for fats
      default:
        return AppColors.neutral;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return CupertinoIcons.heart_fill;
      case 'carbohydrate':
        return CupertinoIcons.circle;
      case 'vegetable':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'fruit':
        return CupertinoIcons.circle_fill;
      case 'dairy':
        return CupertinoIcons.drop;
      case 'fat':
        return CupertinoIcons.drop;
      default:
        return CupertinoIcons.house;
    }
  }
}
