import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  ProfilePage({super.key});

  // Format date for display
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      if (context.mounted) {
        // Navigate to login page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error signing out')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // User avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // User email
            Text(
              user?['email'] ?? 'User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            // User ID
            Text(
              'User ID: ${_authService.userId ?? 'Unknown'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),

            // Account creation date
            if (user?['createdAt'] != null)
              Text(
                'Member since: ${_formatDate(user!['createdAt'])}',
                style: Theme.of(context).textTheme.bodySmall,
              ),

            // Last login
            if (user?['lastLogin'] != null)
              Text(
                'Last login: ${_formatDate(user!['lastLogin'])}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 40),

            // Account information section
            const ListTile(
              title: Text('Account Information'),
              subtitle: Text('Manage your account details'),
              leading: Icon(Icons.account_circle),
              trailing: Icon(Icons.chevron_right),
            ),

            // Settings section
            const ListTile(
              title: Text('Settings'),
              subtitle: Text('App preferences and configurations'),
              leading: Icon(Icons.settings),
              trailing: Icon(Icons.chevron_right),
            ),

            // Privacy section
            const ListTile(
              title: Text('Privacy'),
              subtitle: Text('Privacy settings and data control'),
              leading: Icon(Icons.privacy_tip),
              trailing: Icon(Icons.chevron_right),
            ),

            const Spacer(),

            // Sign out button
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade700,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
