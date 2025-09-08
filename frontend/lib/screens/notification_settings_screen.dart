import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../main.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Local notification settings (meal reminders, etc.)
  Map<String, String> _mealReminderTimes = {
    'breakfast': '08:00',
    'lunch': '12:30',
    'snack': '16:00',
    'dinner': '19:00',
  };
  String _doNotDisturbStart = '22:00';
  String _doNotDisturbEnd = '07:00';
  bool _nightlySummaryEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadLocalSettings();
  }

  void _loadLocalSettings() {
    // In a real implementation, you would load these from shared preferences
    // For now, using default values
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notification Settings'),
        backgroundColor: AppColors.background,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Notifications Toggle
              _buildMainToggleSection(),
              
              const SizedBox(height: 24),
              
              // Meal Reminder Times
              _buildMealReminderSection(),
              
              const SizedBox(height: 24),
              
              // Do Not Disturb Settings
              _buildDoNotDisturbSection(),
              
              const SizedBox(height: 24),
              
              // Nightly Summary Toggle
              _buildNightlySummarySection(),
              
              const SizedBox(height: 32),
              
              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainToggleSection() {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.bell_fill,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Enable Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                    value: profileProvider.notificationsEnabled,
                    onChanged: (value) async {
                      await profileProvider.updateNotificationSettings(
                        notificationsEnabled: value,
                      );
                    },
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Receive reminders for meal tracking and daily summaries',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              // Additional notification type toggles
              const SizedBox(height: 16),
              _buildNotificationTypeRow(
                'Push Notifications',
                CupertinoIcons.device_phone_portrait,
                profileProvider.pushNotifications,
                (value) async {
                  await profileProvider.updateNotificationSettings(
                    pushNotifications: value,
                  );
                },
              ),
              
              const SizedBox(height: 12),
              _buildNotificationTypeRow(
                'Email Notifications',
                CupertinoIcons.mail_solid,
                profileProvider.emailNotifications,
                (value) async {
                  await profileProvider.updateNotificationSettings(
                    emailNotifications: value,
                  );
                },
              ),
              
              // Show loading state if updating
              if (profileProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
                
              // Show error if there's one
              if (profileProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    profileProvider.errorMessage!,
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildNotificationTypeRow(String title, IconData icon, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildMealReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Reminder Times',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set when you want to be reminded to track your meals',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Breakfast
        _buildMealTimeRow(
          'Breakfast',
          'breakfast',
          _mealReminderTimes['breakfast'] ?? '08:00',
          const Icon(CupertinoIcons.sunrise_fill, color: AppColors.warning),
        ),
        
        const SizedBox(height: 12),
        
        // Lunch
        _buildMealTimeRow(
          'Lunch',
          'lunch',
          _mealReminderTimes['lunch'] ?? '12:30',
          const Icon(CupertinoIcons.sun_max_fill, color: AppColors.warning),
        ),
        
        const SizedBox(height: 12),
        
        // Snack
        _buildMealTimeRow(
          'Snack',
          'snack',
          _mealReminderTimes['snack'] ?? '16:00',
          const Icon(CupertinoIcons.circle_fill, color: AppColors.neutral),
        ),
        
        const SizedBox(height: 12),
        
        // Dinner
        _buildMealTimeRow(
          'Dinner',
          'dinner',
          _mealReminderTimes['dinner'] ?? '19:00',
          const Icon(CupertinoIcons.moon_fill, color: AppColors.secondary),
        ),
      ],
    );
  }

  Widget _buildMealTimeRow(String mealName, String mealKey, String currentTime, Icon icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Reminder at $currentTime',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(8),
            onPressed: () => _showTimePicker(context, mealKey, currentTime),
            child: Text(
              currentTime,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoNotDisturbSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do Not Disturb',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set quiet hours when notifications won\'t disturb you',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                'Start Time',
                _doNotDisturbStart,
                (time) => setState(() => _doNotDisturbStart = time),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeSelector(
                'End Time',
                _doNotDisturbEnd,
                (time) => setState(() => _doNotDisturbEnd = time),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.moon_fill,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quiet hours: $_doNotDisturbStart - $_doNotDisturbEnd',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(String label, String currentTime, Function(String) onTimeChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(8),
          onPressed: () => _showTimePickerForDnd(context, currentTime, onTimeChanged),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentTime,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                CupertinoIcons.clock,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNightlySummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.chart_bar_fill,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nightly Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Daily protein intake summary at 21:30',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: _nightlySummaryEnabled,
                onChanged: (value) {
                  setState(() => _nightlySummaryEnabled = value);
                },
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: () {
          // Show success message and navigate back
          _showSuccessDialog();
        },
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Text(
          'Save Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, String mealKey, String currentTime) {
    // Parse current time
    List<String> timeParts = currentTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: AppColors.background,
        child: Column(
          children: [
            Container(
              height: 50,
              color: AppColors.accent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2024, 1, 1, hour, minute),
                onDateTimeChanged: (DateTime newDateTime) {
                  String newTime = '${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}';
                  
                  setState(() {
                    _mealReminderTimes[mealKey] = newTime;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePickerForDnd(BuildContext context, String currentTime, Function(String) onTimeChanged) {
    // Parse current time
    List<String> timeParts = currentTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: AppColors.background,
        child: Column(
          children: [
            Container(
              height: 50,
              color: AppColors.accent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2024, 1, 1, hour, minute),
                onDateTimeChanged: (DateTime newDateTime) {
                  String newTime = '${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}';
                  onTimeChanged(newTime);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Settings Saved'),
        content: const Text('Your notification preferences have been updated successfully!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}