import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'H_Owner_Profile_ContactUs.dart';

class HOwnerProfileFAQ extends StatefulWidget {
  const HOwnerProfileFAQ({super.key});

  @override
  State<HOwnerProfileFAQ> createState() => _HOwnerProfileFAQState();
}

class _HOwnerProfileFAQState extends State<HOwnerProfileFAQ>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Lorem ipsum dolor sit amet?',
      answer:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a. Proin ac dictumst.',
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
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -1, end: 0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentAnimationController, curve: Curves.easeIn),
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _faqItems
        .where((item) =>
            item.question.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 240,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.teal),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SlideTransition(
                position: AlwaysStoppedAnimation(
                    Offset(_headerSlideAnimation.value, 0)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.teal.shade600,
                        Colors.teal.shade400,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.shade300.withOpacity(0.2),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.shade200.withOpacity(0.15),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FadeTransition(
                              opacity: _headerSlideAnimation.drive(
                                Tween<double>(begin: 0, end: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Help Center',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'How Can We Help You?',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildAnimatedSearchField(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: FadeTransition(
          opacity: _contentFadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Tab Buttons
                  _buildAnimatedTabButtons(),
                  const SizedBox(height: 24),

                  /// Category Tags
                  _buildAnimatedCategoryTags(),
                  const SizedBox(height: 24),

                  /// FAQ Items
                  ...List.generate(filteredItems.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAnimatedFAQItem(filteredItems[index], index),
                    );
                  }),
                  if (filteredItems.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.teal.shade200,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSearchField() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          HapticFeedback.lightImpact();
        },
        decoration: InputDecoration(
          hintText: 'Search FAQs...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.teal.shade600,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() => _searchQuery = '');
                    HapticFeedback.lightImpact();
                  },
                  child: Icon(
                    Icons.clear_rounded,
                    color: Colors.teal.shade600,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAnimatedTabButtons() {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(offset),
          child: FadeTransition(
            opacity: AlwaysStoppedAnimation(1.0 - (offset.dy * 0.5)),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.teal.shade400.withOpacity(0.4),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                child: const Text(
                  'FAQ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: Colors.teal.shade300,
                    width: 1.5,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const HOwnerProfileContactUs(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                            opacity: animation, child: child);
                      },
                    ),
                  );
                },
                child: Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Colors.teal.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCategoryTags() {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(offset),
          child: child,
        );
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildAnimatedCategoryTag('Popular', true, 0),
            const SizedBox(width: 10),
            _buildAnimatedCategoryTag('General', false, 1),
            const SizedBox(width: 10),
            _buildAnimatedCategoryTag('Services', false, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCategoryTag(String label, bool isActive, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (100 * index)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.7 + (value * 0.3),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isActive ? Colors.teal.shade600 : Colors.teal.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: isActive ? 4 : 0,
            shadowColor: Colors.teal.shade400.withOpacity(0.3),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
          },
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.teal.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFAQItem(FAQItem item, int index) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero),
      duration: Duration(milliseconds: 600 + (100 * index)),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(offset),
          child: FadeTransition(
            opacity: AlwaysStoppedAnimation(1.0 - offset.dx),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.teal.shade100, width: 1.2),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.teal.shade100, width: 1.2),
            ),
            backgroundColor: Colors.teal.shade50,
            collapsedBackgroundColor: Colors.white,
            iconColor: Colors.teal.shade600,
            collapsedIconColor: Colors.teal.shade400,
            onExpansionChanged: (expanded) {
              HapticFeedback.lightImpact();
            },
            title: Text(
              item.question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Text(
                  item.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.8,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
