import 'package:flutter/cupertino.dart';
import '../main.dart';

class PortionSelectionScreen extends StatefulWidget {
  final String imagePath;
  final List<Map<String, dynamic>> detectedFoods;
  final int selectedFoodIndex;

  const PortionSelectionScreen({
    super.key,
    required this.imagePath,
    required this.detectedFoods,
    required this.selectedFoodIndex,
  });

  @override
  State<PortionSelectionScreen> createState() => _PortionSelectionScreenState();
}

class _PortionSelectionScreenState extends State<PortionSelectionScreen> {
  double _selectedPortion = 150.0;
  bool _isCustomPortion = false;
  final TextEditingController _customPortionController = TextEditingController();
  final List<double> _standardPortions = [100, 150, 200, 250];
  int _currentFoodIndex = 0; // Track which food we're currently configuring
  bool _isBreakdownExpanded = false; // Track accordion expansion state

  @override
  void initState() {
    super.initState();
    _currentFoodIndex = widget.selectedFoodIndex; // Start with the initially selected food
    _selectedPortion = _standardPortions[1]; // Default to 150g
    _customPortionController.text = _selectedPortion.toString();
  }

  @override
  void dispose() {
    _customPortionController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get selectedFood => widget.detectedFoods[_currentFoodIndex];
  Map<String, dynamic> get currentFood => widget.detectedFoods[_currentFoodIndex];

  double get proteinPer100g => currentFood['estimatedProtein'] as double;

  double get calculatedProtein => (_selectedPortion / 100) * proteinPer100g;

  // Calculate total protein from all foods (assuming 150g default portion for non-selected foods)
  double get totalProteinFromAllFoods {
    double total = 0;
    for (int i = 0; i < widget.detectedFoods.length; i++) {
      final food = widget.detectedFoods[i];
      final portion = (i == _currentFoodIndex) ? _selectedPortion : 150.0; // Use selected portion for current food, default for others
      final proteinPer100g = food['estimatedProtein'] as double;
      total += (portion / 100) * proteinPer100g;
    }
    return total;
  }

  // Get individual food details for display
  List<Map<String, dynamic>> get individualFoodDetails {
    return widget.detectedFoods.asMap().entries.map((entry) {
      final index = entry.key;
      final food = entry.value;
      final portion = (index == _currentFoodIndex) ? _selectedPortion : 150.0;
      final proteinPer100g = food['estimatedProtein'] as double;
      final protein = (portion / 100) * proteinPer100g;
      
      return {
        'name': food['name'] as String,
        'portion': portion,
        'proteinPer100g': proteinPer100g,
        'calculatedProtein': protein,
        'isCurrent': index == _currentFoodIndex,
      };
    }).toList();
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

  void _selectFood(int index) {
    setState(() {
      _currentFoodIndex = index;
      _selectedPortion = _standardPortions[1]; // Reset to default portion
      _isCustomPortion = false;
      _customPortionController.text = _selectedPortion.toString();
    });
  }

  void _toggleBreakdown() {
    setState(() {
      _isBreakdownExpanded = !_isBreakdownExpanded;
    });
  }

  void _next() {
    Navigator.pushNamed(
      context,
      '/meal-assignment',
      arguments: {
        'imagePath': widget.imagePath,
        'detectedFoods': widget.detectedFoods,
        'selectedFoodIndex': _currentFoodIndex, // Use current food index
        'portion': _selectedPortion,
        'protein': calculatedProtein,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Custom Navigation Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey4,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      CupertinoIcons.back,
                      color: CupertinoColors.black,
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Portion Size',
                      style: TextStyle(
                        color: CupertinoColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 44), // Balance the back button
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
            // Debug: Show if we have data
            if (widget.detectedFoods.isEmpty || widget.selectedFoodIndex >= widget.detectedFoods.length)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CupertinoColors.systemRed,
                    width: 2,
                  ),
                ),
                child: const Text(
                  'ERROR: No food data available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ),
            
            // Food Selection (if multiple foods)
            if (widget.detectedFoods.length > 1) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Food to Configure',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90, // Increased height to prevent overflow
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.detectedFoods.length,
                        itemBuilder: (context, index) {
                          final food = widget.detectedFoods[index];
                          final isSelected = _currentFoodIndex == index;
                          return GestureDetector(
                            onTap: () => _selectFood(index),
                            child: Container(
                              width: 120,
                              margin: EdgeInsets.only(
                                right: index < widget.detectedFoods.length - 1 ? 12 : 0,
                              ),
                              padding: const EdgeInsets.all(8), // Reduced padding
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : CupertinoColors.systemGrey4,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min, // Prevent overflow
                                children: [
                                  Icon(
                                    _getFoodIcon(food['category'] as String),
                                    color: isSelected ? AppColors.primary : CupertinoColors.systemGrey,
                                    size: 20, // Slightly smaller icon
                                  ),
                                  const SizedBox(height: 6),
                                  Flexible( // Use Flexible to prevent overflow
                                    child: Text(
                                      food['name'] as String,
                                      style: TextStyle(
                                        fontSize: 11, // Slightly smaller font
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? AppColors.primary : CupertinoColors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Food Summary
            Container(
              margin: const EdgeInsets.all(16),
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
                  // Food Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getFoodIcon(currentFood['category'] as String),
                      color: AppColors.primary,
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
                          currentFood['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${proteinPer100g.toStringAsFixed(1)}g protein per 100g',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        if (widget.detectedFoods.length > 1) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Food ${_currentFoodIndex + 1} of ${widget.detectedFoods.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Portion Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Portion Size',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // Standard Portion Chips
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _standardPortions.map((portion) {
                    final isSelected = !_isCustomPortion && _selectedPortion == portion;
                    return GestureDetector(
                      onTap: () => _selectPortion(portion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : CupertinoColors.systemGrey4,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${portion.toInt()}g',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // Custom Portion
                GestureDetector(
                  onTap: _enableCustomPortion,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isCustomPortion ? AppColors.primary : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _isCustomPortion ? AppColors.primary : CupertinoColors.systemGrey4,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.pencil,
                          size: 20,
                          color: _isCustomPortion ? CupertinoColors.white : CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Custom',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isCustomPortion ? CupertinoColors.white : CupertinoColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Custom Input Field
                if (_isCustomPortion) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: CupertinoTextField(
                      controller: _customPortionController,
                      keyboardType: TextInputType.number,
                      placeholder: 'Enter portion size',
                      placeholderStyle: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.black,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(),
                      suffix: Container(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          'g',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onChanged: _updateCustomPortion,
                    ),
                  ),
                ],
              ],
            ),
          ),

                          // Enhanced Protein Calculation Display
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Reduced bottom margin
                            padding: const EdgeInsets.all(16), // Reduced padding
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
                // Show total and individual details if multiple foods
                if (widget.detectedFoods.length > 1) ...[
                  // Accordion-style Total Protein with Breakdown
                  GestureDetector(
                    onTap: _toggleBreakdown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Protein (${widget.detectedFoods.length} foods)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${totalProteinFromAllFoods.toStringAsFixed(1)}g',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: _isBreakdownExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Icon(
                                  CupertinoIcons.chevron_down,
                                  size: 16,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Animated Expandable Breakdown Section
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isBreakdownExpanded
                        ? Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: CupertinoColors.systemGrey4,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Individual Breakdown:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Individual Food Details with staggered animation
                                ...individualFoodDetails.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final food = entry.value;
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(milliseconds: 200 + (index * 100)),
                                    curve: Curves.easeOut,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 6),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: food['isCurrent'] 
                                                ? AppColors.primary.withValues(alpha: 0.1)
                                                : CupertinoColors.systemBackground,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: food['isCurrent'] 
                                                  ? AppColors.primary.withValues(alpha: 0.3)
                                                  : CupertinoColors.systemGrey4,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    food['name'],
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: food['isCurrent'] ? FontWeight.w600 : FontWeight.w500,
                                                      color: food['isCurrent'] ? AppColors.primary : CupertinoColors.black,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${food['portion'].toInt()}g → ${food['calculatedProtein'].toStringAsFixed(1)}g',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: CupertinoColors.systemGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Fixed Next Button at bottom
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        onPressed: _next,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: const Text(
                          'Next',
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
          ],
        ),
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
}
