import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../utils/user_settings_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notification Settings'),
        backgroundColor: CupertinoColors.systemBackground,
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
    return Consumer<UserSettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CupertinoColors.systemGrey4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.bell_fill,
                    color: CupertinoColors.activeBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Enable Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      settings.updateNotificationSettings(notificationsEnabled: value);
                    },
                    activeTrackColor: CupertinoColors.activeBlue,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Receive reminders for meal tracking and daily summaries',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealReminderSection() {
    return Consumer<UserSettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Reminder Times',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set when you want to be reminded to track your meals',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 16),
            
            // Breakfast
            _buildMealTimeRow(
              'Breakfast',
              'breakfast',
              settings.mealReminderTimes['breakfast'] ?? '08:00',
              const Icon(CupertinoIcons.sunrise_fill, color: CupertinoColors.systemOrange),
              settings,
            ),
            
            const SizedBox(height: 12),
            
            // Lunch
            _buildMealTimeRow(
              'Lunch',
              'lunch',
              settings.mealReminderTimes['lunch'] ?? '12:30',
              const Icon(CupertinoIcons.sun_max_fill, color: CupertinoColors.systemYellow),
              settings,
            ),
            
            const SizedBox(height: 12),
            
            // Snack
            _buildMealTimeRow(
              'Snack',
              'snack',
              settings.mealReminderTimes['snack'] ?? '16:00',
              const Icon(CupertinoIcons.circle_fill, color: CupertinoColors.systemGrey),
              settings,
            ),
            
            const SizedBox(height: 12),
            
            // Dinner
            _buildMealTimeRow(
              'Dinner',
              'dinner',
              settings.mealReminderTimes['dinner'] ?? '19:00',
              const Icon(CupertinoIcons.moon_fill, color: CupertinoColors.systemPurple),
              settings,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealTimeRow(String mealName, String mealKey, String currentTime, Icon icon, UserSettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
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
                    color: CupertinoColors.black,
                  ),
                ),
                Text(
                  'Reminder at $currentTime',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
            onPressed: () => _showTimePicker(context, mealKey, currentTime, settings),
            child: Text(
              currentTime,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoNotDisturbSection() {
    return Consumer<UserSettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Do Not Disturb',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set quiet hours when notifications won\'t disturb you',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    'Start Time',
                    settings.doNotDisturbStart,
                    (time) => settings.updateNotificationSettings(doNotDisturbStart: time),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector(
                    'End Time',
                    settings.doNotDisturbEnd,
                    (time) => settings.updateNotificationSettings(doNotDisturbEnd: time),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CupertinoColors.systemGrey4),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.moon_fill,
                    color: CupertinoColors.systemGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Quiet hours: ${settings.doNotDisturbStart} - ${settings.doNotDisturbEnd}',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
          onPressed: () => _showTimePicker(context, '', currentTime, null, onTimeChanged: onTimeChanged),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentTime,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
              const Icon(
                CupertinoIcons.clock,
                color: CupertinoColors.systemGrey,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNightlySummarySection() {
    return Consumer<UserSettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CupertinoColors.systemGrey4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.chart_bar_fill,
                    color: CupertinoColors.activeGreen,
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
                            color: CupertinoColors.black,
                          ),
                        ),
                        Text(
                          'Daily protein intake summary at 21:30',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: settings.nightlySummaryEnabled,
                    onChanged: (value) {
                      settings.updateNotificationSettings(nightlySummaryEnabled: value);
                    },
                    activeTrackColor: CupertinoColors.activeGreen,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton.filled(
        onPressed: () {
          // Show success message and navigate back
          _showSuccessDialog();
        },
        child: const Text(
          'Save Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, String mealKey, String currentTime, UserSettingsProvider? settings, {Function(String)? onTimeChanged}) {
    // Parse current time
    List<String> timeParts = currentTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 50,
              color: CupertinoColors.systemGrey6,
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
                  
                  if (mealKey.isNotEmpty && settings != null) {
                    settings.updateMealReminderTime(mealKey, newTime);
                  } else if (onTimeChanged != null) {
                    onTimeChanged(newTime);
                  }
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
