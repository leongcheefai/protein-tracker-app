import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../main.dart';
import '../providers/food_provider.dart';

class FoodDetectionResultsScreen extends StatefulWidget {
  final String imagePath;
  final List<Map<String, dynamic>> detectedFoods; // Keep for backward compatibility

  const FoodDetectionResultsScreen({
    super.key,
    required this.imagePath,
    required this.detectedFoods,
  });

  @override
  State<FoodDetectionResultsScreen> createState() => _FoodDetectionResultsScreenState();
}

class _FoodDetectionResultsScreenState extends State<FoodDetectionResultsScreen> {
  int? _selectedFoodIndex;

  @override
  void initState() {
    super.initState();
    // Auto-select first food if available
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    if (foodProvider.detectedFoods.isNotEmpty) {
      _selectedFoodIndex = 0;
      foodProvider.selectDetectedFood(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        final detectedFoods = foodProvider.detectedFoods;
        final detectionResult = foodProvider.currentDetectionResult;
        
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
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: detectionResult?.imageUrl != null
                        ? Image.network(
                            detectionResult!.imageUrl,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CupertinoActivityIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to local image
                              return Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                              );
                            },
                          )
                        : Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
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
                    final confidence = food.confidence * 100;
                    final protein = food.estimatedNutrition?.protein ?? 0.0;
                    final category = food.category ?? 'Unknown';
                    final isSelected = _selectedFoodIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFoodIndex = index;
                        });
                        foodProvider.selectDetectedFood(index);
                      },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected 
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                                blurRadius: isSelected ? 8 : 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Selection indicator and food name
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (isSelected)
                                          Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            child: Icon(
                                              CupertinoIcons.checkmark_circle_fill,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                        Expanded(
                                          child: Text(
                                            food.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                  Expanded(
                                    child: Text(
                                      protein > 0 
                                          ? '${protein.toStringAsFixed(1)}g protein/100g'
                                          : 'Nutrition info unavailable',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Estimated quantity if available
                              if (food.estimatedQuantity != null && food.estimatedUnit != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.cube_box,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Est. ${food.estimatedQuantity!.toStringAsFixed(0)} ${food.estimatedUnit}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
              },
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              children: [
                // Add More Foods Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: () {
                      // Navigate to camera launch screen
                      Navigator.pushNamed(
                        context,
                        '/camera-launch',
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
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add More Foods',
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

                // Continue Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  child: CupertinoButton(
                    onPressed: detectedFoods.isNotEmpty && _selectedFoodIndex != null
                        ? () {
                            Navigator.pushNamed(
                              context,
                              '/portion-selection',
                              arguments: {
                                'imagePath': widget.imagePath,
                                'detectedFoods': detectedFoods.map((f) => f.toJson()).toList(),
                                'selectedFoodIndex': _selectedFoodIndex!,
                              },
                            );
                          }
                        : null,
                    color: detectedFoods.isNotEmpty && _selectedFoodIndex != null
                        ? AppColors.primary
                        : CupertinoColors.systemGrey,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedFoodIndex != null 
                              ? 'Continue with ${detectedFoods[_selectedFoodIndex!].name}'
                              : 'Select a food to continue',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          CupertinoIcons.arrow_right,
                          color: CupertinoColors.white,
                          size: 20,
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
      },
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
