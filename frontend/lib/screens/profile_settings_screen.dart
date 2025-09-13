import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/user_profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_settings/profile_photo_section.dart';
import '../widgets/profile_settings/login_details_section.dart';
import '../widgets/profile_settings/personal_info_section.dart';
import '../widgets/profile_settings/activity_goals_section.dart';
import '../utils/profile_settings_helpers.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  String _selectedActivityLevel = 'moderately_active';
  List<String> _dietaryRestrictions = [];
  String _units = 'metric';
  File? _profilePhoto;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    
    // Load current profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Initialize from current user data
    _heightController.text = profileProvider.height?.toString() ?? '';
    _weightController.text = profileProvider.weight?.toString() ?? '';
    _nameController.text = profileProvider.displayName ?? authProvider.displayName;
    _ageController.text = profileProvider.age?.toString() ?? '';
    _selectedActivityLevel = profileProvider.activityLevel ?? 'moderately_active';
    _dietaryRestrictions = profileProvider.dietaryRestrictions ?? [];
    _units = profileProvider.units ?? 'metric';
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  double _calculateDailyProteinTarget() {
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    
    // Base calculation: moderate protein intake
    double multiplier = 1.2; // sedentary
    
    switch (_selectedActivityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'lightly_active':
        multiplier = 1.4;
        break;
      case 'moderately_active':
        multiplier = 1.6;
        break;
      case 'very_active':
        multiplier = 1.8;
        break;
      case 'extra_active':
        multiplier = 2.0;
        break;
    }
    
    return weight * multiplier;
  }

  void _saveChanges() async {
    // Validate inputs
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final age = int.tryParse(_ageController.text);
    
    if (height == null || weight == null) {
      ProfileSettingsHelpers.showErrorDialog(context, 'Please enter valid height and weight values.');
      return;
    }
    
    if (height < 100 || height > 250) {
      ProfileSettingsHelpers.showErrorDialog(context, 'Height must be between 100-250 cm.');
      return;
    }
    
    if (weight < 30 || weight > 200) {
      ProfileSettingsHelpers.showErrorDialog(context, 'Weight must be between 30-200 kg.');
      return;
    }

    if (age != null && (age < 13 || age > 120)) {
      ProfileSettingsHelpers.showErrorDialog(context, 'Age must be between 13-120 years.');
      return;
    }

    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Calculate daily protein goal based on current inputs
      final dailyProteinGoal = _calculateDailyProteinTarget();
      
      // Update backend profile
      final success = await profileProvider.updateBasicProfile(
        displayName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        age: age,
        height: height,
        weight: weight,
        dailyProteinGoal: dailyProteinGoal,
        activityLevel: _selectedActivityLevel,
        dietaryRestrictions: _dietaryRestrictions,
        units: _units,
      );
      
      if (success) {
        // Update auth provider with latest profile data
        await authProvider.refreshUserProfile();

        // TODO: Save profile photo to cloud storage
        if (_profilePhoto != null) {
          // In a real app, you would upload the photo here
          // For example: await _uploadProfilePhoto(_profilePhoto!);
        }

        // Show success and navigate back
        if (mounted) {
          ProfileSettingsHelpers.showSuccessDialog(context);
        }
      } else {
        // Show error from profile provider
        if (mounted) {
          ProfileSettingsHelpers.showErrorDialog(
            context, 
            profileProvider.errorMessage ?? 'Failed to update profile. Please try again.'
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ProfileSettingsHelpers.showErrorDialog(
          context, 
          'An unexpected error occurred. Please try again.'
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProfileProvider, AuthProvider>(
      builder: (context, profileProvider, authProvider, child) {
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
                  // Loading indicator
                  if (profileProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CupertinoActivityIndicator(),
                      ),
                    ),
                  
                  // Profile Photo Section
                  ProfilePhotoSection(
                    profileImageUrl: null, // TODO: Add profile image URL support
                    onPhotoChanged: (photo) {
                      setState(() {
                        _profilePhoto = photo;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login Details Section
                  LoginDetailsSection(
                    userEmail: authProvider.userEmail,
                    userName: profileProvider.displayName ?? authProvider.displayName,
                    authProvider: 'email', // TODO: Get from auth provider
                    nameController: _nameController,
                    onPasswordChange: () => ProfileSettingsHelpers.handleChangePassword(context),
                    onLinkAccount: () => ProfileSettingsHelpers.handleLinkAccount(context),
                    onUnlinkAccount: () => ProfileSettingsHelpers.handleUnlinkAccount(
                      context, 
                      'Email & Password',
                    ),
                    onAccountSecurity: () => ProfileSettingsHelpers.handleAccountSecurity(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Personal Information Section
                  PersonalInfoSection(
                    ageController: _ageController,
                    heightController: _heightController,
                    weightController: _weightController,
                    selectedActivityLevel: _selectedActivityLevel,
                    onActivityLevelTap: _showActivityLevelPicker,
                    onChanged: () => setState(() {}),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  _buildSaveButton(),
                  
                  // Error message display
                  if (profileProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        profileProvider.errorMessage!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }




  void _showActivityLevelPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey4,
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(
                  initialItem: _getActivityLevelIndex(_selectedActivityLevel),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedActivityLevel = _getActivityLevelValue(index);
                  });
                },
                children: const [
                  Text('Sedentary'),
                  Text('Lightly Active'),
                  Text('Moderately Active'),
                  Text('Very Active'),
                  Text('Extra Active'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getActivityLevelIndex(String level) {
    switch (level) {
      case 'sedentary': return 0;
      case 'lightly_active': return 1;
      case 'moderately_active': return 2;
      case 'very_active': return 3;
      case 'extra_active': return 4;
      default: return 2;
    }
  }

  String _getActivityLevelValue(int index) {
    switch (index) {
      case 0: return 'sedentary';
      case 1: return 'lightly_active';
      case 2: return 'moderately_active';
      case 3: return 'very_active';
      case 4: return 'extra_active';
      default: return 'moderately_active';
    }
  }

  void _showDietaryRestrictionsPicker() {
    final restrictions = [
      'Vegetarian',
      'Vegan',
      'Gluten-Free',
      'Dairy-Free',
      'Nut-Free',
      'Low-Carb',
      'Keto',
      'Paleo',
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey4,
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Dietary Restrictions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: restrictions.map((restriction) {
                  final isSelected = _dietaryRestrictions.contains(restriction);
                  return CupertinoListTile(
                    title: Text(restriction),
                    trailing: isSelected
                        ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _dietaryRestrictions.remove(restriction);
                        } else {
                          _dietaryRestrictions.add(restriction);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
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
}