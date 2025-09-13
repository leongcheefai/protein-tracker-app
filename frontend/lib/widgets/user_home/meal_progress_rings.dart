import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/meal_config.dart';
import '../../utils/progress_utils.dart';
import '../../utils/meal_tracking_provider.dart';

/// A widget that displays meal progress with circular progress rings
/// 
/// This widget is focused on showing progress data and depends on MealTrackingProvider
/// for real-time progress updates. It uses the new meal configuration system.
class MealProgressRings extends StatelessWidget {
  final List<String> enabledMealTypes;
  final double dailyProteinTarget;
  final bool showIconsInCenter;
  final double ringSize;
  final double strokeWidth;

  const MealProgressRings({
    super.key,
    required this.enabledMealTypes,
    required this.dailyProteinTarget,
    this.showIconsInCenter = true,
    this.ringSize = 60.0,
    this.strokeWidth = 4.0,
  });

  /// Create from UserSettingsProvider (recommended approach)
  factory MealProgressRings.fromUserSettings({
    required List<String> userEnabledMealTypes,
    required double dailyProteinTarget,
    bool showIconsInCenter = true,
    double ringSize = 60.0,
    double strokeWidth = 4.0,
  }) {
    return MealProgressRings(
      enabledMealTypes: userEnabledMealTypes,
      dailyProteinTarget: dailyProteinTarget,
      showIconsInCenter: showIconsInCenter,
      ringSize: ringSize,
      strokeWidth: strokeWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealTrackingProvider>(
      builder: (context, mealProvider, child) {
        // Get valid meal types from configuration
        final mealTypes = MealConfig.getEnabledMealTypes(enabledMealTypes);
        
        if (mealTypes.isEmpty) {
          return const SizedBox.shrink();
        }

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
              child: Row(
                children: mealTypes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mealType = entry.value;
                  
                  // Get real progress from provider
                  final mealSummary = mealProvider.mealSummary;
                  final progress = (mealSummary[mealType.id.toLowerCase()]?['protein'] ?? 0.0).toDouble();
                  final target = (mealSummary[mealType.id.toLowerCase()]?['target'] ?? (dailyProteinTarget / 4)).toDouble();
                  final mealPercentage = target > 0 ? (progress / target) : 0.0;
              
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < mealTypes.length - 1 ? 8 : 0),
                      child: Column(
                        children: [
                          // Progress Ring
                          SizedBox(
                            width: ringSize,
                            height: ringSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background ring
                                CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: strokeWidth,
                                  backgroundColor: AppColors.neutral.withValues(alpha: 0.1),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                                ),
                                // Progress ring
                                CircularProgressIndicator(
                                  value: mealPercentage.clamp(0.0, 1.0),
                                  strokeWidth: strokeWidth,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ProgressUtils.getProgressColor(mealPercentage * 100),
                                  ),
                                ),
                                // Center icon (optional)
                                if (showIconsInCenter)
                                  Icon(
                                    mealType.icon,
                                    color: ProgressUtils.getProgressColor(mealPercentage * 100),
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Meal name
                          Text(
                            mealType.displayName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          
                          // Progress amount
                          Text(
                            '${progress.toStringAsFixed(0)}g',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A compact version of meal progress rings without labels
class CompactMealProgressRings extends StatelessWidget {
  final List<String> enabledMealTypes;
  final double dailyProteinTarget;
  final double ringSize;
  final double strokeWidth;
  final bool showProgress;

  const CompactMealProgressRings({
    super.key,
    required this.enabledMealTypes,
    required this.dailyProteinTarget,
    this.ringSize = 40.0,
    this.strokeWidth = 3.0,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showProgress) {
      // Just show icons without progress
      final mealTypes = MealConfig.getEnabledMealTypes(enabledMealTypes);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: mealTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final mealType = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(right: index < mealTypes.length - 1 ? 8.0 : 0),
            child: Icon(
              mealType.icon,
              size: 20,
              color: AppColors.primary,
            ),
          );
        }).toList(),
      );
    }

    return Consumer<MealTrackingProvider>(
      builder: (context, mealProvider, child) {
        final mealTypes = MealConfig.getEnabledMealTypes(enabledMealTypes);
        
        if (mealTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Row(
          children: mealTypes.asMap().entries.map((entry) {
            final index = entry.key;
            final mealType = entry.value;
            
            // Get progress data
            final mealSummary = mealProvider.mealSummary;
            final progress = (mealSummary[mealType.id.toLowerCase()]?['protein'] ?? 0.0).toDouble();
            final target = (mealSummary[mealType.id.toLowerCase()]?['target'] ?? (dailyProteinTarget / 4)).toDouble();
            final mealPercentage = target > 0 ? (progress / target) : 0.0;
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < mealTypes.length - 1 ? 8 : 0),
                alignment: Alignment.center,
                child: SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background ring
                      CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: strokeWidth,
                        backgroundColor: AppColors.neutral.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                      ),
                      // Progress ring
                      CircularProgressIndicator(
                        value: mealPercentage.clamp(0.0, 1.0),
                        strokeWidth: strokeWidth,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ProgressUtils.getProgressColor(mealPercentage * 100),
                        ),
                      ),
                      // Center icon
                      Icon(
                        mealType.icon,
                        color: ProgressUtils.getProgressColor(mealPercentage * 100),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Simple progress indicator for a single meal type
class SingleMealProgressRing extends StatelessWidget {
  final String mealTypeId;
  final double dailyProteinTarget;
  final double ringSize;
  final double strokeWidth;
  final bool showLabel;
  final bool showProgress;

  const SingleMealProgressRing({
    super.key,
    required this.mealTypeId,
    required this.dailyProteinTarget,
    this.ringSize = 60.0,
    this.strokeWidth = 4.0,
    this.showLabel = true,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final mealType = MealConfig.getMealTypeById(mealTypeId);
    if (mealType == null) {
      return const SizedBox.shrink();
    }

    if (!showProgress) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            mealType.icon,
            size: ringSize * 0.4,
            color: AppColors.primary,
          ),
          if (showLabel) ...[
            const SizedBox(height: 4),
            Text(
              mealType.displayName,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      );
    }

    return Consumer<MealTrackingProvider>(
      builder: (context, mealProvider, child) {
        // Get progress data
        final mealSummary = mealProvider.mealSummary;
        final progress = (mealSummary[mealType.id.toLowerCase()]?['protein'] ?? 0.0).toDouble();
        final target = (mealSummary[mealType.id.toLowerCase()]?['target'] ?? (dailyProteinTarget / 4)).toDouble();
        final mealPercentage = target > 0 ? (progress / target) : 0.0;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ringSize,
              height: ringSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: strokeWidth,
                    backgroundColor: AppColors.neutral.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                  ),
                  // Progress ring
                  CircularProgressIndicator(
                    value: mealPercentage.clamp(0.0, 1.0),
                    strokeWidth: strokeWidth,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ProgressUtils.getProgressColor(mealPercentage * 100),
                    ),
                  ),
                  // Center icon
                  Icon(
                    mealType.icon,
                    color: ProgressUtils.getProgressColor(mealPercentage * 100),
                    size: 20,
                  ),
                ],
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 8),
              Text(
                mealType.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '${progress.toStringAsFixed(0)}g',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }
}