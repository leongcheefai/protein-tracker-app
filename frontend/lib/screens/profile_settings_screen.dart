import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../utils/user_settings_provider.dart';
import '../widgets/profile_settings/profile_photo_section.dart';
import '../widgets/profile_settings/login_details_section.dart';
import '../widgets/profile_settings/body_metrics_section.dart';
import '../widgets/profile_settings/training_goal_section.dart';
import '../utils/profile_settings_helpers.dart';

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
    if (_profilePhoto != null) {
      // In a real app, you would save the photo here
      // For example: await _saveProfilePhoto(_profilePhoto!);
    }

    // Show success and navigate back
    ProfileSettingsHelpers.showSuccessDialog(context);
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
              ProfilePhotoSection(
                profileImageUrl: widget.profileImageUrl,
                onPhotoChanged: (photo) {
                  setState(() {
                    _profilePhoto = photo;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Login Details Section
              LoginDetailsSection(
                userEmail: widget.userEmail,
                userName: widget.userName,
                authProvider: widget.authProvider,
                nameController: _nameController,
                onPasswordChange: () => ProfileSettingsHelpers.handleChangePassword(context),
                onLinkAccount: () => ProfileSettingsHelpers.handleLinkAccount(context),
                onUnlinkAccount: () => ProfileSettingsHelpers.handleUnlinkAccount(
                  context, 
                  _getAuthProviderName(),
                ),
                onAccountSecurity: () => ProfileSettingsHelpers.handleAccountSecurity(context),
              ),
              
              const SizedBox(height: 24),
              
              // Body Metrics Section
              BodyMetricsSection(
                heightController: _heightController,
                weightController: _weightController,
                onChanged: _updateDailyTarget,
              ),
              
              const SizedBox(height: 24),
              
              // Training and Goal Section
              TrainingGoalSection(
                selectedTrainingMultiplier: _selectedTrainingMultiplier,
                selectedGoal: _selectedGoal,
                dailyProteinTarget: _dailyProteinTarget,
                onTrainingMultiplierChanged: (multiplier) {
                  setState(() {
                    _selectedTrainingMultiplier = multiplier;
                  });
                  _updateDailyTarget();
                },
                onGoalChanged: (goal) {
                  setState(() {
                    _selectedGoal = goal;
                  });
                  _updateDailyTarget();
                },
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
}