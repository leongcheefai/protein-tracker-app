import 'package:flutter/cupertino.dart';
import '../main.dart';
import 'permission_denied_screen.dart';
import 'network_error_screen.dart';

class ErrorDemoScreen extends StatelessWidget {
  const ErrorDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Error & Edge Cases Demo'),
        backgroundColor: AppColors.background,
        border: Border(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phase 6: Error & Edge Cases',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Test different error states and permission screens',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Permission Denied Screens
              const Text(
                'Permission Denied Screens',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildDemoButton(
                context,
                'Camera Permission',
                'Test camera permission denied screen',
                () => _showPermissionDenied(context, PermissionType.camera),
                CupertinoIcons.camera,
                AppColors.primary,
              ),
              
              const SizedBox(height: 12),
              
              _buildDemoButton(
                context,
                'Notifications Permission',
                'Test notification permission denied screen',
                () => _showPermissionDenied(context, PermissionType.notifications),
                CupertinoIcons.bell,
                AppColors.warning,
              ),
              
              const SizedBox(height: 12),
              
              _buildDemoButton(
                context,
                'Storage Permission',
                'Test storage permission denied screen',
                () => _showPermissionDenied(context, PermissionType.storage),
                CupertinoIcons.folder,
                AppColors.neutral,
              ),
              
              const SizedBox(height: 32),
              
              // Network Error Screens
              const Text(
                'Network Error Screens',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildDemoButton(
                context,
                'No Internet Connection',
                'Test no internet error screen',
                () => _showNetworkError(context, NetworkErrorType.noInternet),
                CupertinoIcons.wifi_slash,
                AppColors.warning,
              ),
              
              const SizedBox(height: 12),
              
              _buildDemoButton(
                context,
                'API Error',
                'Test API connection error screen',
                () => _showNetworkError(context, NetworkErrorType.apiError),
                CupertinoIcons.exclamationmark_triangle,
                AppColors.error,
              ),
              
              const SizedBox(height: 12),
              
              _buildDemoButton(
                context,
                'Request Timeout',
                'Test timeout error screen',
                () => _showNetworkError(context, NetworkErrorType.timeout),
                CupertinoIcons.clock,
                AppColors.warning,
              ),
              
              const SizedBox(height: 12),
              
              _buildDemoButton(
                context,
                'Server Error',
                'Test server error screen',
                () => _showNetworkError(context, NetworkErrorType.serverError),
                CupertinoIcons.exclamationmark_octagon,
                AppColors.error,
              ),
              
              const SizedBox(height: 12),
              
              _buildDemoButton(
                context,
                'Unknown Error',
                'Test unknown network error screen',
                () => _showNetworkError(context, NetworkErrorType.unknown),
                CupertinoIcons.exclamationmark_circle,
                AppColors.neutral,
              ),
              
              const SizedBox(height: 32),
              
              // Info Section
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.info_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Demo Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'These screens demonstrate how the app handles various error states and permission issues. Each screen follows Cupertino design guidelines and provides clear user guidance.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
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

  Widget _buildDemoButton(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onPressed,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: onPressed,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.neutral,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDenied(BuildContext context, PermissionType permissionType) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => PermissionDeniedScreen(
          permissionType: permissionType,
          onRetry: () {
            Navigator.of(context).pop();
            // In a real app, you would retry the permission request
          },
          onMaybeLater: () {
            Navigator.of(context).pop();
            // In a real app, you would handle the user choosing to skip
          },
        ),
      ),
    );
  }

  void _showNetworkError(BuildContext context, NetworkErrorType errorType) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => NetworkErrorScreen(
          errorType: errorType,
          onRetry: () {
            Navigator.of(context).pop();
            // In a real app, you would retry the network request
          },
          onGoBack: () {
            Navigator.of(context).pop();
            // In a real app, you would navigate back
          },
          showOfflineMode: errorType == NetworkErrorType.noInternet,
        ),
      ),
    );
  }
}
