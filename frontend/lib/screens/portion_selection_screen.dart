import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedPortion = _standardPortions[1]; // Default to 150g
    _customPortionController.text = _selectedPortion.toString();
  }

  @override
  void dispose() {
    _customPortionController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get selectedFood => widget.detectedFoods[widget.selectedFoodIndex];

  double get proteinPer100g => selectedFood['estimatedProtein'] as double;

  double get calculatedProtein => (_selectedPortion / 100) * proteinPer100g;

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

  void _next() {
    Navigator.pushNamed(
      context,
      '/meal-assignment',
      arguments: {
        'imagePath': widget.imagePath,
        'detectedFoods': widget.detectedFoods,
        'selectedFoodIndex': widget.selectedFoodIndex,
        'portion': _selectedPortion,
        'protein': calculatedProtein,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        middle: const Text(
          'Portion Size',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
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
                    _getFoodIcon(selectedFood['category'] as String),
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
                        selectedFood['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

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
                  const SizedBox(height: 16),
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

          const Spacer(),

          // Protein Calculation Display
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CupertinoColors.systemGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedPortion.toInt()}g × ${proteinPer100g.toStringAsFixed(1)}g/100g',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '≈ ${calculatedProtein.toStringAsFixed(1)}g protein',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemGreen,
                      ),
                    ),
                  ],
                ),
                Icon(
                  CupertinoIcons.heart_fill,
                  size: 40,
                  color: CupertinoColors.systemGreen,
                ),
              ],
            ),
          ),

          // Next Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
