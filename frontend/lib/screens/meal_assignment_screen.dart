import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../main.dart';
import '../utils/meal_tracking_provider.dart';
import '../models/dto/meal_dto.dart';
import '../models/dto/food_dto.dart';

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
  String _selectedMeal = 'lunch'; // User's selected meal
  String _suggestedMeal = 'lunch'; // Time-based suggested meal (fixed)
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
    _determineSuggestedMeal();
  }

  void _determineSuggestedMeal() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 6 && hour < 11) {
      _suggestedMeal = 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      _suggestedMeal = 'lunch';
    } else if (hour >= 16 && hour < 21) {
      _suggestedMeal = 'dinner';
    } else {
      _suggestedMeal = 'snack';
    }
    
    // Set the selected meal to the suggested meal initially
    _selectedMeal = _suggestedMeal;
    setState(() {});
  }

  void _selectMeal(String meal) {
    setState(() {
      _selectedMeal = meal;
    });
  }

  void _save() async {
    final mealProvider = Provider.of<MealTrackingProvider>(context, listen: false);
    final selectedFood = widget.detectedFoods[widget.selectedFoodIndex];
    
    try {
      // Create nutrition data for the portion
      final nutritionData = NutritionDataDto(
        calories: (selectedFood['calories'] ?? 0).toDouble() * (widget.portion / 100),
        protein: widget.protein,
        carbs: (selectedFood['carbs'] ?? 0).toDouble() * (widget.portion / 100),
        fat: (selectedFood['fat'] ?? 0).toDouble() * (widget.portion / 100),
      );
      
      // Create meal food entry
      final mealFood = MealFoodDto(
        id: '',
        mealId: '',
        foodId: selectedFood['id'] ?? 'detected-food',
        quantity: widget.portion,
        unit: 'grams',
        nutritionData: nutritionData,
      );
      
      // Save meal to backend
      final meal = await mealProvider.createMeal(
        mealType: _selectedMeal,
        photoUrl: widget.imagePath,
        notes: 'Added via food detection',
        foods: [mealFood],
      );
      
      if (mounted && meal != null) {
        // Navigate to confirmation screen on success
        Navigator.pushNamed(
          context,
          '/confirmation',
          arguments: {
            'imagePath': widget.imagePath,
            'foodName': selectedFood['name'],
            'portion': widget.portion,
            'protein': widget.protein,
            'meal': _selectedMeal,
            'mealProgress': _mealProgress,
            'mealTargets': _mealTargets,
            'success': true,
          },
        );
      } else if (mounted) {
        // Show error if meal creation failed
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(mealProvider.error ?? 'Failed to save meal'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error dialog
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save meal: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
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
      child: SafeArea(
        child: Column(
          children: [
            // Meal Selection
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                        final isSuggested = _suggestedMeal == meal;
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
                                            if (isSuggested) ...[
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
                                        // Background circle
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: CupertinoColors.systemGrey4,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        // Progress arc
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CustomPaint(
                                            painter: ProgressPainter(
                                              progress: progressPercentage,
                                              color: _getProgressColor(progressPercentage),
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                        // Percentage text
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
              ),
            ),

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
      ),
    );
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

class ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  ProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Start from top (-π/2) and draw clockwise
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}