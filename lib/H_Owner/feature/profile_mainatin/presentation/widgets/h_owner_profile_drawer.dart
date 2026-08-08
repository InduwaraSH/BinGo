import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bingo/Common/Logging.dart';
import 'package:bingo/H_Owner/feature/payment/presentation/pages/payment_method_page.dart';
import '../pages/h_owner_profile_edit.dart';
import '../pages/h_owner_profile_privacy.dart';
import '../pages/h_owner_profile_setting.dart';

class HOwnerProfileDrawer extends StatelessWidget {
  final Map<String, dynamic> userProfile;

  const HOwnerProfileDrawer({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    String name = userProfile['Owner_Name'] ?? 'User';
    String email =
        userProfile['Owner_Email'] ??
        FirebaseAuth.instance.currentUser?.email ??
        '';

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1824), Color(0xFF07121A)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 30,
              offset: Offset(10, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Profile Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00B4FF).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFF00B4FF).withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00B4FF).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.user,
                        size: 30,
                        color: Color(0xFF00B4FF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Divider(
                  color: Colors.white.withOpacity(0.1),
                  thickness: 1,
                ),
              ),
              const SizedBox(height: 10),
              // Menu Items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Iconsax.user_edit,
                        label: 'Profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HOwnerProfileEdit(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Iconsax.card,
                        label: 'Payment Method',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PaymentMethodPage(amount: 0.0),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Iconsax.shield_tick,
                        label: 'Privacy Policy',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HOwnerProfilePrivacy(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Iconsax.setting_2,
                        label: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HOwnerProfileSetting(),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 10,
                        ),
                        child: Divider(
                          color: Colors.white.withOpacity(0.1),
                          thickness: 1,
                        ),
                      ),
                      _buildMenuItem(
                        icon: Iconsax.logout,
                        label: 'Logout',
                        isLogout: true,
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Logging(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        hoverColor: const Color(0xFF00B4FF).withOpacity(0.1),
        splashColor: const Color(0xFF00B4FF).withOpacity(0.2),
        leading: Icon(
          icon,
          color: isLogout ? Colors.redAccent : Colors.white70,
          size: 24,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.redAccent : Colors.white,
          ),
        ),
        trailing: isLogout
            ? null
            : const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white24,
                size: 14,
              ),
      ),
    );
  }
}
