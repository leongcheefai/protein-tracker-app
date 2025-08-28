import 'package:flutter/material.dart';
import '../../utils/meal_utils.dart';

class EnhancedHeader extends StatelessWidget {
  const EnhancedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateString = '${MealUtils.getMonthName(now.month)} ${now.day}, ${now.year}';
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            dateString,
            style: const TextStyle(
              color: Color(0xFF6B7280), // AppColors.textSecondary
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
