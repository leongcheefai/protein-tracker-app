import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/progress_utils.dart';

class ProgressVisualization extends StatelessWidget {
  final double totalProgress;
  final double dailyProteinTarget;
  final String goal;
  final double trainingMultiplier;
  final Animation<double> ringAnimation;
  final Animation<double> pulseAnimation;

  const ProgressVisualization({
    super.key,
    required this.totalProgress,
    required this.dailyProteinTarget,
    required this.goal,
    required this.trainingMultiplier,
    required this.ringAnimation,
    required this.pulseAnimation,
  });

  double get progressPercentage {
    if (dailyProteinTarget == 0) return 0.0;
    return (totalProgress / dailyProteinTarget) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Ring
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Ring
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFF9CA3AF).withValues(alpha: 0.1), // AppColors.neutral
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                  ),
                ),
                
                // Progress Ring
                AnimatedBuilder(
                  animation: ringAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: ringAnimation.value,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ProgressUtils.getProgressColor(progressPercentage),
                        ),
                      ),
                    );
                  },
                ),
                
                // Center Content
                AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: pulseAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${totalProgress.toStringAsFixed(1)}g',
                            style: const TextStyle(
                              color: Color(0xFF111827), // AppColors.textPrimary
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'of ${dailyProteinTarget.toStringAsFixed(1)}g',
                            style: const TextStyle(
                              color: Color(0xFF6B7280), // AppColors.textSecondary
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: ProgressUtils.getProgressColor(progressPercentage).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${progressPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: ProgressUtils.getProgressColor(progressPercentage),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Goal Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.heart_fill,
                color: Color(0xFF3B82F6), // AppColors.primary
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Goal: $goal • ${trainingMultiplier.toStringAsFixed(1)}x training',
                style: const TextStyle(
                  color: Color(0xFF6B7280), // AppColors.textSecondary
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
