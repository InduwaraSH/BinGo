import 'package:flutter/material.dart';
import 'driver_notification_setting.dart';
import 'driver_password_manager.dart';
import 'driver_delete_account.dart';

class DriverProfileSetting extends StatefulWidget {
  const DriverProfileSetting({super.key});

  @override
  State<DriverProfileSetting> createState() => _DriverProfileSettingState();
}

class _DriverProfileSettingState extends State<DriverProfileSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Notification Setting
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              label: 'Notification Setting',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DriverNotificationSetting(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Password Manager
            _buildSettingItem(
              icon: Icons.lock_outlined,
              label: 'Password Manager',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DriverPasswordManager(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Delete Account
            _buildSettingItem(
              icon: Icons.person_remove_outlined,
              label: 'Delete Account',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DriverDeleteAccount(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF00B4FF),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white30,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
