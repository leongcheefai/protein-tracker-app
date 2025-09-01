import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'pricing_plans_screen.dart';

enum PaymentMethod { creditCard, applePay, googlePay }

class PaymentProcessingScreen extends StatefulWidget {
  final SubscriptionPlan plan;
  final SubscriptionPeriod period;
  final double price;

  const PaymentProcessingScreen({
    super.key,
    required this.plan,
    required this.period,
    required this.price,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  bool _savePaymentMethod = true;
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _isProcessing = false;
  bool _isApplePayAvailable = false;
  bool _isGooglePayAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentMethods();
    _loadUserData();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _checkPaymentMethods() {
    // In a real app, you would check platform capabilities
    // For now, we'll simulate based on platform
    setState(() {
      _isApplePayAvailable = true; // Simulate iOS
      _isGooglePayAvailable = true; // Simulate Android
    });
  }

  void _loadUserData() {
    // In a real app, you would load user data from your provider
    // For now, we'll use placeholder data
    _nameController.text = 'John Doe';
    _emailController.text = 'john.doe@example.com';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Payment'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPlanSummary(),
                const SizedBox(height: 30),
                _buildPaymentMethodSelection(),
                const SizedBox(height: 20),
                if (_selectedPaymentMethod == PaymentMethod.creditCard) ...[
                  _buildCreditCardForm(),
                  const SizedBox(height: 20),
                ],
                _buildBillingInformation(),
                const SizedBox(height: 20),
                _buildTermsAndConditions(),
                const SizedBox(height: 30),
                _buildActionButtons(),
                const SizedBox(height: 20),
                _buildSecurityBadges(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
              Text(
                widget.period == SubscriptionPeriod.monthly ? 'Monthly' : 'Annual',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '7-day free trial • Cancel anytime',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (_isApplePayAvailable) ...[
          _buildPaymentOption(
            PaymentMethod.applePay,
            'Apple Pay',
            CupertinoIcons.creditcard,
            'Pay securely with Apple Pay',
          ),
          const SizedBox(height: 12),
        ],
        if (_isGooglePayAvailable) ...[
          _buildPaymentOption(
            PaymentMethod.googlePay,
            'Google Pay',
            CupertinoIcons.creditcard,
            'Pay securely with Google Pay',
          ),
          const SizedBox(height: 12),
        ],
        _buildPaymentOption(
          PaymentMethod.creditCard,
          'Credit Card',
          CupertinoIcons.creditcard,
          'Pay with credit or debit card',
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    PaymentMethod method,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: _cardNumberController,
          placeholder: 'Card Number',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberFormatter(),
          ],
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(16),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _expiryController,
                placeholder: 'MM/YY',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryFormatter(),
                ],
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutral.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CupertinoTextField(
                controller: _cvvController,
                placeholder: 'CVV',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutral.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CupertinoSwitch(
              value: _savePaymentMethod,
              onChanged: (value) {
                setState(() {
                  _savePaymentMethod = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Save payment method for future use',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillingInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billing Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: _nameController,
          placeholder: 'Full Name',
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(16),
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: _emailController,
          placeholder: 'Email Address',
          keyboardType: TextInputType.emailAddress,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(16),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CupertinoSwitch(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'I agree to the Terms of Service',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CupertinoSwitch(
              value: _agreeToPrivacy,
              onChanged: (value) {
                setState(() {
                  _agreeToPrivacy = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'I agree to the Privacy Policy',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Your subscription will automatically renew unless cancelled at least 24 hours before the end of the current period.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isFormValid = _validateForm();
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            onPressed: _isProcessing || !isFormValid ? null : _processPayment,
            child: _isProcessing
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : const Text(
                    'Start Free Trial',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(12),
            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
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

  Widget _buildSecurityBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          CupertinoIcons.lock_shield,
          size: 20,
          color: AppColors.success,
        ),
        const SizedBox(width: 8),
        const Text(
          'SSL Secured',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 20),
        const Icon(
          CupertinoIcons.checkmark_shield,
          size: 20,
          color: AppColors.success,
        ),
        const SizedBox(width: 8),
        const Text(
          'PCI Compliant',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  bool _validateForm() {
    if (!_agreeToTerms || !_agreeToPrivacy) return false;
    
    if (_selectedPaymentMethod == PaymentMethod.creditCard) {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty ||
          _nameController.text.isEmpty ||
          _emailController.text.isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to success screen
      await Navigator.of(context).pushReplacementNamed(
        '/payment-success',
        arguments: {
          'plan': widget.plan,
          'period': widget.period,
          'price': widget.price,
        },
      );
    } catch (e) {
      _showErrorDialog('Payment failed. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Payment Error'),
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

// Custom text formatters
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formatted = text.replaceAllMapped(
      RegExp(r'(\d{4})'),
      (Match match) => '${match[1]} ',
    ).trim();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length >= 2) {
      final formatted = '${text.substring(0, 2)}/${text.substring(2)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return newValue;
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
