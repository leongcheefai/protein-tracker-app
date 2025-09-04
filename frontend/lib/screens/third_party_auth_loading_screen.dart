import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';

enum AuthProvider {
  google,
  apple,
}

class ThirdPartyAuthLoadingScreen extends StatefulWidget {
  final AuthProvider provider;
  final VoidCallback? onCancel;
  
  const ThirdPartyAuthLoadingScreen({
    super.key,
    required this.provider,
    this.onCancel,
  });

  @override
  State<ThirdPartyAuthLoadingScreen> createState() => _ThirdPartyAuthLoadingScreenState();
}

class _ThirdPartyAuthLoadingScreenState extends State<ThirdPartyAuthLoadingScreen> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  bool _isLoading = true;
  String? _errorMessage;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAuthentication();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
    
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  void _startAuthentication() async {
    try {
      // Simulate authentication steps
      setState(() {
        _statusMessage = 'Connecting to ${_getProviderName()}...';
      });
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _statusMessage = 'Verifying your account...';
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      
      setState(() {
        _statusMessage = 'Signing you in...';
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Simulate success
      if (mounted) {
        _handleAuthSuccess();
      }
    } catch (e) {
      if (mounted) {
        _handleAuthError(e.toString());
      }
    }
  }

  void _handleAuthSuccess() {
    setState(() {
      _isLoading = false;
      _statusMessage = 'Welcome to Fuelie!';
    });
    
    // Navigate to onboarding after a brief success display
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        // Navigate to onboarding flow for new authenticated users
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    });
  }

  void _handleAuthError(String error) {
    setState(() {
      _isLoading = false;
      _errorMessage = _getErrorMessage(error);
    });
  }

  String _getProviderName() {
    switch (widget.provider) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
    }
  }

  String _getErrorMessage(String error) {
    switch (widget.provider) {
      case AuthProvider.google:
        return 'Failed to sign in with Google. Please try again.';
      case AuthProvider.apple:
        return 'Failed to sign in with Apple. Please try again.';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

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
              // Provider Logo
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _getProviderColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _getProviderColor().withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: _buildProviderIcon(),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Provider Name
              Text(
                _getProviderName(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Status Message
              Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Loading Indicator
              if (_isLoading) ...[
                AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value * 2 * 3.14159,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CupertinoActivityIndicator(
                          radius: 20,
                          color: _getProviderColor(),
                        ),
                      ),
                    );
                  },
                ),
              ] else if (_errorMessage != null) ...[
                // Error State
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    color: AppColors.error,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                // Success State
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    CupertinoIcons.checkmark,
                    color: AppColors.success,
                    size: 30,
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
              
              // Cancel Button (only show during loading or error)
              if (_isLoading || _errorMessage != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _handleCancel,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _errorMessage != null ? 'Try Again' : 'Cancel',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProviderIcon() {
    switch (widget.provider) {
      case AuthProvider.google:
        return Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      case AuthProvider.apple:
        return Center(
          child: _buildAppleLogo(size: 60),
        );
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

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).pop();
    }
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
      ..color = Colors.black
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
