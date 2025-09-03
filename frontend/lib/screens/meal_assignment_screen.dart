import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class MealAssignmentScreen extends StatefulWidget {
  final String imagePath;
  final List<Map<String, dynamic>> detectedFoods;
  final int selectedFoodIndex;
  final double portion;
  final double protein;

  const MealAssignmentScreen({
    super.key,
    required this.imagePath,
    required this.detectedFoods,
    required this.selectedFoodIndex,
    required this.portion,
    required this.protein,
  });

  @override
  State<MealAssignmentScreen> createState() => _MealAssignmentScreenState();
}

class _MealAssignmentScreenState extends State<MealAssignmentScreen> {
  String _selectedMeal = 'lunch'; // Default meal
  final Map<String, double> _mealProgress = {
    'breakfast': 25.0, // Mock data - replace with actual progress
    'lunch': 45.0,
    'dinner': 30.0,
    'snack': 15.0,
  };

  final Map<String, double> _mealTargets = {
    'breakfast': 36.0, // Mock data - replace with actual targets
    'lunch': 36.0,
    'dinner': 36.0,
    'snack': 36.0,
  };

  @override
  void initState() {
    super.initState();
    _suggestMeal();
  }

  void _suggestMeal() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 6 && hour < 11) {
      _selectedMeal = 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      _selectedMeal = 'lunch';
    } else if (hour >= 16 && hour < 21) {
      _selectedMeal = 'dinner';
    } else {
      _selectedMeal = 'snack';
    }
    setState(() {});
  }

  void _selectMeal(String meal) {
    setState(() {
      _selectedMeal = meal;
    });
  }

  void _save() {
    Navigator.pushNamed(
      context,
      '/confirmation',
      arguments: {
        'imagePath': widget.imagePath,
        'foodName': widget.detectedFoods[widget.selectedFoodIndex]['name'],
        'portion': widget.portion,
        'protein': widget.protein,
        'meal': _selectedMeal,
        'mealProgress': _mealProgress,
        'mealTargets': _mealTargets,
      },
    );
  }

  Map<String, dynamic> get selectedFood => widget.detectedFoods[widget.selectedFoodIndex];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.transparent,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
          color: CupertinoColors.black,
        ),
        middle: const Text(
          'Assign to Meal',
          style: TextStyle(
            color: CupertinoColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
          // Food Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CupertinoColors.systemGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Food Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFoodIcon(selectedFood['category'] as String),
                    color: CupertinoColors.systemGreen,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Food Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedFood['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.portion.toInt()}g • ${widget.protein.toStringAsFixed(1)}g protein',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Meal Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Which meal is this?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Meal Selection Chips
                ...['breakfast', 'lunch', 'dinner', 'snack'].map((meal) {
                  final isSelected = _selectedMeal == meal;
                  final progress = _mealProgress[meal] ?? 0.0;
                  final target = _mealTargets[meal] ?? 0.0;
                  final progressPercentage = target > 0 ? (progress / target) : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _selectMeal(meal),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : CupertinoColors.systemGrey4,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Meal Icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : CupertinoColors.systemGrey3,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getMealIcon(meal),
                                color: CupertinoColors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Meal Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _getMealDisplayName(meal),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? AppColors.primary : CupertinoColors.black,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Suggested',
                                            style: TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${progress.toStringAsFixed(1)}g / ${target.toStringAsFixed(1)}g protein',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Progress Ring
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Stack(
                                children: [
                                  CupertinoActivityIndicator(
                                    radius: 20,
                                    color: _getProgressColor(progressPercentage),
                                  ),
                                  Center(
                                    child: Text(
                                      '${(progressPercentage * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _getProgressColor(progressPercentage),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const Spacer(),

          // Save Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                onPressed: _save,
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFoodIcon(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return CupertinoIcons.heart_fill;
      case 'carbohydrate':
        return CupertinoIcons.circle;
      case 'vegetable':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'fruit':
        return CupertinoIcons.circle_fill;
      case 'dairy':
        return CupertinoIcons.drop;
      default:
        return CupertinoIcons.house;
    }
  }

  IconData _getMealIcon(String meal) {
    switch (meal) {
      case 'breakfast':
        return CupertinoIcons.sun_max;
      case 'lunch':
        return CupertinoIcons.house;
      case 'dinner':
        return CupertinoIcons.moon;
      case 'snack':
        return CupertinoIcons.circle;
      default:
        return CupertinoIcons.house;
    }
  }

  String _getMealDisplayName(String meal) {
    switch (meal) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return meal;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 1.0) return CupertinoColors.systemGreen;
    if (percentage >= 0.8) return CupertinoColors.systemOrange;
    if (percentage >= 0.6) return AppColors.primary;
    return CupertinoColors.systemGrey;
  }
}