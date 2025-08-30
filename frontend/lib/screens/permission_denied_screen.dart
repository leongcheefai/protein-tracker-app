import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';

enum PermissionType {
  camera,
  notifications,
  storage,
  microphone,
}

class PermissionDeniedScreen extends StatelessWidget {
  final PermissionType permissionType;
  final VoidCallback? onRetry;
  final VoidCallback? onMaybeLater;

  const PermissionDeniedScreen({
    super.key,
    required this.permissionType,
    this.onRetry,
    this.onMaybeLater,
  });

  String get _getTitle {
    switch (permissionType) {
      case PermissionType.camera:
        return 'Camera Permission Required';
      case PermissionType.notifications:
        return 'Notification Permission Required';
      case PermissionType.storage:
        return 'Storage Permission Required';
      case PermissionType.microphone:
        return 'Microphone Permission Required';
    }
  }

  String get _getDescription {
    switch (permissionType) {
      case PermissionType.camera:
        return 'We need camera access to analyze your meals and calculate protein content. Your photos are processed locally and never stored.';
      case PermissionType.notifications:
        return 'We need notification permission to remind you about meal tracking and help you stay on track with your protein goals.';
      case PermissionType.storage:
        return 'We need storage access to save your meal photos temporarily for analysis. Your data is kept private and secure.';
      case PermissionType.microphone:
        return 'We need microphone access for voice commands and audio input features.';
    }
  }

  IconData get _getIcon {
    switch (permissionType) {
      case PermissionType.camera:
        return CupertinoIcons.camera;
      case PermissionType.notifications:
        return CupertinoIcons.bell;
      case PermissionType.storage:
        return CupertinoIcons.folder;
      case PermissionType.microphone:
        return CupertinoIcons.mic;
    }
  }

  Color get _getIconColor {
    switch (permissionType) {
      case PermissionType.camera:
        return AppColors.primary;
      case PermissionType.notifications:
        return AppColors.warning;
      case PermissionType.storage:
        return AppColors.neutral;
      case PermissionType.microphone:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(_getTitle),
        backgroundColor: AppColors.background,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Permission Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getIconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  _getIcon,
                  size: 60,
                  color: _getIconColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                _getTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                _getDescription,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Open Settings Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    openAppSettings();
                  },
                  child: const Text(
                    'Open Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Retry Button (if provided)
              if (onRetry != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: onRetry,
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Maybe Later Button (if provided)
              if (onMaybeLater != null)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: Colors.transparent,
                    onPressed: onMaybeLater,
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Additional Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.info_circle,
                      color: AppColors.neutral,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can change permissions anytime in your device settings',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
