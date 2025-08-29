import 'package:flutter/cupertino.dart';
import '../main.dart';

class HistoryScreen extends StatefulWidget {
  final double dailyProteinTarget;
  final Map<String, bool> meals;

  const HistoryScreen({
    super.key,
    required this.dailyProteinTarget,
    required this.meals,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Mock data for demonstration - in real app this would come from a database
  final List<Map<String, dynamic>> _historyData = [
    {
      'date': '2024-01-15',
      'totalProtein': 142.0,
      'goal': 144.0,
      'goalMet': true,
      'streak': 5,
      'meals': {
        'Breakfast': {'target': 36.0, 'actual': 38.0, 'items': ['Greek Yogurt', 'Oatmeal']},
        'Lunch': {'target': 36.0, 'actual': 45.0, 'items': ['Grilled Chicken', 'Quinoa']},
        'Dinner': {'target': 36.0, 'actual': 42.0, 'items': ['Salmon', 'Broccoli']},
        'Snack': {'target': 36.0, 'actual': 17.0, 'items': ['Protein Bar']},
      }
    },
    {
      'date': '2024-01-14',
      'totalProtein': 138.0,
      'goal': 144.0,
      'goalMet': false,
      'streak': 4,
      'meals': {
        'Breakfast': {'target': 36.0, 'actual': 32.0, 'items': ['Eggs', 'Toast']},
        'Lunch': {'target': 36.0, 'actual': 41.0, 'items': ['Turkey Sandwich', 'Apple']},
        'Dinner': {'target': 36.0, 'actual': 45.0, 'items': ['Beef Steak', 'Rice']},
        'Snack': {'target': 36.0, 'actual': 20.0, 'items': ['Nuts']},
      }
    },
    {
      'date': '2024-01-13',
      'totalProtein': 147.0,
      'goal': 144.0,
      'goalMet': true,
      'streak': 3,
      'meals': {
        'Breakfast': {'target': 36.0, 'actual': 35.0, 'items': ['Protein Shake', 'Banana']},
        'Lunch': {'target': 36.0, 'actual': 38.0, 'items': ['Tuna Salad', 'Crackers']},
        'Dinner': {'target': 36.0, 'actual': 44.0, 'items': ['Pork Chops', 'Potatoes']},
        'Snack': {'target': 36.0, 'actual': 30.0, 'items': ['Cottage Cheese']},
      }
    },
  ];

  String _selectedDateRange = '7 days';
  final List<String> _dateRanges = ['7 days', '30 days', '1 year'];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: null,
        middle: const Text(
          'History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Enhanced Date Range Selector with Today Quick Access
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Today Quick Access Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: CupertinoButton.filled(
                      onPressed: () {
                        // TODO: Navigate to today's data
                        setState(() {
                          _selectedDateRange = '7 days';
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.calendar,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Today',
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
                  const SizedBox(height: 12),
                  
                  // View Stats Button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: CupertinoButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/stats-overview',
                          arguments: {
                            'dailyProteinTarget': widget.dailyProteinTarget,
                          },
                        );
                      },
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.chart_bar_fill,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'View Stats',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Date Range Selector
                  Row(
                    children: [
                      const Text(
                        'Date Range:',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBackground,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: CupertinoSlidingSegmentedControl<String>(
                            groupValue: _selectedDateRange,
                            backgroundColor: AppColors.secondaryBackground,
                            thumbColor: AppColors.primary,
                            children: {
                              for (final range in _dateRanges)
                                range: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                  child: Text(
                                    range,
                                    style: TextStyle(
                                      color: _selectedDateRange == range 
                                          ? CupertinoColors.white 
                                          : AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            },
                            onValueChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedDateRange = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // History List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _historyData.length,
                itemBuilder: (context, index) {
                  final dayData = _historyData[index];
                  final date = DateTime.parse(dayData['date']);
                  final isToday = date.isAtSameMomentAs(DateTime.now().subtract(const Duration(days: 1)));
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/meal-breakdown',
                        arguments: {
                          'date': dayData['date'],
                          'dailyTotal': dayData['totalProtein'],
                          'dailyGoal': dayData['goal'],
                          'meals': dayData['meals'],
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
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
                      children: [
                        // Enhanced Day Header with Streak
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primary.withValues(alpha: 0.1) : null,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(date),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatDay(date),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  if (dayData['goalMet'])
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: const Text(
                                        'Goal Met!',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  // Enhanced Streak Indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          CupertinoIcons.flame_fill,
                                          color: AppColors.primary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${dayData['streak']} day streak',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
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

                        // Enhanced Progress Summary with Better Protein Ring
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Enhanced Protein Ring
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Stack(
                                  children: [
                                    // Background circle
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.secondaryBackground,
                                          width: 6,
                                        ),
                                      ),
                                    ),
                                    // Progress circle with gradient
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _getProgressColor(dayData['totalProtein'], dayData['goal']),
                                          width: 6,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${(dayData['totalProtein'] / dayData['goal'] * 100).round()}%',
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Goal',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Protein Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${dayData['totalProtein'].round()}g / ${dayData['goal'].round()}g',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Daily Protein',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Progress bar
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryBackground,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: (dayData['totalProtein'] / dayData['goal']).clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _getProgressColor(dayData['totalProtein'], dayData['goal']),
                                            borderRadius: BorderRadius.circular(3),
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

                        // Enhanced Meal Breakdown
                        Container(
                          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                          child: Column(
                            children: [
                              Container(
                                height: 1,
                                color: AppColors.secondaryBackground,
                              ),
                              const SizedBox(height: 12),
                              ...dayData['meals'].entries.map((meal) {
                                final mealData = meal.value as Map<String, dynamic>;
                                final progress = mealData['actual'] / mealData['target'];
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          meal.key,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.secondaryBackground,
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                    child: FractionallySizedBox(
                                                      alignment: Alignment.centerLeft,
                                                      widthFactor: progress.clamp(0.0, 1.0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: _getProgressColor(mealData['actual'], mealData['target']),
                                                          borderRadius: BorderRadius.circular(3),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${mealData['actual'].round()}g',
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              mealData['items'].join(', '),
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
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
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDay(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference < 7) {
      return date.weekday == 1 ? 'Monday' :
             date.weekday == 2 ? 'Tuesday' :
             date.weekday == 3 ? 'Wednesday' :
             date.weekday == 4 ? 'Thursday' :
             date.weekday == 5 ? 'Friday' :
             date.weekday == 6 ? 'Saturday' : 'Sunday';
    }
    
    return '${date.day} ${_getMonthName(date.month)}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Color _getProgressColor(double actual, double target) {
    final percentage = actual / target;
    if (percentage >= 1.0) return AppColors.success;
    if (percentage >= 0.8) return AppColors.warning;
    return AppColors.error;
  }
}
