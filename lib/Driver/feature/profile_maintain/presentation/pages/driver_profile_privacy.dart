import 'package:flutter/material.dart';

class DriverProfilePrivacy extends StatefulWidget {
  const DriverProfilePrivacy({super.key});

  @override
  State<DriverProfilePrivacy> createState() => _DriverProfilePrivacyState();
}

class _DriverProfilePrivacyState extends State<DriverProfilePrivacy> {
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
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
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
            // Last Update
            Text(
              'Last Update: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white30,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            // Privacy Policy Content
            const Text(
              'Welcome to BinGo. This Privacy Policy explains how we collect, use, and protect your personal information when you use our waste management driver application. By using BinGo as a driver, you agree to the collection and use of information in accordance with this policy.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We are committed to ensuring that your privacy is protected. Should we ask you to provide certain information by which you can be identified when using this app, you can be assured that it will only be used in accordance with this privacy statement.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            // Terms & Conditions Section
            const Text(
              'Key Privacy Principles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Term 1
            _buildTermItem(
              number: '1',
              title: 'Information Collection',
              content:
                  'We collect information to provide better delivery services. This includes your name, contact number, license information, vehicle details, and address. We also securely store your location data during active deliveries and transaction records for your payment history.',
            ),
            const SizedBox(height: 16),
            // Term 2
            _buildTermItem(
              number: '2',
              title: 'How We Use Your Information',
              content:
                  'The information we collect is used to facilitate smooth waste collection and delivery services, process payments, and improve our platform. Your location data is used to optimize delivery routes and provide real-time tracking to customers. We may also use your contact details to send important service updates and delivery notifications.',
            ),
            const SizedBox(height: 16),
            // Term 3
            _buildTermItem(
              number: '3',
              title:
                  'Data Security',
              content:
                  'We are committed to ensuring that your information is secure. In order to prevent unauthorized access or disclosure, we have put in place suitable physical, electronic and managerial procedures to safeguard and secure the information we collect online via Firebase. Driver credentials and vehicle information are encrypted and securely stored.',
            ),
            const SizedBox(height: 16),
            // Term 4
            _buildTermItem(
              number: '4',
              title: 'Location Tracking',
              content:
                  'Location data is collected during active deliveries to provide customers with accurate tracking and delivery updates. This data is only accessible to authorized BinGo personnel and is deleted after 30 days. We do not share your location with third parties without explicit consent.',
            ),
            const SizedBox(height: 16),
            // Term 5
            _buildTermItem(
              number: '5',
              title: 'Payment Information',
              content:
                  'We securely process your payment information through encrypted channels. We do not store complete payment card information on our servers. All transaction records are maintained for accounting and dispute resolution purposes only.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem({
    required String number,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$number.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
