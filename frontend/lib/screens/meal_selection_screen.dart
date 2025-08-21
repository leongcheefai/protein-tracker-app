import 'package:flutter/material.dart';
import '../main.dart';

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
    'Breakfast': Icons.wb_sunny,
    'Lunch': Icons.restaurant,
    'Dinner': Icons.dinner_dining,
    'Snack': Icons.coffee,
  };

  double get _mealProteinTarget {
    final enabledMeals = _meals.values.where((enabled) => enabled).length;
    return widget.dailyProteinTarget / enabledMeals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Which meals do you want to track?",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                "Configure your meal tracking preferences and protein distribution",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Meal Selection
              Expanded(
                child: ListView(
                  children: [
                    _buildMealToggle('Breakfast'),
                    const SizedBox(height: 16),
                    _buildMealToggle('Lunch'),
                    const SizedBox(height: 16),
                    _buildMealToggle('Dinner'),
                    const SizedBox(height: 16),
                    _buildMealToggle('Snack'),
                  ],
                ),
              ),
              
              // Daily Target Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Daily Protein Target',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      '${widget.dailyProteinTarget.toStringAsFixed(0)}g total',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Meal Breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _meals.entries.map((entry) {
                        if (entry.value) {
                          return Column(
                            children: [
                              Icon(
                                _mealIcons[entry.key],
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${_mealProteinTarget.toStringAsFixed(0)}g',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Start Tracking Button
              ElevatedButton(
                onPressed: () {
                  _showCompletionDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Start Tracking'),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealToggle(String mealName) {
    final isEnabled = _meals[mealName] ?? false;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.primary.withOpacity(0.1) : AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? AppColors.primary : AppColors.neutral.withOpacity(0.2),
          width: isEnabled ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.primary : AppColors.primary.withOpacity(0.1),
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isEnabled ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  isEnabled 
                      ? '${_mealProteinTarget.toStringAsFixed(0)}g protein target'
                      : 'Not tracking this meal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isEnabled ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Switch(
            value: isEnabled,
            onChanged: (value) {
              setState(() {
                _meals[mealName] = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Setup Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your protein tracking is now configured:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildSummaryRow('Daily Target', '${widget.dailyProteinTarget.toStringAsFixed(0)}g'),
              _buildSummaryRow('Goal', widget.goal),
              _buildSummaryRow('Training Level', '${widget.trainingMultiplier.toStringAsFixed(1)}x'),
              
              const SizedBox(height: 16),
              
              Text(
                'You\'re all set to start tracking your protein intake!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Here you would typically navigate to the main app
                // For now, we'll just show a success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Welcome to Protein Pace! 🎉'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Get Started'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
