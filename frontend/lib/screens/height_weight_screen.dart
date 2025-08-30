import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'training_frequency_screen.dart';
import '../main.dart';

class HeightWeightScreen extends StatefulWidget {
  const HeightWeightScreen({super.key});

  @override
  State<HeightWeightScreen> createState() => _HeightWeightScreenState();
}

class _HeightWeightScreenState extends State<HeightWeightScreen> {
  double _height = 170.0;
  double _weight = 70.0;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _heightController.text = _height.toStringAsFixed(0);
    _weightController.text = _weight.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _updateHeight(double value) {
    setState(() {
      _height = value;
      _heightController.text = value.toStringAsFixed(0);
    });
  }

  void _updateWeight(double value) {
    setState(() {
      _weight = value;
      _weightController.text = value.toStringAsFixed(0);
    });
  }

  bool _canProceed() {
    return _height >= 100 && _height <= 250 && _weight >= 30 && _weight <= 200;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  "Let's calculate your protein needs",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  "Enter your basic body metrics to get started",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Height Section
                _buildInputSection(
                  context,
                  'Height',
                  'cm',
                  _height,
                  100.0,
                  250.0,
                  _heightController,
                  _updateHeight,
                  CupertinoIcons.arrow_up_arrow_down,
                ),
                
                const SizedBox(height: 24),
                
                // Weight Section
                _buildInputSection(
                  context,
                  'Weight',
                  'kg',
                  _weight,
                  30.0,
                  200.0,
                  _weightController,
                  _updateWeight,
                  CupertinoIcons.chart_bar,
                ),
                
                const SizedBox(height: 24),
                
                // BMI Display
                _buildBMIDisplay(),
                
                const SizedBox(height: 32),
                
                // Next Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _canProceed() ? () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => TrainingFrequencyScreen(
                              height: _height, 
                              weight: _weight
                            ),
                          ),
                        );
                      }
                    } : null,
                    color: _canProceed() ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(
    BuildContext context,
    String title,
    String unit,
    double value,
    double min,
    double max,
    TextEditingController controller,
    Function(double) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Slider
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${min.toInt()}$unit',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${max.toInt()}$unit',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              CupertinoSlider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                onChanged: onChanged,
                activeColor: AppColors.primary,
                thumbColor: AppColors.primary,
              ),
              
              const SizedBox(height: 8),
              
              // Current value display
              Text(
                '${value.toInt()}$unit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Manual Input Label
        Text(
          'Or enter manually:',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Manual Input
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CupertinoTextField(
            controller: controller,
            keyboardType: TextInputType.number,
            placeholder: 'Enter $title',
            placeholderStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 16,
            ),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffix: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                unit,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            decoration: null, // Remove the decoration to avoid conflicts
            onChanged: (value) {
              final number = double.tryParse(value);
              if (number != null && number >= min && number <= max) {
                onChanged(number);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBMIDisplay() {
    final bmi = _weight / ((_height / 100) * (_height / 100));
    String bmiCategory;
    Color bmiColor;
    
    if (bmi < 18.5) {
      bmiCategory = 'Underweight';
      bmiColor = AppColors.warning;
    } else if (bmi < 25) {
      bmiCategory = 'Normal weight';
      bmiColor = AppColors.success;
    } else if (bmi < 30) {
      bmiCategory = 'Overweight';
      bmiColor = AppColors.warning;
    } else {
      bmiCategory = 'Obese';
      bmiColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bmiColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmiColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: bmiColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.info_circle,
            color: bmiColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your BMI: ${bmi.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bmiCategory,
                  style: TextStyle(
                    fontSize: 14,
                    color: bmiColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
