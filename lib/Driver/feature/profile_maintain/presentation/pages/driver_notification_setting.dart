import 'package:flutter/material.dart';

class DriverNotificationSetting extends StatefulWidget {
  const DriverNotificationSetting({super.key});

  @override
  State<DriverNotificationSetting> createState() =>
      _DriverNotificationSettingState();
}

class _DriverNotificationSettingState extends State<DriverNotificationSetting> {
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool smsNotifications = true;
  bool deliveryAlerts = true;

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
          'Notification Settings',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildNotificationToggle(
              title: 'Push Notifications',
              value: pushNotifications,
              onChanged: (value) {
                setState(() => pushNotifications = value);
              },
            ),
            const SizedBox(height: 16),
            _buildNotificationToggle(
              title: 'Email Notifications',
              value: emailNotifications,
              onChanged: (value) {
                setState(() => emailNotifications = value);
              },
            ),
            const SizedBox(height: 16),
            _buildNotificationToggle(
              title: 'SMS Notifications',
              value: smsNotifications,
              onChanged: (value) {
                setState(() => smsNotifications = value);
              },
            ),
            const SizedBox(height: 16),
            _buildNotificationToggle(
              title: 'Delivery Alerts',
              value: deliveryAlerts,
              onChanged: (value) {
                setState(() => deliveryAlerts = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00B4FF),
          ),
        ],
      ),
    );
  }
}
