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
        return const Color(0xFF8B5CF6); // Purple for fruits
      case 'dairy':
        return const Color(0xFF3B82F6); // Blue for dairy
      case 'fat':
        return const Color(0xFFF59E0B); // Amber for fats
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
