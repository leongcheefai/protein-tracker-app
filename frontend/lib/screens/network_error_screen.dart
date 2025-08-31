import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';

enum NetworkErrorType {
  noInternet,
  apiError,
  timeout,
  serverError,
  unknown,
}

class NetworkErrorScreen extends StatelessWidget {
  final NetworkErrorType errorType;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final bool showOfflineMode;

  const NetworkErrorScreen({
    super.key,
    required this.errorType,
    this.customMessage,
    this.onRetry,
    this.onGoBack,
    this.showOfflineMode = false,
  });

  String get _getTitle {
    switch (errorType) {
      case NetworkErrorType.noInternet:
        return 'No Internet Connection';
      case NetworkErrorType.apiError:
        return 'Connection Error';
      case NetworkErrorType.timeout:
        return 'Request Timeout';
      case NetworkErrorType.serverError:
        return 'Server Error';
      case NetworkErrorType.unknown:
        return 'Network Error';
    }
  }

  String get _getDescription {
    if (customMessage != null) {
      return customMessage!;
    }
    
    switch (errorType) {
      case NetworkErrorType.noInternet:
        return 'Please check your internet connection and try again. You can still use the app in offline mode for basic features.';
      case NetworkErrorType.apiError:
        return 'There was an issue connecting to our servers. Please try again in a few moments.';
      case NetworkErrorType.timeout:
        return 'The request took too long to complete. This might be due to a slow connection.';
      case NetworkErrorType.serverError:
        return 'Our servers are experiencing issues. Please try again later.';
      case NetworkErrorType.unknown:
        return 'An unexpected network error occurred. Please check your connection and try again.';
    }
  }

  IconData get _getIcon {
    switch (errorType) {
      case NetworkErrorType.noInternet:
        return CupertinoIcons.wifi_slash;
      case NetworkErrorType.apiError:
        return CupertinoIcons.exclamationmark_triangle;
      case NetworkErrorType.timeout:
        return CupertinoIcons.clock;
      case NetworkErrorType.serverError:
        return CupertinoIcons.exclamationmark_octagon;
      case NetworkErrorType.unknown:
        return CupertinoIcons.exclamationmark_circle;
    }
  }

  Color get _getIconColor {
    switch (errorType) {
      case NetworkErrorType.noInternet:
        return AppColors.warning;
      case NetworkErrorType.apiError:
        return AppColors.error;
      case NetworkErrorType.timeout:
        return AppColors.warning;
      case NetworkErrorType.serverError:
        return AppColors.error;
      case NetworkErrorType.unknown:
        return AppColors.neutral;
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
            color: AppColors.neutral,
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
              // Error Icon
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
              
              // Retry Button
              if (onRetry != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: onRetry,
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Go Back Button (if provided)
              if (onGoBack != null)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: onGoBack,
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Offline Mode Indicator
              if (showOfflineMode) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Offline mode enabled - you can still view your progress and add basic entries',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Troubleshooting Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neutral,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.lightbulb,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Troubleshooting Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTroubleshootingTip('Check your Wi-Fi or mobile data connection'),
                    _buildTroubleshootingTip('Try switching between Wi-Fi and mobile data'),
                    _buildTroubleshootingTip('Restart the app if the problem persists'),
                    if (errorType == NetworkErrorType.serverError)
                      _buildTroubleshootingTip('This is a temporary issue, please try again later'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTroubleshootingTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: AppColors.neutral,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
