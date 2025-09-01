import 'package:flutter/cupertino.dart';

enum SubscriptionPlan { free, pro }
enum SubscriptionPeriod { monthly, annual }

class PricingPlansScreen extends StatefulWidget {
  final SubscriptionPlan? currentPlan;
  final bool isTrialUser;
  final VoidCallback? onClose;

  const PricingPlansScreen({
    super.key,
    this.currentPlan = SubscriptionPlan.free,
    this.isTrialUser = false,
    this.onClose,
  });

  @override
  State<PricingPlansScreen> createState() => _PricingPlansScreenState();
}

class _PricingPlansScreenState extends State<PricingPlansScreen> {
  SubscriptionPeriod _selectedPeriod = SubscriptionPeriod.annual;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Choose Your Plan'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.xmark),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildPlanCards(),
              const SizedBox(height: 30),
              _buildFeatureComparison(),
              const SizedBox(height: 30),
              _buildTermsAndPrivacy(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          CupertinoIcons.star_fill,
          size: 60,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        const Text(
          'Unlock Your Full Potential',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose the plan that fits your fitness journey',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlanCards() {
    return Column(
      children: [
        _buildFreePlanCard(),
        const SizedBox(height: 16),
        _buildProPlanCard(),
      ],
    );
  }

  Widget _buildFreePlanCard() {
    final isCurrentPlan = widget.currentPlan == SubscriptionPlan.free;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan ? AppColors.primary : AppColors.neutral.withOpacity(0.3),
          width: isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neutral.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Free',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isCurrentPlan) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Basic Tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureList([
            'Photo-based food tracking',
            'Basic daily progress',
            '7-day history',
            'Standard protein goals',
            'Basic analytics',
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: isCurrentPlan ? AppColors.neutral : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              onPressed: isCurrentPlan ? null : () {
                // Stay on free plan
                Navigator.of(context).pop();
              },
              child: Text(
                isCurrentPlan ? 'Current Plan' : 'Continue with Free',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCurrentPlan ? AppColors.textSecondary : CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProPlanCard() {
    final isCurrentPlan = widget.currentPlan == SubscriptionPlan.pro;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: const Text(
                  'Pro',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Most Popular',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Premium Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildPricingSection(),
          const SizedBox(height: 12),
          _buildFeatureList([
            'Unlimited history & data export',
            'Advanced analytics & insights',
            'Custom protein goals',
            'Meal planning & scheduling',
            'Priority support',
            'Ad-free experience',
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              onPressed: _isLoading ? null : _handleProSubscription,
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : Text(
                      isCurrentPlan ? 'Manage Subscription' : 'Start Free Trial',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Column(
      children: [
        Row(
          children: [
            CupertinoSegmentedControl<SubscriptionPeriod>(
              children: const {
                SubscriptionPeriod.monthly: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Monthly'),
                ),
                SubscriptionPeriod.annual: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Annual'),
                ),
              },
              groupValue: _selectedPeriod,
              onValueChanged: (SubscriptionPeriod value) {
                setState(() {
                  _selectedPeriod = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              _selectedPeriod == SubscriptionPeriod.monthly ? '\$4.99' : '\$39.99',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedPeriod == SubscriptionPeriod.monthly ? '/month' : '/year',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            if (_selectedPeriod == SubscriptionPeriod.annual) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Save 33%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_selectedPeriod == SubscriptionPeriod.annual)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Billed annually (\$3.33/month)',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureList(List<String> features) {
    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              size: 20,
              color: AppColors.success,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildFeatureComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feature Comparison',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _buildComparisonRow('Feature', 'Free', 'Pro', isHeader: true),
              _buildComparisonRow('Photo Tracking', '✓', '✓'),
              _buildComparisonRow('Daily Progress', '✓', '✓'),
              _buildComparisonRow('History', '7 days', 'Unlimited'),
              _buildComparisonRow('Data Export', '✗', '✓'),
              _buildComparisonRow('Advanced Analytics', '✗', '✓'),
              _buildComparisonRow('Custom Goals', '✗', '✓'),
              _buildComparisonRow('Meal Planning', '✗', '✓'),
              _buildComparisonRow('Priority Support', '✗', '✓'),
              _buildComparisonRow('Ad-free Experience', '✗', '✓'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String feature, String free, String pro, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutral.withOpacity(0.2),
            width: isHeader ? 2 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              free,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? AppColors.primary : (free == '✓' ? AppColors.success : AppColors.textSecondary),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              pro,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? AppColors.primary : (pro == '✓' ? AppColors.success : AppColors.textSecondary),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Column(
      children: [
        const Text(
          '7-day free trial • Cancel anytime',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // Navigate to terms of service
              },
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Text(
              ' • ',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // Navigate to privacy policy
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleProSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Navigate to payment processing screen
      await Navigator.of(context).pushNamed(
        '/payment-processing',
        arguments: {
          'plan': SubscriptionPlan.pro,
          'period': _selectedPeriod,
          'price': _selectedPeriod == SubscriptionPeriod.monthly ? 4.99 : 39.99,
        },
      );
    } catch (e) {
      _showErrorDialog('Failed to process payment. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
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
