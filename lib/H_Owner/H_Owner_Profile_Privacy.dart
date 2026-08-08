import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HOwnerProfilePrivacy extends StatefulWidget {
  const HOwnerProfilePrivacy({super.key});

  @override
  State<HOwnerProfilePrivacy> createState() => _HOwnerProfilePrivacyState();
}

class _HOwnerProfilePrivacyState extends State<HOwnerProfilePrivacy>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerScaleAnimation;
  late Animation<double> _contentFadeAnimation;
  late List<AnimationController> _termControllers;

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

    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentAnimationController, curve: Curves.easeIn),
    );

    _termControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
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
    for (var controller in _termControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          /// Animated Header
          SliverAppBar(
            expandedHeight: 160,
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
                      color: Colors.blue),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ScaleTransition(
                scale: _headerScaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.shade600,
                        Colors.purple.shade400,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50,
                        right: -50,
                        child: ScaleTransition(
                          scale: _headerScaleAnimation,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purple.shade300.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: ScaleTransition(
                          scale: _headerScaleAnimation,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purple.shade200.withOpacity(0.15),
                            ),
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: _headerScaleAnimation,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your privacy matters to us',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          /// Animated Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Last Update Card
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purple.shade100,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              color: Colors.purple.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Last Update: 08/04/2024',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.purple.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// Description Card
                    _buildAnimatedDescriptionCard(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque congue lorem, vel volutpat leo placerat a. Proin ac dictumst. Aenean in sagittis magna, ut feugiat diam.',
                      0,
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedDescriptionCard(
                      'Nunc auctor tortor in dolor luctus, quis eulsmod urna tincidunt. Aenean arcu metus, bibendum ut rhoncus sit, volutpat ut lacus.',
                      1,
                    ),
                    const SizedBox(height: 32),

                    /// Terms & Conditions Section
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedTermItem(
                      index: 0,
                      number: '1',
                      title: 'Ut lacinia justo sit amet lorem sodales accusam.',
                      content:
                          'Proin malesuada eleifend fermentum. Donec convallis, nunc at rhoncus lobotris et mi, laoreet ipsum.',
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedTermItem(
                      index: 1,
                      number: '2',
                      title: 'Ut lacinia justo sit amet lorem sodales accusam.',
                      content:
                          'Proin malesuada eleifend fermentum. Donec convallis, nunc at rhoncus lobotris et mi.',
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedTermItem(
                      index: 2,
                      number: '3',
                      title:
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                      content:
                          'Proin pellentesque congue lorem, vel volutpat leo placerat a. Proin ac dictumst.',
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedTermItem(
                      index: 3,
                      number: '4',
                      title:
                          'Nunc auctor tortor in dolor luctus, quis eulsmod urna.',
                      content:
                          'Tincidunt. Aenean arcu metus, bibendum at rhoncus sit, volutpat ut lacus.',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDescriptionCard(String text, int index) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero),
      duration: Duration(milliseconds: 600 + (100 * index)),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.shade100.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.8,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTermItem({
    required int index,
    required String number,
    required String title,
    required String content,
  }) {
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.purple.shade100,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.shade100.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade600,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        number,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.6,
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
