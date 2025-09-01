import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'pricing_plans_screen.dart';

enum UnlockTrigger {
  historyLimit,
  analyticsLimit,
  exportLimit,
  customGoalsLimit,
  mealPlanningLimit,
  generalUpgrade,
}

class PremiumFeaturesUnlockScreen extends StatefulWidget {
  final UnlockTrigger trigger;
  final String? customMessage;
  final VoidCallback? onSkip;

  const PremiumFeaturesUnlockScreen({
    super.key,
    required this.trigger,
    this.customMessage,
    this.onSkip,
  });

  @override
  State<PremiumFeaturesUnlockScreen> createState() => _PremiumFeaturesUnlockScreenState();
}

class _PremiumFeaturesUnlockScreenState extends State<PremiumFeaturesUnlockScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _featureController;
  late Animation<double> _heroAnimation;
  late Animation<double> _featureAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _featureController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.elasticOut,
    ));
    
    _featureAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featureController,
      curve: Curves.easeInOut,
    ));
    
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featureController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
    
    _startAnimations();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _heroController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _featureController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              _buildHeroSection(),
              const SizedBox(height: 40),
              _buildTriggerMessage(),
              const SizedBox(height: 30),
              _buildFeatureHighlights(),
              const SizedBox(height: 40),
              _buildActionButtons(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _heroAnimation.value,
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.star_fill,
                  size: 60,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Unlock Premium Features!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTriggerMessage() {
    String message = widget.customMessage ?? _getDefaultMessage();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            _getTriggerIcon(),
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    return AnimatedBuilder(
      animation: _featureAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _featureAnimation.value)),
          child: Opacity(
            opacity: _featureAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premium Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  title: 'Advanced Analytics & Insights',
                  description: 'Get detailed progress reports and trends',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: CupertinoIcons.clock_fill,
                  title: 'Unlimited History & Data Export',
                  description: 'Access all your data and export anytime',
                ),
                const SizedBox(height: 12),
                                 _buildFeatureItem(
                   icon: CupertinoIcons.location_circle,
                   title: 'Custom Protein Goals',
                   description: 'Set personalized targets for your goals',
                 ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: CupertinoIcons.calendar,
                  title: 'Meal Planning & Scheduling',
                  description: 'Plan your meals and track macros',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                  title: 'Priority Support',
                  description: 'Get help faster with priority support',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: CupertinoIcons.xmark_circle,
                  title: 'Ad-free Experience',
                  description: 'Enjoy a clean, distraction-free app',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _buttonAnimation.value)),
          child: Opacity(
            opacity: _buttonAnimation.value,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _upgradeToPro,
                    child: const Text(
                      'Upgrade to Pro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _maybeLater,
                    child: const Text(
                      'Maybe Later',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _learnMore,
                  child: const Text(
                    'Learn More About Pro',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDefaultMessage() {
    switch (widget.trigger) {
      case UnlockTrigger.historyLimit:
        return 'You\'ve reached the 7-day history limit. Upgrade to Pro for unlimited access to all your data.';
      case UnlockTrigger.analyticsLimit:
        return 'Advanced analytics are available with Pro. Get detailed insights into your protein intake patterns.';
      case UnlockTrigger.exportLimit:
        return 'Data export is a Pro feature. Download your complete nutrition history anytime.';
      case UnlockTrigger.customGoalsLimit:
        return 'Custom protein goals are available with Pro. Set personalized targets for your fitness journey.';
      case UnlockTrigger.mealPlanningLimit:
        return 'Meal planning and scheduling are Pro features. Plan your nutrition for optimal results.';
      case UnlockTrigger.generalUpgrade:
        return 'Unlock the full potential of Protein Pace with premium features designed for serious fitness enthusiasts.';
      default:
        return 'Unlock the full potential of Protein Pace with premium features designed for serious fitness enthusiasts.';
    }
  }

  IconData _getTriggerIcon() {
    switch (widget.trigger) {
      case UnlockTrigger.historyLimit:
        return CupertinoIcons.clock;
      case UnlockTrigger.analyticsLimit:
        return CupertinoIcons.chart_bar_alt_fill;
      case UnlockTrigger.exportLimit:
        return CupertinoIcons.arrow_down_doc;
      case UnlockTrigger.customGoalsLimit:
        return CupertinoIcons.location_circle;
      case UnlockTrigger.mealPlanningLimit:
        return CupertinoIcons.calendar;
      case UnlockTrigger.generalUpgrade:
        return CupertinoIcons.star_fill;
      default:
        return CupertinoIcons.star_fill;
    }
  }

  void _upgradeToPro() {
    Navigator.of(context).pushNamed(
      '/pricing-plans',
      arguments: {
        'currentPlan': SubscriptionPlan.free,
        'isTrialUser': false,
        'trigger': widget.trigger,
      },
    );
  }

  void _maybeLater() {
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _learnMore() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About Protein Pace Pro'),
        content: const Text(
          'Pro features include:\n\n'
          '• Unlimited history & data export\n'
          '• Advanced analytics & insights\n'
          '• Custom protein goals\n'
          '• Meal planning & scheduling\n'
          '• Priority support\n'
          '• Ad-free experience\n\n'
          'Start with a 7-day free trial, then \$4.99/month or \$39.99/year.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Upgrade Now'),
            onPressed: () {
              Navigator.of(context).pop();
              _upgradeToPro();
            },
          ),
        ],
      ),
    );
  }
}

// App Colors (same as main.dart)
class AppColors {
  static const primary = Color(0xFF4F7C8A);
  static const secondary = Color(0xFF7FB069);
  static const accent = Color(0xFFF5F1E8);
  static const success = Color(0xFF7FB069);
  static const warning = Color(0xFFE6A23C);
  static const error = Color(0xFFE74C3C);
  static const neutral = Color(0xFF8B8B8B);
  static const background = Color(0xFFFDFCFA);
  static const secondaryBackground = Color(0xFFFAF8F3);
  static const textPrimary = Color(0xFF2C3E50);
  static const textSecondary = Color(0xFF7F8C8D);
}
