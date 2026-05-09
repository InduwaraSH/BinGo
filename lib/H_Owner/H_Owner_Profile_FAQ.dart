import 'package:flutter/material.dart';
import 'H_Owner_Profile_ContactUs.dart';

class HOwnerProfileFAQ extends StatefulWidget {
  const HOwnerProfileFAQ({super.key});

  @override
  State<HOwnerProfileFAQ> createState() => _HOwnerProfileFAQState();
}

class _HOwnerProfileFAQState extends State<HOwnerProfileFAQ> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Lorem ipsum dolor sit amet?',
      answer:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a. Proin ac dictumst. Aenean in sagittis magna, ut feugiat diam.',
    ),
    FAQItem(
      question: 'Lorem ipsum dolor sit amet?',
      answer:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a.',
    ),
    FAQItem(
      question: 'Lorem ipsum dolor sit amet?',
      answer:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a.',
    ),
    FAQItem(
      question: 'Lorem ipsum dolor sit amet?',
      answer:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a.',
    ),
    FAQItem(
      question: 'Lorem ipsum dolor sit amet?',
      answer:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a.',
    ),
    FAQItem(
      question: 'Lorem ipsum dolor sit amet?',
      answer:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a.',
    ),
    FAQItem(
      question: 'Lorem ipsum dolor sit amet?',
      answer:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a.',
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredItems = _faqItems
        .where((item) =>
            item.question.toLowerCase().contains(_searchQuery.toLowerCase()))
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
                          'FAQ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              builder: (_) => const HOwnerProfileContactUs(),
                            ),
                          );
                        },
                        child: const Text(
                          'Contact Us',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Category Tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryTag('Popular Topic', true),
                      const SizedBox(width: 8),
                      _buildCategoryTag('General', false),
                      const SizedBox(width: 8),
                      _buildCategoryTag('Services', false),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // FAQ Items
                ...List.generate(filteredItems.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildFAQItem(filteredItems[index]),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String label, bool isActive) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.blue.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {},
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
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
      title: Text(
        item.question,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            item.answer,
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

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
