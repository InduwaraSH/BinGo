import 'package:flutter/material.dart';

class HOwnerProfilePrivacy extends StatefulWidget {
  const HOwnerProfilePrivacy({super.key});

  @override
  State<HOwnerProfilePrivacy> createState() => _HOwnerProfilePrivacyState();
}

class _HOwnerProfilePrivacyState extends State<HOwnerProfilePrivacy> {
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
          'Privacy Policy',
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
            // Last Update
            Text(
              'Last Update: 08/04/2024',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            // Privacy Policy Content
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a. Proin ac dictumst. Aenean in sagittis magna, ut feugiat diam. Fusce a scelerisque neque, sed ac semper metus.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nunc auctor tortor in dolor luctus, quis eulsmod urna tincidunt. Aenean arcu metus, bibendum ut rhoncus sit, volutpat ut lacus. Morbi pellentesque malesuada aeros semper ultricies. Vestibulum lobortis enim vel neque auctor, a ultricies es phaetra. Mauris ut lacinia justo, sed susceptt tortor. Nam egestas nulla posuere neque rhoncbus parr.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            // Terms & Conditions Section
            const Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Term 1
            _buildTermItem(
              number: '1',
              title: 'Ut lacinia justo sit amet lorem sodales accusam.',
              content:
                  'Proin malesuada eleifend fermentum. Donec convallis, nunc at rhoncus lobotris et mi, laoreet ipsum, eu pharetra eros est vitae orci. Morbi auris nibh, nullam lacinia tortor tincidunt. Duis laoreet, ex eget rutrum pharetra, lectus nisl posuere netus, vel facilisis nis telus ac.',
            ),
            const SizedBox(height: 16),
            // Term 2
            _buildTermItem(
              number: '2',
              title: 'Ut lacinia justo sit amet lorem sodales accusam.',
              content:
                  'Proin malesuada eleifend fermentum. Donec convallis, nunc at rhoncus lobotris et mi, laoreet ipsum, eu pharetra eros est vitae orci. Morbi auris nibh, nullam lacinia tortor tincidunt. Duis laoreet, ex eget rutrum pharetra, lectus nisl posuere netus, vel facilisis nis telus ac.',
            ),
            const SizedBox(height: 16),
            // Term 3
            _buildTermItem(
              number: '3',
              title:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
              content:
                  'Proin pellentesque congue lorem, vel volutpat leo placerat a. Proin ac dictumst. Aenean in sagittis magna, ut feugiat diam.',
            ),
            const SizedBox(height: 16),
            // Term 4
            _buildTermItem(
              number: '4',
              title: 'Nunc auctor tortor in dolor luctus, quis eulsmod urna.',
              content:
                  'tincidunt. Aenean arcu metus, bibendum at rhoncus sit, volutpat ut lacus. Morbi pellentesque malesuada aeros semper ultricies. Vestibulum lobortis enim vel neque auctor, a ultricies es phaetra. Mauris ut lacinia justo, sed susceptt tortor. Nam egestas nulla posuere neque.',
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
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
