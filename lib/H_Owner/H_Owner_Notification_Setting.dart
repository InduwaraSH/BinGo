import 'package:flutter/material.dart';

class HOwnerNotificationSetting extends StatefulWidget {
  const HOwnerNotificationSetting({super.key});

  @override
  State<HOwnerNotificationSetting> createState() =>
      _HOwnerNotificationSettingState();
}

class _HOwnerNotificationSettingState extends State<HOwnerNotificationSetting> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _accountNotifications = true;

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
          'Notification Settings',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Notification Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Push Notifications
            _buildNotificationToggle(
              title: 'Push Notifications',
              subtitle: 'Receive mobile app notifications',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
              },
            ),
            const SizedBox(height: 16),
            // Email Notifications
            _buildNotificationToggle(
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
              },
            ),
            const SizedBox(height: 16),
            // SMS Notifications
            _buildNotificationToggle(
              title: 'SMS Notifications',
              subtitle: 'Receive text message updates',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() => _smsNotifications = value);
              },
            ),
            const SizedBox(height: 28),
            const Text(
              'Notification Types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Order Updates
            _buildNotificationToggle(
              title: 'Order Updates',
              subtitle: 'Get notified about order status changes',
              value: _orderUpdates,
              onChanged: (value) {
                setState(() => _orderUpdates = value);
              },
            ),
            const SizedBox(height: 16),
            // Promotions & Offers
            _buildNotificationToggle(
              title: 'Promotions & Offers',
              subtitle: 'Receive promotional offers and discounts',
              value: _promotions,
              onChanged: (value) {
                setState(() => _promotions = value);
              },
            ),
            const SizedBox(height: 16),
            // Account Notifications
            _buildNotificationToggle(
              title: 'Account Notifications',
              subtitle: 'Important account and security updates',
              value: _accountNotifications,
              onChanged: (value) {
                setState(() => _accountNotifications = value);
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings updated!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
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
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
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
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
