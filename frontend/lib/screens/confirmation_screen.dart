import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../main.dart';

class ConfirmationScreen extends StatefulWidget {
  final String imagePath;
  final String foodName;
  final double portion;
  final double protein;
  final String meal;
  final Map<String, double> mealProgress;
  final Map<String, double> mealTargets;
  // User settings for navigation back to user home
  final double? height;
  final double? weight;
  final double? trainingMultiplier;
  final String? goal;
  final double? dailyProteinTarget;
  final Map<String, bool>? meals;

  const ConfirmationScreen({
    super.key,
    required this.imagePath,
    required this.foodName,
    required this.portion,
    required this.protein,
    required this.meal,
    required this.mealProgress,
    required this.mealTargets,
    this.height,
    this.weight,
    this.trainingMultiplier,
    this.goal,
    this.dailyProteinTarget,
    this.meals,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _scaleController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _startAnimations();
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _checkmarkController.forward();
  }

  void _logAnotherFood() {
    // Navigate to camera launch screen
    Navigator.pushNamed(
      context,
      '/camera-launch',
    );
  }

  void _done() {
    // Navigate back to the user home screen by popping until we find it
    // or go back to the first route if user home is not in the stack
    Navigator.popUntil(
      context,
      (route) {
        // Check if this is the user home route
        if (route.settings.name == '/user-home') {
          return true;
        }
        // If we reach the first route and it's not user home, stop there
        return route.isFirst;
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final updatedProgress = Map<String, double>.from(widget.mealProgress);
    updatedProgress[widget.meal] = (updatedProgress[widget.meal] ?? 0) + widget.protein;
    
    final progressPercentage = updatedProgress[widget.meal]! / widget.mealTargets[widget.meal]!;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Success Animation
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _checkmarkAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _checkmarkAnimation.value,
                            child: Icon(
                              CupertinoIcons.check_mark,
                              color: CupertinoColors.systemGreen,
                              size: 60,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Success Message
            Text(
              'Successfully Added!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGreen,
              ),
            ),

            const SizedBox(height: 16),

            // Summary Text
            Text(
              'Added ${widget.protein.toStringAsFixed(1)}g protein to ${_getMealDisplayName(widget.meal)}',
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Food Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Food Photo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Food Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.foodName,
                          style: const TextStyle(
                            fontSize: 16,
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

            const SizedBox(height: 32),

            // Updated Meal Progress
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CupertinoColors.systemGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getMealDisplayName(widget.meal)} Progress',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoSlider(
                          value: progressPercentage.clamp(0.0, 1.0),
                          onChanged: null, // Read-only
                          activeColor: _getProgressColor(progressPercentage),
                          thumbColor: _getProgressColor(progressPercentage),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(progressPercentage * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getProgressColor(progressPercentage),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '${updatedProgress[widget.meal]!.toStringAsFixed(1)}g / ${widget.mealTargets[widget.meal]!.toStringAsFixed(1)}g protein',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  // Log Another Food Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _logAnotherFood,
                      color: CupertinoColors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.camera,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Log Another Food',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _done,
                      color: CupertinoColors.systemGreen,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}