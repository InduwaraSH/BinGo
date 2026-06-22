import 'package:flutter/material.dart';
import '../pages/driver_profile_setting.dart';
import '../pages/driver_profile_edit.dart';
import '../pages/driver_profile_privacy.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverProfileDrawer extends StatelessWidget {
  const DriverProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF07121A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00B4FF), Color(0xFF00A8FF)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue[400],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Driver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'driver@bingo.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF00B4FF)),
            title: const Text(
              'Home',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF00B4FF)),
            title: const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DriverProfileEdit(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF00B4FF)),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DriverProfileSetting(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Color(0xFF00B4FF)),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DriverProfilePrivacy(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF00B4FF)),
            title: const Text(
              'Delivery History',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Color(0xFF00B4FF)),
            title: const Text(
              'My Ratings',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF07121A),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF00B4FF)),
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
