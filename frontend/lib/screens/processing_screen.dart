import 'package:flutter/material.dart';
import 'dart:io';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int _currentStep = 0;
  final List<String> _processingSteps = [
    'Uploading photo...',
    'Analyzing image...',
    'Detecting foods...',
    'Calculating nutrition...',
    'Almost done...',
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    
    _startProcessing();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startProcessing() async {
    for (int i = 0; i < _processingSteps.length; i++) {
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        
        // Simulate processing time for each step
        await Future.delayed(Duration(milliseconds: 800 + (i * 200)));
      }
    }
    
    // Simulate final processing delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      // Navigate to food detection results
      Navigator.pushReplacementNamed(
        context,
        '/food-detection-results',
        arguments: {
          'imagePath': widget.imagePath,
          'detectedFoods': _getMockDetectedFoods(),
        },
      );
    }
  }

  List<Map<String, dynamic>> _getMockDetectedFoods() {
    // Mock data for development - replace with actual AI results
    return [
      {
        'name': 'Grilled Chicken Breast',
        'confidence': 0.95,
        'estimatedProtein': 31.0, // g per 100g
        'category': 'Protein',
      },
      {
        'name': 'Brown Rice',
        'confidence': 0.87,
        'estimatedProtein': 2.6, // g per 100g
        'category': 'Carbohydrate',
      },
      {
        'name': 'Broccoli',
        'confidence': 0.92,
        'estimatedProtein': 2.8, // g per 100g
        'category': 'Vegetable',
      },
    ];
  }

  void _cancelProcessing() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _cancelProcessing,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Analyzing Your Meal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Photo Thumbnail
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Processing Animation
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Status Text
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Text(
                    _processingSteps[_currentStep],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Progress Bar
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _processingSteps.length,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Progress Text
            Text(
              '${_currentStep + 1} of ${_processingSteps.length}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),

            const Spacer(),

            // Cancel Button
            Padding(
              padding: const EdgeInsets.all(32),
              child: TextButton(
                onPressed: _cancelProcessing,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
