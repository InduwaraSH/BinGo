import 'package:flutter/material.dart';

class HOwnerNotificationSetting extends StatefulWidget {
  const HOwnerNotificationSetting({super.key});

  @override
  State<HOwnerNotificationSetting> createState() =>
      _HOwnerNotificationSettingState();
}

class _HOwnerNotificationSettingState extends State<HOwnerNotificationSetting>
    with SingleTickerProviderStateMixin {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _accountNotifications = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Communication Channels',
                'Choose how you want to receive updates',
                Icons.notifications_active,
              ),
              const SizedBox(height: 20),
              // Push Notifications
              _buildNotificationToggle(
                title: 'Push Notifications',
                subtitle: 'Receive real-time app notifications',
                value: _pushNotifications,
                icon: Icons.phone_iphone,
                onChanged: (value) {
                  setState(() => _pushNotifications = value);
                },
                delay: 0.1,
              ),
              const SizedBox(height: 12),
              // Email Notifications
              _buildNotificationToggle(
                title: 'Email Notifications',
                subtitle: 'Get daily digest and updates',
                value: _emailNotifications,
                icon: Icons.email,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                },
                delay: 0.15,
              ),
              const SizedBox(height: 12),
              // SMS Notifications
              _buildNotificationToggle(
                title: 'SMS Notifications',
                subtitle: 'Receive urgent alerts via text message',
                value: _smsNotifications,
                icon: Icons.sms,
                onChanged: (value) {
                  setState(() => _smsNotifications = value);
                },
                delay: 0.2,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(
                'Notification Types',
                'Customize notification preferences',
                Icons.category,
              ),
              const SizedBox(height: 20),
              // Order Updates
              _buildNotificationToggle(
                title: 'Service Updates',
                subtitle: 'Get notified about booking and service changes',
                value: _orderUpdates,
                icon: Icons.assignment,
                onChanged: (value) {
                  setState(() => _orderUpdates = value);
                },
                delay: 0.25,
              ),
              const SizedBox(height: 12),
              // Promotions & Offers
              _buildNotificationToggle(
                title: 'Promotions & Deals',
                subtitle: 'Receive exclusive offers and discounts',
                value: _promotions,
                icon: Icons.local_offer,
                onChanged: (value) {
                  setState(() => _promotions = value);
                },
                delay: 0.3,
              ),
              const SizedBox(height: 12),
              // Account Notifications
              _buildNotificationToggle(
                title: 'Security Alerts',
                subtitle: 'Important account and security updates',
                value: _accountNotifications,
                icon: Icons.shield,
                onChanged: (value) {
                  setState(() => _accountNotifications = value);
                },
                delay: 0.35,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C6BFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Notification settings saved successfully!'),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  label: const Text(
                    'Save Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2C6BFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2C6BFF), size: 20),
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
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
    required double delay,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(delay, delay + 0.3, curve: Curves.easeOut))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: value
                  ? const Color(0xFF2C6BFF).withOpacity(0.3)
                  : Colors.grey.shade200,
              width: value ? 1.5 : 1),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: const Color(0xFF2C6BFF).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C6BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2C6BFF), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF2C6BFF),
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
