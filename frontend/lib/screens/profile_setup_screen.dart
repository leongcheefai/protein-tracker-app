import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../main.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String? name;
  final String email;
  final String? profileImageUrl;
  final bool isReturningUser;

  const ProfileSetupScreen({
    super.key,
    this.name,
    required this.email,
    this.profileImageUrl,
    this.isReturningUser = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    // Pre-fill name if provided from auth provider
    _nameController.text = widget.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        leading: widget.isReturningUser
            ? CupertinoNavigationBarBackButton(
                color: AppColors.primary,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        middle: Text(
          'Complete Your Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      child: SafeArea(
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
              
              // Profile Photo Section
              Center(
                child: Column(
                  children: [
                    // Profile Photo
                    GestureDetector(
                      onTap: _handleProfilePhotoTap,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: AppColors.neutral.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _selectedImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(58),
                                child: Image.file(
                                  File(_selectedImagePath!),
                                  width: 116,
                                  height: 116,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : widget.profileImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(58),
                                    child: Image.network(
                                      widget.profileImageUrl!,
                                      width: 116,
                                      height: 116,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildDefaultAvatar();
                                      },
                                    ),
                                  )
                                : _buildDefaultAvatar(),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Photo Upload Text
                    GestureDetector(
                      onTap: _handleProfilePhotoTap,
                      child: Text(
                        _selectedImagePath != null || widget.profileImageUrl != null
                            ? 'Change Photo'
                            : 'Add Photo',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Optional',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Basic Info Section
              Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Name Field
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
              
              // Email Field (Read-only)
              _buildSectionTitle('Email Address'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.lock_fill,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Email cannot be changed here',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const Spacer(),
              
              // Action Buttons
              Column(
                children: [
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Skip Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _isLoading ? null : _handleSkip,
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(58),
      ),
      child: Icon(
        CupertinoIcons.person_fill,
        size: 50,
        color: AppColors.primary,
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

  void _handleProfilePhotoTap() async {
    // Show action sheet for photo selection
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Photo'),
        message: const Text('Choose how you want to add your profile photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.camera, size: 20),
                const SizedBox(width: 8),
                const Text('Take Photo'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.photo, size: 20),
                const SizedBox(width: 8),
                const Text('Choose from Gallery'),
              ],
            ),
          ),
          if (_selectedImagePath != null || widget.profileImageUrl != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _removePhoto();
              },
              isDestructiveAction: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.delete, size: 20),
                  const SizedBox(width: 8),
                  const Text('Remove Photo'),
                ],
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _pickImageFromCamera() {
    // TODO: Implement camera functionality
    // For now, simulate photo selection
    setState(() {
      _selectedImagePath = '/path/to/camera/image.jpg';
    });
  }

  void _pickImageFromGallery() {
    // TODO: Implement gallery picker functionality
    // For now, simulate photo selection
    setState(() {
      _selectedImagePath = '/path/to/gallery/image.jpg';
    });
  }

  void _removePhoto() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  void _handleContinue() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your full name';
      });
      return;
    }

    if (_nameController.text.trim().length < 2) {
      setState(() {
        _errorMessage = 'Name must be at least 2 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement profile update logic
      // For now, simulate loading
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // Navigate based on user type
        if (widget.isReturningUser) {
          // Return to previous screen or user home
          Navigator.of(context).pop();
        } else {
          // Navigate to onboarding flow
          Navigator.of(context).pushReplacementNamed('/welcome');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _handleSkip() async {
    if (widget.isReturningUser) {
      // Return to previous screen
      Navigator.of(context).pop();
    } else {
      // Navigate to onboarding flow
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }
}
