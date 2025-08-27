import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class QuickAddScreen extends StatefulWidget {
  final Map<String, double> mealProgress;
  final Map<String, double> mealTargets;
  final Map<String, bool> enabledMeals;

  const QuickAddScreen({
    super.key,
    required this.mealProgress,
    required this.mealTargets,
    required this.enabledMeals,
  });

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form state
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _foodNameController = TextEditingController();
  String _selectedMeal = 'lunch';
  double _selectedPortion = 150.0;
  bool _isCustomPortion = false;
  final TextEditingController _customPortionController = TextEditingController();

  // Quick portion options
  final List<double> _quickPortions = [50, 100, 150, 200, 250];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _suggestMeal();
    _proteinController.text = '25.0';
    _customPortionController.text = _selectedPortion.toString();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _proteinController.dispose();
    _foodNameController.dispose();
    _customPortionController.dispose();
    super.dispose();
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

  void _selectPortion(double portion) {
    setState(() {
      _selectedPortion = portion;
      _isCustomPortion = false;
      _customPortionController.text = portion.toString();
    });
  }

  void _enableCustomPortion() {
    setState(() {
      _isCustomPortion = true;
    });
    _customPortionController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _customPortionController.text.length,
    );
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _updateCustomPortion(String value) {
    final portion = double.tryParse(value);
    if (portion != null && portion > 0 && portion <= 1000) {
      setState(() {
        _selectedPortion = portion;
      });
    }
  }

  double get _proteinAmount {
    return double.tryParse(_proteinController.text) ?? 0.0;
  }

  bool get _canSubmit {
    return _proteinAmount > 0 && 
           _foodNameController.text.trim().isNotEmpty &&
           widget.enabledMeals[_selectedMeal] == true;
  }

  void _submit() {
    if (!_canSubmit) return;

    // Calculate protein per 100g for consistency with other screens
    final proteinPer100g = (_proteinAmount / _selectedPortion) * 100;
    
    // Navigate to confirmation with the quick add data
    Navigator.pushNamed(
      context,
      '/confirmation',
      arguments: {
        'imagePath': '', // No image for quick add
        'foodName': _foodNameController.text.trim(),
        'portion': _selectedPortion,
        'protein': _proteinAmount,
        'meal': _selectedMeal,
        'mealProgress': widget.mealProgress,
        'mealTargets': widget.mealTargets,
        'isQuickAdd': true,
        'proteinPer100g': proteinPer100g,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        middle: Text(
          'Quick Add Protein',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeaderSection(),
                      
                      const SizedBox(height: 32),
                      
                      // Food Name Input
                      _buildFoodNameInput(),
                      
                      const SizedBox(height: 24),
                      
                      // Portion Selection
                      _buildPortionSelection(),
                      
                      const SizedBox(height: 24),
                      
                      // Protein Input
                      _buildProteinInput(),
                      
                      const SizedBox(height: 32),
                      
                      // Meal Selection
                      _buildMealSelection(),
                      
                      const SizedBox(height: 32),
                      
                      // Summary Card
                      _buildSummaryCard(),
                      
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              CupertinoIcons.bolt,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Protein Log',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log your protein intake without taking photos',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Food Name',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: _foodNameController,
          placeholder: 'e.g., Chicken Breast, Greek Yogurt',
          prefix: Icon(CupertinoIcons.house, color: AppColors.textSecondary),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildPortionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portion Size',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Quick Portion Chips
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _quickPortions.map((portion) {
            final isSelected = !_isCustomPortion && _selectedPortion == portion;
            return GestureDetector(
              onTap: () => _selectPortion(portion),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${portion.toInt()}g',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Custom Portion
        GestureDetector(
          onTap: _enableCustomPortion,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _isCustomPortion ? AppColors.primary : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _isCustomPortion ? AppColors.primary : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.pencil,
                  size: 20,
                  color: _isCustomPortion ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Custom',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isCustomPortion ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Custom Input Field
        if (_isCustomPortion) ...[
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _customPortionController,
            keyboardType: TextInputType.number,
            placeholder: 'Enter portion size',
            suffix: const Text(
              'g',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onChanged: _updateCustomPortion,
          ),
        ],
      ],
    );
  }

  Widget _buildProteinInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Protein Amount',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: _proteinController,
          keyboardType: TextInputType.number,
          placeholder: '25.0',
          suffix: const Text(
            'g protein',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          prefix: Icon(CupertinoIcons.heart_fill, color: AppColors.primary),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the total protein content for your portion',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMealSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign to Meal',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        ...widget.enabledMeals.entries.where((entry) => entry.value).map((entry) {
          final meal = entry.key;
            final isSelected = _selectedMeal == meal;
            final progress = widget.mealProgress[meal] ?? 0.0;
            final target = widget.mealTargets[meal] ?? 0.0;
            final progressPercentage = target > 0 ? (progress / target) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _selectMeal(meal),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
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
                          color: isSelected ? AppColors.primary : Colors.grey[400],
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
                                    color: isSelected ? AppColors.primary : Colors.black,
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
                                      'Selected',
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
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Summary',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Food',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _foodNameController.text.trim().isEmpty 
                          ? 'Not specified' 
                          : _foodNameController.text.trim(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portion',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${_selectedPortion.toInt()}g',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protein',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${_proteinAmount.toStringAsFixed(1)}g',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Meal: ${_getMealDisplayName(_selectedMeal)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: _canSubmit ? _submit : null,
        color: _canSubmit ? AppColors.primary : Colors.grey,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Add to ${_getMealDisplayName(_selectedMeal)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
    if (percentage >= 1.0) return AppColors.success;
    if (percentage >= 0.8) return AppColors.warning;
    if (percentage >= 0.6) return AppColors.primary;
    return Colors.grey;
  }
}
