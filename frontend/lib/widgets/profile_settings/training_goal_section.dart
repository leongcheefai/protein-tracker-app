import 'package:flutter/cupertino.dart';

class TrainingGoalSection extends StatelessWidget {
  final double selectedTrainingMultiplier;
  final String selectedGoal;
  final double dailyProteinTarget;
  final Function(double) onTrainingMultiplierChanged;
  final Function(String) onGoalChanged;

  const TrainingGoalSection({
    super.key,
    required this.selectedTrainingMultiplier,
    required this.selectedGoal,
    required this.dailyProteinTarget,
    required this.onTrainingMultiplierChanged,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Training Frequency Section
        _buildTrainingFrequencySection(),
        
        const SizedBox(height: 24),
        
        // Goal Section
        _buildGoalSection(),
        
        const SizedBox(height: 24),
        
        // Daily Target Display
        Center(
          child: _buildDailyTargetSection(),
        ),
      ],
    );
  }

  Widget _buildTrainingFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Training Frequency',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        Column(
          children: [
            _buildTrainingOption('Light', '1-2x/week', 1.6, 'Occasional workouts, light activity'),
            _buildTrainingOption('Moderate', '3-4x/week', 1.8, 'Regular training, moderate intensity'),
            _buildTrainingOption('Heavy', '5-6x/week', 2.0, 'Frequent training, high intensity'),
            _buildTrainingOption('Very Heavy', '6-7x/week', 2.2, 'Daily training, cutting phase'),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingOption(String title, String frequency, double multiplier, String description) {
    bool isSelected = selectedTrainingMultiplier == multiplier;
    
    return GestureDetector(
      onTap: () => onTrainingMultiplierChanged(multiplier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? CupertinoColors.activeBlue.withValues(alpha: 0.1) : CupertinoColors.systemBackground,
          border: Border.all(
            color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
              ),
              child: isSelected
                  ? const Icon(
                      CupertinoIcons.check_mark,
                      size: 14,
                      color: CupertinoColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        frequency,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${multiplier}g/kg',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitness Goal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildGoalOption('Maintain', 'Keep current muscle mass', 'maintain'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalOption('Bulk', 'Build muscle and strength', 'bulk'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalOption('Cut', 'Lose fat, preserve muscle', 'cut'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalOption(String title, String description, String goalValue) {
    bool isSelected = selectedGoal == goalValue;
    
    return GestureDetector(
      onTap: () => onGoalChanged(goalValue),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? CupertinoColors.activeBlue.withValues(alpha: 0.1) : CupertinoColors.systemBackground,
          border: Border.all(
            color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTargetSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        children: [
          const Text(
            'Daily Protein Target',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${dailyProteinTarget.toStringAsFixed(0)}g protein',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.activeGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on your current settings',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
