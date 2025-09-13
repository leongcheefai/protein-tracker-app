import 'package:flutter/cupertino.dart';
import '../../main.dart';

class QuickStats extends StatelessWidget {
  final double totalProgress;
  final double progressPercentage;

  const QuickStats({
    super.key,
    required this.totalProgress,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Weekly Avg',
                  '${(totalProgress * 7).toStringAsFixed(0)}g',
                  CupertinoIcons.chart_bar,
                  const Color(0xFF10B981), // AppColors.success
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Goal Hit Rate',
                  '${_safePercentageToInt(progressPercentage)}%',
                  CupertinoIcons.flag,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Streak',
                  '3 days',
                  CupertinoIcons.flame,
                  const Color(0xFFF59E0B), // AppColors.warning
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  int _safePercentageToInt(double percentage) {
    if (percentage.isNaN || percentage.isInfinite) {
      return 0;
    }
    return percentage.clamp(0.0, 100.0).toInt();
  }
}
