import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';

enum AuthProvider {
  google,
  apple,
}

class AccountLinkingScreen extends StatefulWidget {
  final AuthProvider provider;
  final String email;
  
  const AccountLinkingScreen({
    super.key,
    required this.provider,
    required this.email,
  });

  @override
  State<AccountLinkingScreen> createState() => _AccountLinkingScreenState();
}

class _AccountLinkingScreenState extends State<AccountLinkingScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              const SizedBox(height: 32),
              
              // Provider Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getProviderColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getProviderColor().withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: _buildProviderIcon(),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Link Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'We found an existing account with this email:\n\n'),
                    TextSpan(
                      text: _maskEmail(widget.email),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: '\n\nWould you like to link your '),
                    TextSpan(
                      text: _getProviderName(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getProviderColor(),
                      ),
                    ),
                    const TextSpan(text: ' account with your existing Fuelie account?'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Error Message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Benefits of Linking
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Benefits of linking:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      CupertinoIcons.arrow_2_circlepath,
                      'Sync your data across devices',
                      'Access your progress from any device',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      CupertinoIcons.shield,
                      'Enhanced security',
                      'Use your existing secure login method',
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      CupertinoIcons.bolt,
                      'Faster sign-in',
                      'Skip the password, use your linked account',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Link Account Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _isLoading ? null : _handleLinkAccount,
                  color: _getProviderColor(),
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildProviderIcon(size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Link with ${_getProviderName()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sign in with Password Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _isLoading ? null : _handleSignInWithPassword,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Sign in with password instead',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Create New Account Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _isLoading ? null : _handleCreateNewAccount,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Create new account',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
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
            color: AppColors.primary,
            size: 20,
          ),
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
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderIcon({double size = 40}) {
    switch (widget.provider) {
      case AuthProvider.google:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
              fit: BoxFit.contain,
            ),
          ),
        );
      case AuthProvider.apple:
        return _buildAppleLogo(size: size);
    }
  }

  String _getProviderName() {
    switch (widget.provider) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
    }
  }

  Color _getProviderColor() {
    switch (widget.provider) {
      case AuthProvider.google:
        return const Color(0xFF4285F4); // Google Blue
      case AuthProvider.apple:
        return Colors.black;
    }
  }

  String _maskEmail(String email) {
    if (email.length <= 3) return email;
    
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }
    
    return '${username[0]}***${username[username.length - 1]}@$domain';
  }

  void _handleLinkAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement account linking with Firebase Auth
      // For now, simulate loading
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate success - navigate to onboarding
      if (mounted) {
        // Navigate to onboarding flow for linked accounts
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to link account. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _handleSignInWithPassword() {
    Navigator.of(context).pushReplacementNamed('/email-login');
  }

  void _handleCreateNewAccount() {
    Navigator.of(context).pushReplacementNamed('/email-signup');
  }

  Widget _buildAppleLogo({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: AppleLogoPainter(),
    );
  }
}

class AppleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Apple logo path - simplified version
    // This creates the classic Apple logo shape
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.cubicTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.1, size.height * 0.3,
      size.width * 0.1, size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.1, size.height * 0.7,
      size.width * 0.3, size.height * 0.9,
      size.width * 0.5, size.height * 0.9,
    );
    path.cubicTo(
      size.width * 0.7, size.height * 0.9,
      size.width * 0.9, size.height * 0.7,
      size.width * 0.9, size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.9, size.height * 0.3,
      size.width * 0.7, size.height * 0.1,
      size.width * 0.5, size.height * 0.1,
    );
    
    // Add the leaf
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.05,
      size.width * 0.65, size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.1,
      size.width * 0.5, size.height * 0.1,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
