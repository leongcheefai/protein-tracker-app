import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'pricing_plans_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final SubscriptionPlan plan;
  final SubscriptionPeriod period;
  final double price;

  const PaymentSuccessScreen({
    super.key,
    required this.plan,
    required this.period,
    required this.price,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _celebrationController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    ));
    
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.bounceOut,
    ));
    
    _startAnimations();
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _checkmarkController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _celebrationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildSuccessAnimation(),
              const SizedBox(height: 40),
              _buildWelcomeMessage(),
              const SizedBox(height: 24),
              _buildTrialInformation(),
              const SizedBox(height: 40),
              _buildNextSteps(),
              const Spacer(),
              _buildAccountManagement(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Column(
      children: [
        // Checkmark animation
        AnimatedBuilder(
          animation: _checkmarkAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _checkmarkAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.checkmark,
                  size: 60,
                  color: CupertinoColors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        // Celebration animation
        AnimatedBuilder(
          animation: _celebrationAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _celebrationAnimation.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.star_fill,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    CupertinoIcons.star_fill,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    CupertinoIcons.star_fill,
                    color: AppColors.warning,
                    size: 24,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        const Text(
          'Welcome to Protein Pace Pro!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Your subscription has been activated successfully. You now have access to all premium features.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTrialInformation() {
    final trialEndDate = DateTime.now().add(const Duration(days: 7));
    final formattedDate = '${trialEndDate.day}/${trialEndDate.month}/${trialEndDate.year}';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.calendar,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          const Text(
            '7-Day Free Trial Started',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trial ends on $formattedDate',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.period == SubscriptionPeriod.monthly ? 'Monthly' : 'Annual'} billing: \$${widget.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            onPressed: _explorePremiumFeatures,
            child: const Text(
              'Explore Premium Features',
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
            onPressed: _continueToApp,
            child: const Text(
              'Continue to App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountManagement() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _manageSubscription,
          child: const Text(
            'Manage Subscription',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You can manage your subscription anytime in the app settings.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _explorePremiumFeatures() {
    // Navigate to a premium features showcase screen
    // For now, we'll just show a dialog
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Premium Features'),
        content: const Text(
          '• Unlimited history & data export\n'
          '• Advanced analytics & insights\n'
          '• Custom protein goals\n'
          '• Meal planning & scheduling\n'
          '• Priority support\n'
          '• Ad-free experience',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Got it!'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _continueToApp() {
    // Navigate back to the main app
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _manageSubscription() {
    // Navigate to subscription management
    // For now, we'll show a dialog
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Subscription Management'),
        content: const Text(
          'You can manage your subscription, view billing history, and update payment methods in the app settings.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
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
