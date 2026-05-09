import 'package:flutter/material.dart';
import 'H_Owner_Profile_FAQ.dart';

class HOwnerProfileContactUs extends StatefulWidget {
  const HOwnerProfileContactUs({super.key});

  @override
  State<HOwnerProfileContactUs> createState() =>
      _HOwnerProfileContactUsState();
}

class _HOwnerProfileContactUsState extends State<HOwnerProfileContactUs> {
  String _searchQuery = '';

  final List<ContactMethod> _contactMethods = [
    ContactMethod(
      icon: Icons.headphones,
      title: 'Customer Service',
      details: 'Available 24/7 for your support needs',
      contactInfo: 'Call: +1 (800) 123-4567',
      action: 'Contact Now',
    ),
    ContactMethod(
      icon: Icons.language,
      title: 'Website',
      details: 'Visit our official website',
      contactInfo: 'www.bingo.com',
      action: 'Visit',
    ),
    ContactMethod(
      icon: Icons.phone,
      title: 'Whatsapp',
      details: 'Chat with us on WhatsApp',
      contactInfo: '+1 (555) 987-6543',
      action: 'Message',
    ),
    ContactMethod(
      icon: Icons.facebook,
      title: 'Facebook',
      details: 'Follow us on Facebook',
      contactInfo: '@bingoapp',
      action: 'Follow',
    ),
    ContactMethod(
      icon: Icons.camera_alt,
      title: 'Instagram',
      details: 'Follow us on Instagram',
      contactInfo: '@bingo_app',
      action: 'Follow',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredMethods = _contactMethods
        .where((item) =>
            item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.blue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.blue,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Help Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'How Can We Help You?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tab Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          side: BorderSide(color: Colors.blue.shade200),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const HOwnerProfileFAQ(),
                            ),
                          );
                        },
                        child: const Text(
                          'FAQ',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Contact Us',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Contact Methods
                ...List.generate(filteredMethods.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildContactMethod(filteredMethods[index]),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactMethod(ContactMethod method) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      backgroundColor: Colors.blue.shade50,
      collapsedBackgroundColor: Colors.blue.shade50,
      leading: Icon(
        method.icon,
        color: Colors.blue,
        size: 28,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            method.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            method.details,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                method.contactInfo,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connecting to ${method.title}...'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  method.action,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ContactMethod {
  final IconData icon;
  final String title;
  final String details;
  final String contactInfo;
  final String action;

  ContactMethod({
    required this.icon,
    required this.title,
    required this.details,
    required this.contactInfo,
    required this.action,
  });
}
