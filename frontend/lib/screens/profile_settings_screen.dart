import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/user_settings_provider.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final double height;
  final double weight;
  final double trainingMultiplier;
  final String goal;
  final double dailyProteinTarget;
  final String? userEmail;
  final String? userName;
  final String? authProvider; // 'email', 'google', 'apple'
  final String? profileImageUrl;

  const ProfileSettingsScreen({
    super.key,
    required this.height,
    required this.weight,
    required this.trainingMultiplier,
    required this.goal,
    required this.dailyProteinTarget,
    this.userEmail,
    this.userName,
    this.authProvider,
    this.profileImageUrl,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late double _selectedTrainingMultiplier;
  late String _selectedGoal;
  late double _dailyProteinTarget;
  File? _profilePhoto;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoadingPhoto = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers first
    _heightController = TextEditingController(text: widget.height.toString());
    _weightController = TextEditingController(text: widget.weight.toString());
    _nameController = TextEditingController(text: widget.userName ?? '');
    _emailController = TextEditingController(text: widget.userEmail ?? '');
    
    // Initialize other state variables
    _selectedTrainingMultiplier = widget.trainingMultiplier;
    _selectedGoal = widget.goal;
    _dailyProteinTarget = widget.dailyProteinTarget;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateDailyTarget() {
    double weight = double.tryParse(_weightController.text) ?? widget.weight;
    
    // Calculate new daily protein target
    double newTarget = weight * _selectedTrainingMultiplier;
    
    // Apply goal multiplier
    switch (_selectedGoal) {
      case 'bulk':
        newTarget *= 1.1; // 10% increase for bulking
        break;
      case 'cut':
        newTarget *= 0.9; // 10% decrease for cutting
        break;
      default: // maintain
        break;
    }
    
    setState(() {
      _dailyProteinTarget = newTarget;
    });
  }

  void _saveChanges() {
    // Validate inputs
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);
    
    if (height == null || weight == null) {
      _showErrorDialog('Please enter valid height and weight values.');
      return;
    }
    
    if (height < 100 || height > 250) {
      _showErrorDialog('Height must be between 100-250 cm.');
      return;
    }
    
    if (weight < 30 || weight > 200) {
      _showErrorDialog('Weight must be between 30-200 kg.');
      return;
    }

    // Update provider
    final settingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
    settingsProvider.updateProfile(
      height: height,
      weight: weight,
      trainingMultiplier: _selectedTrainingMultiplier,
      goal: _selectedGoal,
      dailyProteinTarget: _dailyProteinTarget,
    );

    // TODO: Save profile photo to local storage or cloud storage
    // For now, we'll just show success message
    if (_profilePhoto != null) {
      // In a real app, you would save the photo here
      // For example: await _saveProfilePhoto(_profilePhoto!);
    }

    // Show success and navigate back
    _showSuccessDialog();
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Invalid Input'),
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

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: const Text('Your profile has been updated successfully!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Return true to indicate success
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Profile Settings'),
        backgroundColor: CupertinoColors.systemBackground,
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section
              _buildProfilePhotoSection(),
              
              const SizedBox(height: 24),
              
              // Login Details Section
              _buildLoginDetailsSection(),
              
              const SizedBox(height: 24),
              
              // Height & Weight Section
              _buildHeightWeightSection(),
              
              const SizedBox(height: 24),
              
              // Training Frequency Section
              _buildTrainingFrequencySection(),
              
              const SizedBox(height: 24),
              
              // Goal Section
              _buildGoalSection(),
              
              const SizedBox(height: 24),
              
              // Daily Target Display
              Center(
                child: _buildDailyTargetSection(),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () {
              _showPhotoPickerDialog();
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                  width: 2,
                ),
              ),
                          child: _isLoadingPhoto
                ? const CupertinoActivityIndicator()
                : _profilePhoto != null
                    ? ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CupertinoColors.activeBlue,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Image.file(
                            _profilePhoto!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const Icon(
                        CupertinoIcons.person_fill,
                        size: 50,
                        color: CupertinoColors.systemGrey,
                      ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _profilePhoto != null ? 'Tap to change photo' : 'Tap to add photo',
            style: TextStyle(
              fontSize: 14,
              color: _profilePhoto != null ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        // Name Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _nameController,
              placeholder: 'Enter your full name',
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.black,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email Address',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.userEmail?.isNotEmpty == true ? widget.userEmail! : 'No email set',
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.lock_fill,
                    color: CupertinoColors.systemGrey,
                    size: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Email cannot be changed here',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Authentication Method
        _buildAuthMethodSection(),
        
        const SizedBox(height: 16),
        
        // Account Actions
        _buildAccountActionsSection(),
      ],
    );
  }

  Widget _buildAuthMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign-in Method',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.systemGrey4),
          ),
          child: Row(
            children: [
              Icon(
                _getAuthProviderIcon(),
                color: _getAuthProviderColor(),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAuthProviderName(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    Text(
                      _getAuthProviderDescription(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Actions',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 8),
        
        // Password Change (only for email users)
        if (widget.authProvider == 'email') ...[
          _buildActionButton(
            icon: CupertinoIcons.lock_rotation,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: _handleChangePassword,
          ),
          const SizedBox(height: 8),
        ],
        
        // Link/Unlink Account
        _buildActionButton(
          icon: widget.authProvider == 'email' ? CupertinoIcons.link : CupertinoIcons.minus_circle,
          title: widget.authProvider == 'email' ? 'Link Social Account' : 'Unlink Account',
          subtitle: widget.authProvider == 'email' 
              ? 'Connect Google or Apple for easier sign-in'
              : 'Remove social account connection',
          onTap: widget.authProvider == 'email' ? _handleLinkAccount : _handleUnlinkAccount,
        ),
        
        const SizedBox(height: 8),
        
        // Account Security
        _buildActionButton(
          icon: CupertinoIcons.shield,
          title: 'Account Security',
          subtitle: 'Manage your account security settings',
          onTap: _handleAccountSecurity,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CupertinoColors.systemGrey4),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: CupertinoColors.activeBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Body Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        // Height Input
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Height (cm)',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    placeholder: '170',
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                    onChanged: (value) => _updateDailyTarget(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weight (kg)',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    placeholder: '70',
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                    onChanged: (value) => _updateDailyTarget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Training Frequency',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        Column(
          children: [
            _buildTrainingOption('Light', '1-2x/week', 1.6, 'Occasional workouts, light activity'),
            _buildTrainingOption('Moderate', '3-4x/week', 1.8, 'Regular training, moderate intensity'),
            _buildTrainingOption('Heavy', '5-6x/week', 2.0, 'Frequent training, high intensity'),
            _buildTrainingOption('Very Heavy', '6-7x/week', 2.2, 'Daily training, cutting phase'),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingOption(String title, String frequency, double multiplier, String description) {
    bool isSelected = _selectedTrainingMultiplier == multiplier;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTrainingMultiplier = multiplier;
        });
        _updateDailyTarget();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? CupertinoColors.activeBlue.withValues(alpha: 0.1) : CupertinoColors.systemBackground,
          border: Border.all(
            color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Center content vertically
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
              ),
              child: isSelected
                  ? const Icon(
                      CupertinoIcons.check_mark,
                      size: 14,
                      color: CupertinoColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        frequency,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${multiplier}g/kg',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitness Goal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildGoalOption('Maintain', 'Keep current muscle mass', 'maintain'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalOption('Bulk', 'Build muscle and strength', 'bulk'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalOption('Cut', 'Lose fat, preserve muscle', 'cut'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalOption(String title, String description, String goalValue) {
    bool isSelected = _selectedGoal == goalValue;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = goalValue;
        });
        _updateDailyTarget();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? CupertinoColors.activeBlue.withValues(alpha: 0.1) : CupertinoColors.systemBackground,
          border: Border.all(
            color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTargetSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        children: [
          const Text(
            'Daily Protein Target',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${_dailyProteinTarget.toStringAsFixed(0)}g protein',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.activeGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your current settings',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: _saveChanges,
        child: const Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showPhotoPickerDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              await _takePhoto();
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              await _pickImageFromGallery();
            },
            child: const Text('Choose from Gallery'),
          ),
          if (_profilePhoto != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _removePhoto();
              },
              isDestructiveAction: true,
              child: const Text('Remove Photo'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isLoadingPhoto = true;
    });
    
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (photo != null) {
        final File photoFile = File(photo.path);
        if (await _validateImageFile(photoFile)) {
          setState(() {
            _profilePhoto = photoFile;
          });
        }
      }
    } catch (e) {
      String errorMessage = 'Failed to take photo';
      if (e.toString().contains('permission')) {
        errorMessage = 'Camera permission denied. Please enable camera access in settings.';
      } else if (e.toString().contains('camera')) {
        errorMessage = 'Camera not available. Please check your device camera.';
      }
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoadingPhoto = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoadingPhoto = true;
    });
    
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        if (await _validateImageFile(imageFile)) {
          setState(() {
            _profilePhoto = imageFile;
          });
        }
      }
    } catch (e) {
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('permission')) {
        errorMessage = 'Gallery permission denied. Please enable photo library access in settings.';
      } else if (e.toString().contains('gallery')) {
        errorMessage = 'Gallery not available. Please check your device photo library.';
      }
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoadingPhoto = false;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _profilePhoto = null;
    });
  }

  Future<bool> _validateImageFile(File imageFile) async {
    try {
      // Check if file exists and is readable
      if (!await imageFile.exists()) {
        _showErrorDialog('Selected image file is not accessible.');
        return false;
      }

      // Check file size (max 5MB)
      final int fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        _showErrorDialog('Image file is too large. Please select an image smaller than 5MB.');
        return false;
      }

      return true;
    } catch (e) {
      _showErrorDialog('Failed to validate image file: ${e.toString()}');
      return false;
    }
  }

  // TODO: Future enhancement - Add image cropping functionality
  // Future<void> _cropImage(File imageFile) async {
  //   // This would integrate with an image cropping library
  //   // For example: image_cropper package
  // }

  // Authentication Provider Helper Methods
  IconData _getAuthProviderIcon() {
    switch (widget.authProvider) {
      case 'google':
        return CupertinoIcons.globe;
      case 'apple':
        return CupertinoIcons.app_badge;
      case 'email':
      default:
        return CupertinoIcons.mail;
    }
  }

  Color _getAuthProviderColor() {
    switch (widget.authProvider) {
      case 'google':
        return const Color(0xFF4285F4); // Google Blue
      case 'apple':
        return CupertinoColors.black;
      case 'email':
      default:
        return CupertinoColors.activeBlue;
    }
  }

  String _getAuthProviderName() {
    switch (widget.authProvider) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple ID';
      case 'email':
      default:
        return 'Email & Password';
    }
  }

  String _getAuthProviderDescription() {
    switch (widget.authProvider) {
      case 'google':
        return 'Signed in with Google account';
      case 'apple':
        return 'Signed in with Apple ID';
      case 'email':
      default:
        return 'Signed in with email and password';
    }
  }

  // Action Handlers
  void _handleChangePassword() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Change Password'),
        content: const Text('This feature will be available soon. You can change your password through the email reset link.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _handleLinkAccount() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Link Social Account'),
        message: const Text('Choose a social account to link for easier sign-in'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _linkGoogleAccount();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.globe, size: 20),
                const SizedBox(width: 8),
                const Text('Link Google Account'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _linkAppleAccount();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.app_badge, size: 20),
                const SizedBox(width: 8),
                const Text('Link Apple ID'),
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

  void _handleUnlinkAccount() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Unlink Account'),
        content: Text('Are you sure you want to unlink your ${_getAuthProviderName()} account? You will need to sign in with email and password.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Unlink'),
            onPressed: () {
              Navigator.of(context).pop();
              _unlinkAccount();
            },
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _handleAccountSecurity() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Account Security'),
        content: const Text('Advanced security features will be available soon, including two-factor authentication and login notifications.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _linkGoogleAccount() {
    // TODO: Implement Google account linking
    _showAccountActionDialog('Google account linking will be implemented soon.');
  }

  void _linkAppleAccount() {
    // TODO: Implement Apple account linking
    _showAccountActionDialog('Apple ID linking will be implemented soon.');
  }

  void _unlinkAccount() {
    // TODO: Implement account unlinking
    _showAccountActionDialog('Account unlinking will be implemented soon.');
  }

  void _showAccountActionDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
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
