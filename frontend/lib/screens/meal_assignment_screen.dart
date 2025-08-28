import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Assign to Meal',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Food Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.2),
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
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFoodIcon(selectedFood['category'] as String),
                    color: Colors.green[600],
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
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.portion.toInt()}g • ${widget.protein.toStringAsFixed(1)}g protein',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
                    color: Colors.black,
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
                          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
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
                                color: isSelected ? Colors.blue[600] : Colors.grey[400],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getMealIcon(meal),
                                color: Colors.white,
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
                                          color: isSelected ? Colors.blue[600] : Colors.black,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[600],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Suggested',
                                            style: TextStyle(
                                              color: Colors.white,
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
                                      color: Colors.grey[600],
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
                                  CircularProgressIndicator(
                                    value: progressPercentage.clamp(0.0, 1.0),
                                    strokeWidth: 4,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getProgressColor(progressPercentage),
                                    ),
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
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
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
        return Icons.fitness_center;
      case 'carbohydrate':
        return Icons.grain;
      case 'vegetable':
        return Icons.eco;
      case 'fruit':
        return Icons.apple;
      case 'dairy':
        return Icons.local_drink;
      default:
        return Icons.restaurant;
    }
  }

  IconData _getMealIcon(String meal) {
    switch (meal) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.nights_stay;
      case 'snack':
        return Icons.coffee;
      default:
        return Icons.restaurant;
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
    if (percentage >= 1.0) return Colors.green;
    if (percentage >= 0.8) return Colors.orange;
    if (percentage >= 0.6) return Colors.blue;
    return Colors.grey;
  }
}
