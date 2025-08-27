import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class FoodDetectionResultsScreen extends StatelessWidget {
  final String imagePath;
  final List<Map<String, dynamic>> detectedFoods;

  const FoodDetectionResultsScreen({
    super.key,
    required this.imagePath,
    required this.detectedFoods,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        middle: const Text(
          'Detected Foods',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
          // Photo Thumbnail
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Results Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Found ${detectedFoods.length} food${detectedFoods.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'AI Analysis',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detected Foods List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: detectedFoods.length,
              itemBuilder: (context, index) {
                final food = detectedFoods[index];
                final confidence = (food['confidence'] as double) * 100;
                final protein = food['estimatedProtein'] as double;
                final category = food['category'] as String;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Name and Confidence
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              food['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(confidence).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${confidence.toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getConfidenceColor(confidence),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Category and Protein Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(category).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getCategoryColor(category),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            CupertinoIcons.heart_fill,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${protein.toStringAsFixed(1)}g protein/100g',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Add More Foods Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: () {
                      // Navigate back to camera
                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      );
                    },
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.camera,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add More Foods',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: () {
                      // Navigate to portion selection for the first food
                      if (detectedFoods.isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          '/portion-selection',
                          arguments: {
                            'imagePath': imagePath,
                            'detectedFoods': detectedFoods,
                            'selectedFoodIndex': 0,
                          },
                        );
                      }
                    },
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_right,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 90) return Colors.green;
    if (confidence >= 70) return Colors.orange;
    return Colors.red;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return Colors.red;
      case 'carbohydrate':
        return Colors.orange;
      case 'vegetable':
        return Colors.green;
      case 'fruit':
        return Colors.purple;
      case 'dairy':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
