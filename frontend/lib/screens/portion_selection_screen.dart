import 'package:flutter/material.dart';

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
          'Portion Size',
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
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.2),
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
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFoodIcon(selectedFood['category'] as String),
                    color: Colors.blue[600],
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
                          color: Colors.grey[600],
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
                          color: isSelected ? Colors.blue[600] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
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
                      color: _isCustomPortion ? Colors.blue[600] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _isCustomPortion ? Colors.blue[600]! : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
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
                  TextField(
                    controller: _customPortionController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Portion (grams)',
                      hintText: 'Enter portion size',
                      suffixText: 'g',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                      ),
                    ),
                    onChanged: _updateCustomPortion,
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
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.2),
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
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.fitness_center,
                  size: 40,
                  color: Colors.green[600],
                ),
              ],
            ),
          ),

          // Next Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next',
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
}
