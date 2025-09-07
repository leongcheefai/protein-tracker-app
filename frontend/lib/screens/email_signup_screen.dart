import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import '../utils/error_handler.dart';

class EmailSignupScreen extends StatefulWidget {
  const EmailSignupScreen({super.key});

  @override
  State<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends State<EmailSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.neutral.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text(
          'Create Account',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
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
                
                // Full Name Field
                _buildSectionTitle('Full Name'),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Enter your full name',
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Email Field
                _buildSectionTitle('Email Address'),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _emailController,
                  placeholder: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Password Field
                _buildSectionTitle('Password'),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: 'Create a password',
                  obscureText: _obscurePassword,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  suffix: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                _buildPasswordStrengthIndicator(),
                
                const SizedBox(height: 24),
                
                // Confirm Password Field
                _buildSectionTitle('Confirm Password'),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _confirmPasswordController,
                  placeholder: 'Confirm your password',
                  obscureText: _obscureConfirmPassword,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  suffix: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    child: Icon(
                      _obscureConfirmPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Terms and Privacy Agreement
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _agreeToTerms = !_agreeToTerms;
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _agreeToTerms ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _agreeToTerms ? AppColors.primary : AppColors.neutral,
                            width: 2,
                          ),
                        ),
                        child: _agreeToTerms
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                color: Colors.white,
                                size: 12,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreeToTerms = !_agreeToTerms;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
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
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    Color color;
    String text;
    switch (strength) {
      case 0:
      case 1:
        color = AppColors.error;
        text = 'Weak';
        break;
      case 2:
      case 3:
        color = AppColors.warning;
        text = 'Medium';
        break;
      case 4:
      case 5:
        color = AppColors.success;
        text = 'Strong';
        break;
      default:
        color = AppColors.neutral;
        text = '';
    }
    
    return Row(
      children: [
        Text(
          'Password strength: ',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: index < strength ? color : AppColors.neutral.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ],
    );
  }

  void _handleSignup() async {
    // Manual validation since CupertinoTextField doesn't have validator
    String? nameError = _validateName(_nameController.text);
    String? emailError = _validateEmail(_emailController.text);
    String? passwordError = _validatePassword(_passwordController.text);
    String? confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text, _passwordController.text);
    
    if (nameError != null || emailError != null || passwordError != null || confirmPasswordError != null) {
      setState(() {
        _errorMessage = nameError ?? emailError ?? passwordError ?? confirmPasswordError;
      });
      return;
    }
    
    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the Terms of Service and Privacy Policy';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success) {
        // Signup successful - now update profile with display name
        if (authProvider.currentUser != null) {
          final updatedProfile = authProvider.currentUser!.copyWith(
            displayName: _nameController.text.trim(),
          );
          await authProvider.updateUserProfile(updatedProfile);
        }
        
        // AuthProvider will handle navigation via auth state listener
        if (mounted) {
          // Clear the form
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        }
      } else {
        // Show error from AuthProvider
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Sign up failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create account. Please try again.';
        _isLoading = false;
      });
    }
  }

  String? _validateName(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? _validateConfirmPassword(String value, String password) {
    if (value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _navigateToEmailLogin() {
    Navigator.of(context).pushReplacementNamed('/email-login');
  }
}
