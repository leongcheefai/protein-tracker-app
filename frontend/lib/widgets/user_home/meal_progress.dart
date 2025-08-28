import 'package:flutter/material.dart';
import '../../utils/meal_utils.dart';
import '../../utils/progress_utils.dart';

class MealProgress extends StatelessWidget {
  final Map<String, bool> meals;
  final Map<String, double> mealProgress;
  final double dailyProteinTarget;

  const MealProgress({
    super.key,
    required this.meals,
    required this.mealProgress,
    required this.dailyProteinTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Progress',
          style: TextStyle(
            color: Color(0xFF111827), // AppColors.textPrimary
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: meals.entries.length,
            itemBuilder: (context, index) {
              final mealEntry = meals.entries.elementAt(index);
              final mealName = mealEntry.key;
              final isEnabled = mealEntry.value;
              final progress = mealProgress[mealName] ?? 0.0;
              final target = dailyProteinTarget / 
                  meals.values.where((enabled) => enabled).length;
              final mealPercentage = target > 0 ? (progress / target) : 0.0;
              
              return Container(
                width: 90,
                margin: EdgeInsets.only(right: index == meals.entries.length - 1 ? 0 : 16),
                child: Column(
                  children: [
                    // Mini Progress Ring
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 4,
                            backgroundColor: const Color(0xFF9CA3AF).withValues(alpha: 0.1), // AppColors.neutral
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                          ),
                          CircularProgressIndicator(
                            value: isEnabled ? (mealPercentage / 100).clamp(0.0, 1.0) : 0.0,
                            strokeWidth: 4,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isEnabled ? ProgressUtils.getProgressColor(mealPercentage) : const Color(0xFF9CA3AF).withValues(alpha: 0.3), // AppColors.neutral
                            ),
                          ),
                          Icon(
                            MealUtils.getMealIcon(mealName),
                            color: isEnabled ? ProgressUtils.getProgressColor(mealPercentage) : const Color(0xFF9CA3AF).withValues(alpha: 0.3), // AppColors.neutral
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      mealName,
                      style: TextStyle(
                        color: isEnabled ? const Color(0xFF111827) : const Color(0xFF9CA3AF).withValues(alpha: 0.3), // AppColors.textPrimary vs neutral
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    
                    Text(
                      isEnabled ? '${progress.toStringAsFixed(0)}g' : '0g',
                      style: TextStyle(
                        color: isEnabled ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF).withValues(alpha: 0.3), // AppColors.textSecondary vs neutral
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
