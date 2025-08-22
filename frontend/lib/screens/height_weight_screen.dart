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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
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
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  "Enter your basic body metrics to get started",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  Icons.height,
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
                  Icons.monitor_weight,
                ),
                
                const SizedBox(height: 24),
                
                // BMI Display
                _buildBMIDisplay(),
                
                const SizedBox(height: 32),
                
                // Next Button
                ElevatedButton(
                  onPressed: _canProceed() ? () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => 
                              TrainingFrequencyScreen(height: _height, weight: _weight),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canProceed() ? AppColors.primary : AppColors.neutral.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Next'),
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Slider
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${min.toInt()}$unit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${max.toInt()}$unit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 6),
              
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.neutral.withValues(alpha: 0.3),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.2),
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: (max - min).toInt(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Manual Input
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter $title',
            suffixText: unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $title';
            }
            final number = double.tryParse(value);
            if (number == null) {
              return 'Please enter a valid number';
            }
            if (number < min || number > max) {
              return '$title must be between ${min.toInt()}$unit and ${max.toInt()}$unit';
            }
            return null;
          },
          onChanged: (value) {
            final number = double.tryParse(value);
            if (number != null && number >= min && number <= max) {
              onChanged(number);
            }
          },
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmiColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bmiCategory,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
