import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/nutrition_service.dart';
import '../utils/meal_tracking_provider.dart';
import '../models/dto/meal_dto.dart';
import '../models/dto/food_dto.dart';

class EnhancedMealLoggingScreen extends StatefulWidget {
  final String? imagePath;
  final List<Map<String, dynamic>>? detectedFoods;
  final String? preselectedMealType;

  const EnhancedMealLoggingScreen({
    super.key,
    this.imagePath,
    this.detectedFoods,
    this.preselectedMealType,
  });

  @override
  State<EnhancedMealLoggingScreen> createState() => _EnhancedMealLoggingScreenState();
}

class _EnhancedMealLoggingScreenState extends State<EnhancedMealLoggingScreen> {
  String _selectedMeal = 'lunch';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<MealFood> _selectedFoods = [];
  List<Food> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _determineSuggestedMeal();
    _initializeWithDetectedFoods();
  }

  void _determineSuggestedMeal() {
    if (widget.preselectedMealType != null) {
      _selectedMeal = widget.preselectedMealType!;
      return;
    }

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

  void _initializeWithDetectedFoods() {
    if (widget.detectedFoods != null && widget.detectedFoods!.isNotEmpty) {
      // Convert detected foods to MealFood objects
      // This is a simplified implementation
      for (final detectedFood in widget.detectedFoods!) {
        final food = Food(
          id: 'detected-${DateTime.now().millisecondsSinceEpoch}',
          name: detectedFood['name'] ?? 'Unknown Food',
          nutritionPer100g: NutritionData(
            calories: (detectedFood['calories'] ?? 0).toDouble(),
            protein: (detectedFood['protein'] ?? 0).toDouble(),
            carbs: (detectedFood['carbs'] ?? 0).toDouble(),
            fat: (detectedFood['fat'] ?? 0).toDouble(),
            fiber: 0,
            sugar: 0,
            sodium: 0,
          ),
          commonPortions: [
            Portion(name: 'Small serving', grams: 75),
            Portion(name: 'Medium serving', grams: 150),
            Portion(name: 'Large serving', grams: 225),
          ],
          verified: false,
        );

        final nutritionData = NutritionService.calculateNutritionForQuantity(
          food.nutritionPer100g,
          150, // Default to medium serving
          'grams',
        );

        final mealFood = MealFood(
          id: food.id,
          food: food,
          quantity: 150,
          unit: 'grams',
          nutritionData: nutritionData,
        );

        _selectedFoods.add(mealFood);
      }
      setState(() {});
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await NutritionService.searchFoods(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showError('Failed to search foods: $e');
    }
  }

  void _addFoodToMeal(Food food, double quantity, String unit) {
    final nutritionData = NutritionService.calculateNutritionForQuantity(
      food.nutritionPer100g,
      quantity,
      unit,
    );

    final mealFood = MealFood(
      id: '${food.id}-${DateTime.now().millisecondsSinceEpoch}',
      food: food,
      quantity: quantity,
      unit: unit,
      nutritionData: nutritionData,
    );

    setState(() {
      _selectedFoods.add(mealFood);
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _removeFoodFromMeal(int index) {
    setState(() {
      _selectedFoods.removeAt(index);
    });
  }

  void _updateFoodQuantity(int index, double newQuantity) {
    final mealFood = _selectedFoods[index];
    final newNutrition = NutritionService.calculateNutritionForQuantity(
      mealFood.food.nutritionPer100g,
      newQuantity,
      mealFood.unit,
    );

    setState(() {
      _selectedFoods[index] = MealFood(
        id: mealFood.id,
        food: mealFood.food,
        quantity: newQuantity,
        unit: mealFood.unit,
        nutritionData: newNutrition,
      );
    });
  }

  NutritionData get _totalNutrition {
    return _selectedFoods.fold<NutritionData>(
      NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0, sodium: 0),
      (total, mealFood) => total + mealFood.nutritionData,
    );
  }

  Future<void> _saveMeal() async {
    if (_selectedFoods.isEmpty) {
      _showError('Please add at least one food item');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final mealTracker = Provider.of<MealTrackingProvider>(context, listen: false);
      
      final foods = _selectedFoods.map((mealFood) => MealFoodDto(
        id: '',
        mealId: '',
        foodId: mealFood.food.id,
        quantity: mealFood.quantity,
        unit: mealFood.unit,
        nutritionData: NutritionDataDto(
          calories: mealFood.nutritionData.calories,
          protein: mealFood.nutritionData.protein,
          carbs: mealFood.nutritionData.carbs,
          fat: mealFood.nutritionData.fat,
          fiber: mealFood.nutritionData.fiber,
          sugar: mealFood.nutritionData.sugar,
          sodium: mealFood.nutritionData.sodium,
        ),
      )).toList();

      final meal = await mealTracker.createMeal(
        mealType: _selectedMeal,
        photoUrl: widget.imagePath,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        foods: foods,
      );

      if (mounted) {
        if (meal != null) {
          Navigator.pushReplacementNamed(
            context,
            '/meal-success',
            arguments: {
              'meal': meal,
              'nutrition': _totalNutrition,
            },
          );
        } else {
          _showError('Failed to save meal');
        }
      }
    } catch (e) {
      _showError('Error saving meal: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealTracker = Provider.of<MealTrackingProvider>(context);
    
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
          'Log Meal',
          style: TextStyle(
            color: CupertinoColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: _isSaving 
          ? const CupertinoActivityIndicator()
          : CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _selectedFoods.isNotEmpty ? _saveMeal : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _selectedFoods.isNotEmpty 
                    ? AppColors.primary 
                    : CupertinoColors.inactiveGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal Type Selection
                    _buildMealTypeSelection(),
                    const SizedBox(height: 24),

                    // Food Search
                    _buildFoodSearch(),
                    const SizedBox(height: 16),

                    // Search Results
                    if (_searchResults.isNotEmpty) ...[
                      _buildSearchResults(),
                      const SizedBox(height: 24),
                    ],

                    // Selected Foods
                    if (_selectedFoods.isNotEmpty) ...[
                      _buildSelectedFoods(),
                      const SizedBox(height: 24),
                    ],

                    // Nutrition Summary
                    if (_selectedFoods.isNotEmpty) ...[
                      _buildNutritionSummary(),
                      const SizedBox(height: 24),
                    ],

                    // Notes
                    _buildNotesSection(),
                    const SizedBox(height: 24),

                    // Photo (if available)
                    if (widget.imagePath != null) ...[
                      _buildPhotoSection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['breakfast', 'lunch', 'dinner', 'snack'].map((meal) {
            final isSelected = _selectedMeal == meal;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: isSelected ? AppColors.primary : CupertinoColors.systemGrey5,
                  onPressed: () => setState(() => _selectedMeal = meal),
                  child: Text(
                    meal.substring(0, 1).toUpperCase() + meal.substring(1),
                    style: TextStyle(
                      color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFoodSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Foods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 12),
        CupertinoTextField(
          controller: _searchController,
          placeholder: 'Search for foods...',
          suffix: _isSearching
            ? const Padding(
                padding: EdgeInsets.only(right: 12),
                child: CupertinoActivityIndicator(),
              )
            : const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(CupertinoIcons.search, color: CupertinoColors.systemGrey),
              ),
          onChanged: _searchFoods,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Results',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...(_searchResults.take(5).map((food) => _buildFoodResultItem(food)).toList()),
      ],
    );
  }

  Widget _buildFoodResultItem(Food food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (food.brand != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    food.brand!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${NutritionService.formatNutritionValue(food.nutritionPer100g.protein)}g protein per 100g',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showAddFoodDialog(food),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFoods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Foods',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...(_selectedFoods.asMap().entries.map((entry) {
          final index = entry.key;
          final mealFood = entry.value;
          return _buildSelectedFoodItem(mealFood, index);
        }).toList()),
      ],
    );
  }

  Widget _buildSelectedFoodItem(MealFood mealFood, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mealFood.food.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _removeFoodFromMeal(index),
                child: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: CupertinoColors.systemRed,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Quantity: ${NutritionService.formatNutritionValue(mealFood.quantity)}${mealFood.unit == 'grams' ? 'g' : mealFood.unit}',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${NutritionService.formatNutritionValue(mealFood.nutritionData.protein)}g protein',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    final totalNutrition = _totalNutrition;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  'Protein',
                  '${NutritionService.formatNutritionValue(totalNutrition.protein)}g',
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  'Calories',
                  NutritionService.formatNutritionValue(totalNutrition.calories),
                  CupertinoColors.systemOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNutritionItem(
                  'Carbs',
                  '${NutritionService.formatNutritionValue(totalNutrition.carbs)}g',
                  CupertinoColors.systemGreen,
                ),
              ),
              Expanded(
                child: _buildNutritionItem(
                  'Fat',
                  '${NutritionService.formatNutritionValue(totalNutrition.fat)}g',
                  CupertinoColors.systemYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: _notesController,
          placeholder: 'Add any notes about this meal...',
          maxLines: 3,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: CupertinoColors.systemGrey6,
          ),
          child: const Center(
            child: Text(
              'Photo Preview\n(Implementation needed)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddFoodDialog(Food food) {
    double quantity = 100.0;
    String selectedUnit = 'grams';
    
    showCupertinoDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: Text(food.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text('How much did you eat?'),
              const SizedBox(height: 16),
              CupertinoTextField(
                keyboardType: TextInputType.number,
                placeholder: 'Quantity',
                onChanged: (value) {
                  quantity = double.tryParse(value) ?? quantity;
                },
                controller: TextEditingController(text: quantity.toString()),
              ),
              const SizedBox(height: 8),
              Text('$selectedUnit'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                _addFoodToMeal(food, quantity, selectedUnit);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}