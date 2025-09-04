import 'package:flutter/cupertino.dart';

class ProfileSettingsHelpers {
  static void handleChangePassword(BuildContext context) {
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

  static void handleLinkAccount(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Link Social Account'),
        message: const Text('Choose a social account to link for easier sign-in'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _linkGoogleAccount(context);
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
              _linkAppleAccount(context);
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

  static void handleUnlinkAccount(BuildContext context, String authProviderName) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Unlink Account'),
        content: Text('Are you sure you want to unlink your $authProviderName account? You will need to sign in with email and password.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Unlink'),
            onPressed: () {
              Navigator.of(context).pop();
              _unlinkAccount(context);
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

  static void handleAccountSecurity(BuildContext context) {
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

  static void _linkGoogleAccount(BuildContext context) {
    // TODO: Implement Google account linking
    _showAccountActionDialog(context, 'Google account linking will be implemented soon.');
  }

  static void _linkAppleAccount(BuildContext context) {
    // TODO: Implement Apple account linking
    _showAccountActionDialog(context, 'Apple ID linking will be implemented soon.');
  }

  static void _unlinkAccount(BuildContext context) {
    // TODO: Implement account unlinking
    _showAccountActionDialog(context, 'Account unlinking will be implemented soon.');
  }

  static void _showAccountActionDialog(BuildContext context, String message) {
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

  static void showErrorDialog(BuildContext context, String message) {
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

  static void showSuccessDialog(BuildContext context) {
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
}
