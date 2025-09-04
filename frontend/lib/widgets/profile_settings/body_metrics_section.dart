import 'package:flutter/cupertino.dart';

class BodyMetricsSection extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final VoidCallback onChanged;

  const BodyMetricsSection({
    super.key,
    required this.heightController,
    required this.weightController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Body Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        // Height and Weight Inputs
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Height (cm)',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    placeholder: '170',
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weight (kg)',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    placeholder: '70',
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
