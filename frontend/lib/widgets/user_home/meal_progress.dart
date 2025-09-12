import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../utils/meal_utils.dart';
import '../../utils/progress_utils.dart';
import '../../utils/meal_tracking_provider.dart';

class MealProgress extends StatelessWidget {
  final Map<String, bool> meals;
  final double dailyProteinTarget;

  const MealProgress({
    super.key,
    required this.meals,
    required this.dailyProteinTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MealTrackingProvider>(
      builder: (context, mealProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Progress',
              style: TextStyle(
                color: AppColors.textPrimary,
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
                  
                  // Get real progress from provider
                  final mealSummary = mealProvider.mealSummary;
                  final progress = (mealSummary[mealName.toLowerCase()]?['protein'] ?? 0.0).toDouble();
                  final target = (mealSummary[mealName.toLowerCase()]?['target'] ?? (dailyProteinTarget / 4)).toDouble();
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
                            backgroundColor: AppColors.neutral.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                          ),
                          CircularProgressIndicator(
                            value: isEnabled ? mealPercentage.clamp(0.0, 1.0) : 0.0,
                            strokeWidth: 4,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isEnabled ? ProgressUtils.getProgressColor(mealPercentage * 100) : AppColors.neutral.withValues(alpha: 0.3),
                            ),
                          ),
                          Icon(
                            MealUtils.getMealIcon(mealName),
                            color: isEnabled ? ProgressUtils.getProgressColor(mealPercentage * 100) : AppColors.neutral.withValues(alpha: 0.3),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      mealName,
                      style: TextStyle(
                        color: isEnabled ? AppColors.textPrimary : AppColors.neutral.withValues(alpha: 0.3),
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
                        color: isEnabled ? AppColors.textSecondary : AppColors.neutral.withValues(alpha: 0.3),
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
      },
    );
  }
}
