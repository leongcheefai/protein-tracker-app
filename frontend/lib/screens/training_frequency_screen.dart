import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'goal_setting_screen.dart';
import '../main.dart';

class TrainingFrequencyScreen extends StatelessWidget {
  final double height;
  final double weight;

  const TrainingFrequencyScreen({
    super.key,
    required this.height,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    "How often do you train?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    "Select your activity level to calculate protein needs",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Interactive hint
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.info_circle,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tap any card to see details',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Activity Level Cards - Takes remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListView(
                  children: [
                    _buildActivityCard(
                      context,
                      'Light',
                      '1-2x/week',
                      'Occasional workouts, light activity',
                      1.2,
                      CupertinoIcons.person_2,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildActivityCard(
                      context,
                      'Moderate',
                      '3-4x/week',
                      'Regular workouts, moderate activity',
                      1.4,
                      CupertinoIcons.sportscourt,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildActivityCard(
                      context,
                      'Active',
                      '5-6x/week',
                      'Frequent workouts, high activity',
                      1.6,
                      CupertinoIcons.sportscourt,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildActivityCard(
                      context,
                      'Very Active',
                      'Daily + intense',
                      'Daily intense workouts, athlete level',
                      1.8,
                      CupertinoIcons.flame,
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String frequency,
    String description,
    double multiplier,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => GoalSettingScreen(
              height: height,
              weight: weight,
              trainingMultiplier: multiplier,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    frequency,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.neutral.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
