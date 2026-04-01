import 'package:flutter/material.dart';
import 'payment/payment_method.dart';
import 'H_Owner_Profile_edit.dart';
import 'H_Owner_Profile_Setting.dart';
import 'H_Owner_Profile_Privacy.dart';

class HOwnerProfile extends StatefulWidget {
  const HOwnerProfile({super.key});

  @override
  State<HOwnerProfile> createState() => _HOwnerProfileState();
}

class _HOwnerProfileState extends State<HOwnerProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: const AssetImage('assets/avatar.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person,
                    label: 'Profile',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HOwnerProfileEdit()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.favorite,
                    label: 'Favorite',
                    onTap: () {
                      // TODO: Navigate to Favorite
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.credit_card,
                    label: 'Payment Method',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.lock,
                    label: 'Privacy Policy',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HOwnerProfilePrivacy(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HOwnerProfileSetting(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.help,
                    label: 'Help',
                    onTap: () {
                      // TODO: Navigate to Help
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () {
                      // TODO: Implement Logout
                    },
                    isLogout: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.chat_bubble_outline, color: Colors.white),
              Icon(Icons.person_outline, color: Colors.white),
              Icon(Icons.calendar_today, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
