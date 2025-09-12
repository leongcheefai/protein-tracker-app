import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import 'user_home_screen.dart';

class MealSelectionScreen extends StatefulWidget {
  final double height;
  final double weight;
  final double trainingMultiplier;
  final String goal;
  final double dailyProteinTarget;

  const MealSelectionScreen({
    super.key,
    required this.height,
    required this.weight,
    required this.trainingMultiplier,
    required this.goal,
    required this.dailyProteinTarget,
  });

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  final Map<String, bool> _meals = {
    'Breakfast': true,
    'Lunch': true,
    'Dinner': true,
    'Snack': false,
  };

  final Map<String, IconData> _mealIcons = {
    'Breakfast': CupertinoIcons.sun_max,
    'Lunch': CupertinoIcons.house,
    'Dinner': CupertinoIcons.moon,
    'Snack': CupertinoIcons.circle,
  };

  double get _mealProteinTarget {
    final enabledMeals = _meals.values.where((enabled) => enabled).length;
    return widget.dailyProteinTarget / enabledMeals;
  }

  String get _activityLevelFromMultiplier {
    if (widget.trainingMultiplier <= 1.2) return 'lightly_active';
    if (widget.trainingMultiplier <= 1.4) return 'moderately_active';
    if (widget.trainingMultiplier <= 1.6) return 'very_active';
    return 'extra_active';
  }

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
                    "Which meals do you want to track?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    "Configure your meal tracking preferences and protein distribution",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Meal Selection - Takes remaining space with scrolling
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListView(
                  children: [
                    _buildMealToggle('Breakfast'),
                    const SizedBox(height: 16),
                    _buildMealToggle('Lunch'),
                    const SizedBox(height: 16),
                    _buildMealToggle('Dinner'),
                    const SizedBox(height: 16),
                    _buildMealToggle('Snack'),
                    
                    const SizedBox(height: 24),
                    
                    // Daily Target Summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Daily Protein Target',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            '${widget.dailyProteinTarget.toStringAsFixed(0)}g total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Meal Breakdown
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _meals.entries.map((entry) {
                              final isEnabled = entry.value;
                              return Column(
                                children: [
                                  Icon(
                                    _mealIcons[entry.key],
                                    color: isEnabled ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.3),
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isEnabled ? AppColors.textSecondary : AppColors.neutral.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  Text(
                                    isEnabled 
                                        ? '${_mealProteinTarget.toStringAsFixed(0)}g'
                                        : '0g',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isEnabled ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.3),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    // Add some bottom padding to ensure last element is fully visible
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Start Tracking Button - Fixed at bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: () {
                    _showCompletionDialog(context);
                  },
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Start Tracking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealToggle(String mealName) {
    final isEnabled = _meals[mealName] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.2),
          width: isEnabled ? 2 : 1,
        ),
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
              color: isEnabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _mealIcons[mealName],
              color: isEnabled ? Colors.white : AppColors.primary,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  isEnabled 
                      ? '${_mealProteinTarget.toStringAsFixed(0)}g protein target'
                      : 'Not tracking this meal',
                  style: TextStyle(
                    fontSize: 14,
                    color: isEnabled ? AppColors.primary.withValues(alpha: 0.8) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          CupertinoSwitch(
            value: isEnabled,
            onChanged: (value) {
              setState(() {
                _meals[mealName] = value;
              });
            },
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show loading dialog first
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(),
              const SizedBox(height: 16),
              Text(
                'Saving your profile...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      // Update the user profile with collected data
      if (authProvider.currentUser != null) {
        final updatedProfile = authProvider.currentUser!.copyWith(
          height: widget.height,
          weight: widget.weight,
          dailyProteinGoal: widget.dailyProteinTarget,
          activityLevel: _activityLevelFromMultiplier,
        );

        final success = await authProvider.updateUserProfile(updatedProfile);
        
        if (success) {
          // Close loading dialog
          if (Navigator.canPop(context)) Navigator.of(context).pop();
          
          // Navigate directly to home screen after successful profile save
          _navigateToHomeScreen();
        } else {
          // Close loading dialog and show error
          if (Navigator.canPop(context)) Navigator.of(context).pop();
          _showErrorDialog(context, authProvider.errorMessage ?? 'Failed to save profile');
        }
      } else {
        // Close loading dialog and show error
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        _showErrorDialog(context, 'User not authenticated');
      }
    } catch (e) {
      // Close loading dialog and show error
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      _showErrorDialog(context, 'An unexpected error occurred: ${e.toString()}');
    }
  }

  void _navigateToHomeScreen() {
    // Navigate directly to home screen and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (context) => UserHomeScreen(
          height: widget.height,
          weight: widget.weight,
          trainingMultiplier: widget.trainingMultiplier,
          goal: widget.goal,
          dailyProteinTarget: widget.dailyProteinTarget,
          meals: _meals,
        ),
      ),
      (route) => false,
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: AppColors.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Setup Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to save your profile settings:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                // Try again
                _showCompletionDialog(context);
              },
              child: const Text('Try Again'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                // Continue without saving (temporary)
                _navigateToHomeScreen();
              },
              isDestructiveAction: true,
              child: const Text('Continue Anyway'),
            ),
          ],
        );
      },
    );
  }
}
