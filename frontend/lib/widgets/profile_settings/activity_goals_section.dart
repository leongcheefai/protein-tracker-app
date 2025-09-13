import 'package:flutter/cupertino.dart';
import '../../main.dart';

class ActivityGoalsSection extends StatelessWidget {
  final String selectedActivityLevel;
  final double dailyProteinGoal;
  final List<String> dietaryRestrictions;
  final VoidCallback onActivityLevelTap;
  final VoidCallback onDietaryRestrictionsTap;

  const ActivityGoalsSection({
    super.key,
    required this.selectedActivityLevel,
    required this.dailyProteinGoal,
    required this.dietaryRestrictions,
    required this.onActivityLevelTap,
    required this.onDietaryRestrictionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Activity & Nutrition Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Protein Goal Hero Card
          _buildProteinGoalCard(),
          
          const SizedBox(height: 16),
          
          // Activity Level Card
          _buildActivityLevelCard(),
          
          const SizedBox(height: 16),
          
          // Dietary Restrictions Card
          _buildDietaryRestrictionsCard(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildProteinGoalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.scope,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Protein Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Based on your weight and activity level',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${dailyProteinGoal.toStringAsFixed(0)}g',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress visualization
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.7, // This could be dynamic based on today's intake
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s progress',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '70% complete', // This could be dynamic
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityLevelCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: onActivityLevelTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getActivityLevelColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActivityLevelIcon(),
                  color: _getActivityLevelColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getActivityLevelName(selectedActivityLevel),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getActivityLevelDescription(selectedActivityLevel),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDietaryRestrictionsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: onDietaryRestrictionsTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.heart,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dietary Restrictions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildDietaryRestrictionsContent(),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDietaryRestrictionsContent() {
    if (dietaryRestrictions.isEmpty) {
      return Text(
        'No restrictions set',
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
      );
    } else if (dietaryRestrictions.length <= 2) {
      return Text(
        dietaryRestrictions.join(', '),
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary.withValues(alpha: 0.8),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dietaryRestrictions.take(2).join(', '),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          Text(
            '+ ${dietaryRestrictions.length - 2} more',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }
  }
  
  String _getActivityLevelName(String level) {
    switch (level) {
      case 'sedentary':
        return 'Sedentary';
      case 'lightly_active':
        return 'Lightly Active';
      case 'moderately_active':
        return 'Moderately Active';
      case 'very_active':
        return 'Very Active';
      case 'extra_active':
        return 'Extra Active';
      default:
        return 'Moderately Active';
    }
  }
  
  String _getActivityLevelDescription(String level) {
    switch (level) {
      case 'sedentary':
        return 'Little to no exercise, desk job';
      case 'lightly_active':
        return 'Light exercise 1-3 days/week';
      case 'moderately_active':
        return 'Moderate exercise 3-5 days/week';
      case 'very_active':
        return 'Hard exercise 6-7 days/week';
      case 'extra_active':
        return 'Very hard exercise, physical job';
      default:
        return 'Moderate exercise 3-5 days/week';
    }
  }
  
  IconData _getActivityLevelIcon() {
    switch (selectedActivityLevel) {
      case 'sedentary':
        return CupertinoIcons.moon;
      case 'lightly_active':
        return CupertinoIcons.person;
      case 'moderately_active':
        return CupertinoIcons.sportscourt;
      case 'very_active':
        return CupertinoIcons.flame;
      case 'extra_active':
        return CupertinoIcons.bolt;
      default:
        return CupertinoIcons.sportscourt;
    }
  }
  
  Color _getActivityLevelColor() {
    switch (selectedActivityLevel) {
      case 'sedentary':
        return AppColors.neutral;
      case 'lightly_active':
        return AppColors.warning;
      case 'moderately_active':
        return AppColors.secondary;
      case 'very_active':
        return AppColors.primary;
      case 'extra_active':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }
}