import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/auth_provider.dart' as auth_provider;

class AuthenticationWelcomeScreen extends StatefulWidget {
  const AuthenticationWelcomeScreen({super.key});

  @override
  State<AuthenticationWelcomeScreen> createState() => _AuthenticationWelcomeScreenState();
}

class _AuthenticationWelcomeScreenState extends State<AuthenticationWelcomeScreen> {
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
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.heart_fill,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Welcome Title
              Text(
                'Welcome to Fuelie',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'Track protein intake with just a photo',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
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
              
              // Authentication Options
              _buildAuthButton(
                context,
                icon: CupertinoIcons.mail,
                title: 'Continue with Google',
                subtitle: 'Sign in with your Google account',
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.neutral.withValues(alpha: 0.3),
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                showGoogleIcon: true,
              ),
              
              const SizedBox(height: 16),
              
              // Apple Sign In (iOS only)
              if (Platform.isIOS)
                _buildAuthButton(
                  context,
                  icon: CupertinoIcons.app_badge,
                  title: 'Continue with Apple',
                  subtitle: 'Sign in with your Apple ID',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  onPressed: _isLoading ? null : _handleAppleSignIn,
                  showAppleIcon: true,
                ),
              
              if (Platform.isIOS) const SizedBox(height: 16),
              
              // Email Signup
              _buildAuthButton(
                context,
                icon: CupertinoIcons.mail,
                title: 'Sign up with Email',
                subtitle: 'Create account with email and password',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                borderColor: AppColors.primary,
                onPressed: _isLoading ? null : _navigateToEmailSignup,
              ),
              
              const SizedBox(height: 24),
              
              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : _navigateToEmailLogin,
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Privacy Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.shield,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your data is secure and private',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildAuthButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback? onPressed,
    bool showGoogleIcon = false,
    bool showAppleIcon = false,
  }) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            if (showGoogleIcon)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              )
            else if (showAppleIcon)
              _buildAppleLogo(size: 24)
            else
              Icon(
                icon,
                color: textColor,
                size: 24,
              ),
            
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Loading indicator
            if (_isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CupertinoActivityIndicator(
                  radius: 10,
                  color: textColor,
                ),
              )
            else
              Icon(
                CupertinoIcons.chevron_right,
                color: textColor.withValues(alpha: 0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProviderInstance = Provider.of<auth_provider.AuthProvider>(context, listen: false);
      final success = await authProviderInstance.signInWithGoogle();
      
      if (!success) {
        setState(() {
          _errorMessage = authProviderInstance.errorMessage ?? 'Google sign in failed. Please try again.';
          _isLoading = false;
        });
      }
      // If successful, AuthProvider will handle navigation
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProviderInstance = Provider.of<auth_provider.AuthProvider>(context, listen: false);
      final success = await authProviderInstance.signInWithApple();
      
      if (!success) {
        setState(() {
          _errorMessage = authProviderInstance.errorMessage ?? 'Apple sign in failed. Please try again.';
          _isLoading = false;
        });
      }
      // If successful, AuthProvider will handle navigation
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _navigateToEmailSignup() {
    Navigator.of(context).pushNamed('/email-signup');
  }

  void _navigateToEmailLogin() {
    Navigator.of(context).pushNamed('/email-login');
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
