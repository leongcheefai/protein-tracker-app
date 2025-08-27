import 'package:flutter/cupertino.dart';
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
                    "What's your goal?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    "Choose your fitness objective to optimize protein intake",
                    style: TextStyle(
                      fontSize: 16,
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
                      CupertinoIcons.circle,
                      'Maintain',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildGoalCard(
                      'Bulk',
                      'Build muscle mass',
                      CupertinoIcons.arrow_up_circle,
                      'Bulk',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildGoalCard(
                      'Cut',
                      'Lose fat while preserving muscle',
                      CupertinoIcons.arrow_down_circle,
                      'Cut',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Custom Protein Input
                    if (_selectedGoal == 'Custom') ...[
                      _buildCustomProteinInput(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Protein Summary
                    _buildProteinSummary(),
                    
                    const SizedBox(height: 32),
                    
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => MealSelectionScreen(
                                height: widget.height,
                                weight: widget.weight,
                                trainingMultiplier: widget.trainingMultiplier,
                                goal: _selectedGoal,
                                dailyProteinTarget: _goalProtein,
                              ),
                            ),
                          );
                        },
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildGoalCard(String title, String description, IconData icon, String goal) {
    final isSelected = _selectedGoal == goal;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = goal;
          if (goal != 'Custom') {
            _useCustomProtein = false;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.8) : AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '${_calculateGoalProtein(goal).toStringAsFixed(0)}g protein',
                    style: TextStyle(
                      fontSize: 14,
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
                child: Icon(
                  CupertinoIcons.check_mark,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomProteinInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Protein Target',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          CupertinoTextField(
            controller: TextEditingController(
              text: _customProtein > 0 ? _customProtein.toStringAsFixed(0) : '',
            ),
            keyboardType: TextInputType.number,
            placeholder: 'Enter protein target (g)',
            suffix: Text(
              'g',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            onChanged: (value) {
              final number = double.tryParse(value);
              if (number != null && number > 0) {
                setState(() {
                  _customProtein = number;
                  _useCustomProtein = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProteinSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Daily Protein Target',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Text(
                '${_goalProtein.toStringAsFixed(0)}g',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Based on ${widget.weight.toStringAsFixed(0)}kg weight',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '× ${widget.trainingMultiplier.toStringAsFixed(1)} activity multiplier',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
