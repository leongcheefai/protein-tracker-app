import 'package:flutter/material.dart';
import 'meal_selection_screen.dart';
import '../main.dart';

class GoalSettingScreen extends StatefulWidget {
  final double height;
  final double weight;
  final double trainingMultiplier;

  const GoalSettingScreen({
    super.key,
    required this.height,
    required this.weight,
    required this.trainingMultiplier,
  });

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  String _selectedGoal = 'Maintain';
  double _customProtein = 0.0;
  bool _useCustomProtein = false;

  double get _baseProtein => widget.weight * widget.trainingMultiplier;
  
  double get _goalProtein {
    if (_useCustomProtein && _customProtein > 0) {
      return _customProtein;
    }
    
    switch (_selectedGoal) {
      case 'Maintain':
        return _baseProtein;
      case 'Bulk':
        return _baseProtein * 1.1; // 10% increase for muscle building
      case 'Cut':
        return _baseProtein * 0.9; // 10% decrease for fat loss
      default:
        return _baseProtein;
    }
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
                    "What's your goal?",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    "Choose your fitness objective to optimize protein intake",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Goal Options - Takes remaining space with scrolling
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListView(
                  children: [
                    _buildGoalCard(
                      'Maintain',
                      'Keep current muscle mass',
                      Icons.balance,
                      'Maintain',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildGoalCard(
                      'Bulk',
                      'Build muscle and strength',
                      Icons.trending_up,
                      'Bulk',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildGoalCard(
                      'Cut',
                      'Lose fat, preserve muscle',
                      Icons.trending_down,
                      'Cut',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Daily Target Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your daily target',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            '${_goalProtein.toStringAsFixed(0)}g protein',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Based on ${_selectedGoal.toLowerCase()} goal',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Custom Protein Input (Optional)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _useCustomProtein,
                                onChanged: (value) {
                                  setState(() {
                                    _useCustomProtein = value ?? false;
                                    if (!_useCustomProtein) {
                                      _customProtein = 0.0;
                                    }
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                              Text(
                                'Custom protein target',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          
                          if (_useCustomProtein) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _customProtein > 0 ? _customProtein.toStringAsFixed(0) : '',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Enter custom protein target (g)',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final number = double.tryParse(value);
                                if (number != null && number > 0) {
                                  setState(() {
                                    _customProtein = number;
                                  });
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Add some bottom padding to ensure last element is fully visible
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Next Button - Fixed at bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => 
                          MealSelectionScreen(
                            height: widget.height,
                            weight: widget.weight,
                            trainingMultiplier: widget.trainingMultiplier,
                            goal: _selectedGoal,
                            dailyProteinTarget: _goalProtein,
                          ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(String title, String description, IconData icon, String goal) {
    final isSelected = _selectedGoal == goal;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = goal;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.8) : AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '${_calculateGoalProtein(goal).toStringAsFixed(0)}g protein',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateGoalProtein(String goal) {
    switch (goal) {
      case 'Maintain':
        return _baseProtein;
      case 'Bulk':
        return _baseProtein * 1.1;
      case 'Cut':
        return _baseProtein * 0.9;
      default:
        return _baseProtein;
    }
  }
}
