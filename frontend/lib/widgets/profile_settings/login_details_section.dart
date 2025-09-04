import 'package:flutter/cupertino.dart';

class LoginDetailsSection extends StatelessWidget {
  final String? userEmail;
  final String? userName;
  final String? authProvider;
  final TextEditingController nameController;
  final VoidCallback onPasswordChange;
  final VoidCallback onLinkAccount;
  final VoidCallback onUnlinkAccount;
  final VoidCallback onAccountSecurity;

  const LoginDetailsSection({
    super.key,
    this.userEmail,
    this.userName,
    this.authProvider,
    required this.nameController,
    required this.onPasswordChange,
    required this.onLinkAccount,
    required this.onUnlinkAccount,
    required this.onAccountSecurity,
  });

  @override
  Widget build(BuildContext context) {
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
              controller: nameController,
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
                      userEmail?.isNotEmpty == true ? userEmail! : 'No email set',
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
        if (authProvider == 'email') ...[
          _buildActionButton(
            icon: CupertinoIcons.lock_rotation,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: onPasswordChange,
          ),
          const SizedBox(height: 8),
        ],
        
        // Link/Unlink Account
        _buildActionButton(
          icon: authProvider == 'email' ? CupertinoIcons.link : CupertinoIcons.minus_circle,
          title: authProvider == 'email' ? 'Link Social Account' : 'Unlink Account',
          subtitle: authProvider == 'email' 
              ? 'Connect Google or Apple for easier sign-in'
              : 'Remove social account connection',
          onTap: authProvider == 'email' ? onLinkAccount : onUnlinkAccount,
        ),
        
        const SizedBox(height: 8),
        
        // Account Security
        _buildActionButton(
          icon: CupertinoIcons.shield,
          title: 'Account Security',
          subtitle: 'Manage your account security settings',
          onTap: onAccountSecurity,
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

  // Authentication Provider Helper Methods
  IconData _getAuthProviderIcon() {
    switch (authProvider) {
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
    switch (authProvider) {
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
    switch (authProvider) {
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
    switch (authProvider) {
      case 'google':
        return 'Signed in with Google account';
      case 'apple':
        return 'Signed in with Apple ID';
      case 'email':
      default:
        return 'Signed in with email and password';
    }
  }
}
