import 'package:flutter/material.dart';
import 'H_Owner_Profile_FAQ.dart';

class HOwnerProfileContactUs extends StatefulWidget {
  const HOwnerProfileContactUs({super.key});

  @override
  State<HOwnerProfileContactUs> createState() =>
      _HOwnerProfileContactUsState();
}

class _HOwnerProfileContactUsState extends State<HOwnerProfileContactUs>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  late AnimationController _animationController;

  final List<ContactMethod> _contactMethods = [
    ContactMethod(
      icon: Icons.headphones,
      title: 'Customer Support',
      details: 'Get help from our support team',
      contactInfo: 'support@bingo.com | +1 (800) 123-4567',
      action: 'Contact Now',
      color: Colors.deepPurple,
    ),
    ContactMethod(
      icon: Icons.language,
      title: 'Visit Website',
      details: 'Explore our official platform',
      contactInfo: 'www.bingoapp.io',
      action: 'Visit',
      color: Colors.blue,
    ),
    ContactMethod(
      icon: Icons.chat,
      title: 'Live Chat',
      details: 'Chat with support agent in real-time',
      contactInfo: 'Available 24/7',
      action: 'Chat',
      color: Colors.teal,
    ),
    ContactMethod(
      icon: Icons.facebook,
      title: 'Facebook Community',
      details: 'Join our Facebook community',
      contactInfo: '@bingoapp | 50K+ followers',
      action: 'Follow',
      color: const Color(0xFF1877F2),
    ),
    ContactMethod(
      icon: Icons.camera_alt,
      title: 'Instagram',
      details: 'Follow us for updates and tips',
      contactInfo: '@bingo_app | 75K+ followers',
      action: 'Follow',
      color: const Color(0xFFE4405F),
    ),
  ];

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
    final filteredMethods = _contactMethods
        .where((item) =>
            item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 240,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF2C6BFF),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2C6BFF),
                        Colors.blue.shade700,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Help Center',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We\'re here to help. Reach out anytime!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search contact methods...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFF2C6BFF), size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 12,
                            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...List.generate(filteredMethods.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SlideTransition(
                      position: Tween<Offset>(
                          begin: const Offset(-0.3, 0), end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(0.1 + (index * 0.1), 0.6 + (index * 0.1),
                                  curve: Curves.easeOut))),
                      child: _buildContactMethod(filteredMethods[index]),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.help_outline, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: const Color(0xFF2C6BFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                            color: Color(0xFF2C6BFF), width: 1.5),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const HOwnerProfileFAQ()));
                    },
                    label: const Text(
                      'View FAQ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactMethod(ContactMethod method) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connecting to ${method.title}...'),
                backgroundColor: method.color,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: method.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          method.icon,
                          color: method.color,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method.details,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: method.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: method.color.withOpacity(0.2), width: 1),
                  ),
                  child: Text(
                    method.contactInfo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: method.color,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${method.action} - ${method.title}'),
                          backgroundColor: method.color,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    child: Text(
                      method.action,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactMethod {
  final IconData icon;
  final String title;
  final String details;
  final String contactInfo;
  final String action;
  final Color color;

  ContactMethod({
    required this.icon,
    required this.title,
    required this.details,
    required this.contactInfo,
    required this.action,
    this.color = Colors.blue,
  });
}
