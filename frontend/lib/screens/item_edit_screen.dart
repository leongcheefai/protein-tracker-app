import 'package:flutter/cupertino.dart';
import '../main.dart';

class ItemEditScreen extends StatefulWidget {
  final Map<String, dynamic> foodItem;
  final Map<String, bool> availableMeals;
  final Function(String, double, String) onSaveChanges;
  final Function(String) onDeleteItem;
  final VoidCallback onCancel;

  const ItemEditScreen({
    super.key,
    required this.foodItem,
    required this.availableMeals,
    required this.onSaveChanges,
    required this.onDeleteItem,
    required this.onCancel,
  });

  @override
  State<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  late TextEditingController _portionController;
  late String _selectedMeal;

  @override
  void initState() {
    super.initState();
    _portionController = TextEditingController(
      text: widget.foodItem['portion'].toString(),
    );
    _selectedMeal = widget.foodItem['meal'] ?? 'lunch';
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final newPortion = double.tryParse(_portionController.text);
    if (newPortion != null && newPortion > 0) {
      widget.onSaveChanges(
        widget.foodItem['id'],
        newPortion,
        _selectedMeal,
      );
      Navigator.pop(context);
    } else {
      _showInvalidPortionAlert();
    }
  }

  void _showInvalidPortionAlert() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Invalid Portion'),
          content: const Text('Please enter a valid portion size greater than 0.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Food Item?'),
          content: Text(
            'Are you sure you want to delete "${widget.foodItem['name']}"? This action cannot be undone.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Delete'),
              onPressed: () {
                Navigator.pop(context);
                widget.onDeleteItem(widget.foodItem['id']);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _selectMeal(String meal) {
    setState(() {
      _selectedMeal = meal;
    });
  }

  String _getMealDisplayName(String meal) {
    switch (meal.toLowerCase()) {
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

  IconData _getMealIcon(String meal) {
    switch (meal.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: null,
        middle: const Text(
          'Edit Food Item',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveChanges,
          child: const Text(
            'Save',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Item Summary Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.05),
                      blurRadius: 10.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            CupertinoIcons.circle,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.foodItem['name'] ?? 'Unknown Food',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Current: ${widget.foodItem['portion'].toStringAsFixed(1)}g • ${widget.foodItem['protein'].toStringAsFixed(1)}g protein',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Portion Adjustment Section
              Text(
                'Portion Size',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                  color: CupertinoColors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _portionController,
                        keyboardType: TextInputType.number,
                        placeholder: 'Enter portion size',
                        decoration: const BoxDecoration(
                          border: null,
                          color: CupertinoColors.systemBackground,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'g',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adjust the portion size to recalculate protein content',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // Meal Reassignment Section
              Text(
                'Assign to Meal',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              ...widget.availableMeals.entries.where((entry) => entry.value).map((entry) {
                final meal = entry.key;
                final isSelected = _selectedMeal == meal;

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
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : CupertinoColors.systemGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getMealIcon(meal),
                              color: CupertinoColors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _getMealDisplayName(meal),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              CupertinoIcons.check_mark_circled_solid,
                              color: AppColors.primary,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 40),

              // Delete Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _showDeleteConfirmation,
                  color: CupertinoColors.systemRed,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.delete,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Delete Item',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100), // Space for bottom
            ],
          ),
        ),
      ),
    );
  }
}
