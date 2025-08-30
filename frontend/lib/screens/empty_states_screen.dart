import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';

enum EmptyStateType {
  firstTime,
  noData,
  noResults,
  noHistory,
  noMeals,
  noProgress,
}

class EmptyStatesScreen extends StatelessWidget {
  final EmptyStateType emptyStateType;
  final String? customTitle;
  final String? customMessage;
  final String? customActionText;
  final VoidCallback? onActionPressed;
  final bool showIllustration;

  const EmptyStatesScreen({
    super.key,
    required this.emptyStateType,
    this.customTitle,
    this.customMessage,
    this.customActionText,
    this.onActionPressed,
    this.showIllustration = true,
  });

  String get _getTitle {
    if (customTitle != null) {
      return customTitle!;
    }
    
    switch (emptyStateType) {
      case EmptyStateType.firstTime:
        return 'Welcome to Protein Pace!';
      case EmptyStateType.noData:
        return 'No Data Available';
      case EmptyStateType.noResults:
        return 'No Results Found';
      case EmptyStateType.noHistory:
        return 'No History Yet';
      case EmptyStateType.noMeals:
        return 'No Meals Logged';
      case EmptyStateType.noProgress:
        return 'No Progress Data';
    }
  }

  String get _getMessage {
    if (customMessage != null) {
      return customMessage!;
    }
    
    switch (emptyStateType) {
      case EmptyStateType.firstTime:
        return 'Start your protein tracking journey by taking a photo of your first meal. We\'ll help you stay on track with your fitness goals.';
      case EmptyStateType.noData:
        return 'There\'s no data to display at the moment. This could be because you haven\'t logged any meals yet or there was an issue loading your data.';
      case EmptyStateType.noResults:
        return 'We couldn\'t find any results matching your search. Try adjusting your filters or search terms.';
      case EmptyStateType.noHistory:
        return 'Your meal history will appear here once you start logging your protein intake. Start by taking a photo of your next meal!';
      case EmptyStateType.noMeals:
        return 'You haven\'t logged any meals yet. Start tracking your protein intake by taking a photo of your next meal.';
      case EmptyStateType.noProgress:
        return 'Progress data will appear here once you start consistently logging your meals and hitting your protein goals.';
    }
  }

  String get _getActionText {
    if (customActionText != null) {
      return customActionText!;
    }
    
    switch (emptyStateType) {
      case EmptyStateType.firstTime:
        return 'Get Started';
      case EmptyStateType.noData:
        return 'Refresh';
      case EmptyStateType.noResults:
        return 'Try Again';
      case EmptyStateType.noHistory:
        return 'Log First Meal';
      case EmptyStateType.noMeals:
        return 'Log Meal';
      case EmptyStateType.noProgress:
        return 'Start Tracking';
    }
  }

  IconData get _getIcon {
    switch (emptyStateType) {
      case EmptyStateType.firstTime:
        return CupertinoIcons.rocket;
      case EmptyStateType.noData:
        return CupertinoIcons.doc_text;
      case EmptyStateType.noResults:
        return CupertinoIcons.search;
      case EmptyStateType.noHistory:
        return CupertinoIcons.clock;
      case EmptyStateType.noMeals:
        return CupertinoIcons.camera;
      case EmptyStateType.noProgress:
        return CupertinoIcons.chart_bar;
    }
  }

  Color get _getIconColor {
    switch (emptyStateType) {
      case EmptyStateType.firstTime:
        return AppColors.primary;
      case EmptyStateType.noData:
        return AppColors.neutral;
      case EmptyStateType.noResults:
        return AppColors.warning;
      case EmptyStateType.noHistory:
        return AppColors.neutral;
      case EmptyStateType.noMeals:
        return AppColors.primary;
      case EmptyStateType.noProgress:
        return AppColors.success;
    }
  }

  List<String> get _getTips {
    switch (emptyStateType) {
      case EmptyStateType.firstTime:
        return [
          'Take clear photos of your meals for better analysis',
          'Log meals consistently to see your progress',
          'Set realistic protein goals based on your activity level'
        ];
      case EmptyStateType.noData:
        return [
          'Check your internet connection',
          'Try refreshing the page',
          'Contact support if the issue persists'
        ];
      case EmptyStateType.noResults:
        return [
          'Try different search terms',
          'Check your spelling',
          'Use broader search criteria'
        ];
      case EmptyStateType.noHistory:
        return [
          'Take a photo of your next meal',
          'Use the quick add feature for manual entry',
          'Set up meal reminders to stay consistent'
        ];
      case EmptyStateType.noMeals:
        return [
          'Point your camera at your meal',
          'Ensure good lighting for better results',
          'Try different angles if detection fails'
        ];
      case EmptyStateType.noProgress:
        return [
          'Log meals for at least 3 days',
          'Set achievable daily protein targets',
          'Track your progress consistently'
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(_getTitle),
        backgroundColor: AppColors.background,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Illustration/Icon
              if (showIllustration) ...[
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: _getIconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(70),
                  ),
                  child: Icon(
                    _getIcon,
                    size: 70,
                    color: _getIconColor,
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
              
              // Title
              Text(
                _getTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                _getMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Action Button
              if (onActionPressed != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: _getIconColor,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: onActionPressed,
                    child: Text(
                      _getActionText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
              
              // Tips Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.lightbulb,
                          color: _getIconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Helpful Tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ..._getTips.map((tip) => _buildTipItem(tip)),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: _getIconColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
