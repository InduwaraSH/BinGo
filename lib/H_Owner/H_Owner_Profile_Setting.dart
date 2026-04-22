import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'H_Owner_Notification_Setting.dart';
import 'H_Owner_Password_Manager.dart';
import 'H_Owner_Delete_Account.dart';

class HOwnerProfileSetting extends StatefulWidget {
  const HOwnerProfileSetting({super.key});

  @override
  State<HOwnerProfileSetting> createState() => _HOwnerProfileSettingState();
}

class _HOwnerProfileSettingState extends State<HOwnerProfileSetting>
    with TickerProviderStateMixin {
  File? _profileImage;
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _profileAnimationController;
  late AnimationController _settingsAnimationController;
  late Animation<double> _headerScaleAnimation;
  late Animation<Offset> _profileSlideAnimation;
  late Animation<double> _settingsFadeAnimation;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();

    // Initialize Animation Controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _settingsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Setup Animations
    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut),
    );

    _profileSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _profileAnimationController, curve: Curves.easeOut),
    );

    _settingsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _settingsAnimationController, curve: Curves.easeIn),
    );

    // Start animations in sequence
    _headerAnimationController.forward();
    _profileAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _settingsAnimationController.forward();
      }
    });

    _loadUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _headerAnimationController.dispose();
    _profileAnimationController.dispose();
    _settingsAnimationController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _nameController.text = user.displayName ?? 'User';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        // Haptic feedback for better UX
        HapticFeedback.mediumImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Image selected successfully'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
      );
    }
  }

  Future<void> _updateUserInfo() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email cannot be empty'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.heavyImpact();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update email if changed
        if (_emailController.text != user.email) {
          await user.verifyBeforeUpdateEmail(_emailController.text);
        }

        // Update display name if changed
        if (_nameController.text != user.displayName) {
          await user.updateDisplayName(_nameController.text);
        }

        if (mounted) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Premium Header with Gradient and Animations
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: ScaleTransition(
                scale: _headerScaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade600,
                        Colors.blue.shade400,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated Decorative circles
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
                              color: Colors.blue.shade300.withOpacity(0.3),
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
                              color: Colors.blue.shade200.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                      // Header Content with Fade Animation
                      FadeTransition(
                        opacity: _headerScaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your preferences',
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
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Settings Items with Profile Edit Section and Animations
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Edit Section with Slide Animation
                  SlideTransition(
                    position: _profileSlideAnimation,
                    child: FadeTransition(
                      opacity: _profileAnimationController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildAnimatedProfileCard(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Preferences Section with Fade Animation
                  FadeTransition(
                    opacity: _settingsFadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferences',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAnimatedSettingItem(
                          index: 0,
                          icon: Icons.notifications_rounded,
                          label: 'Notification Settings',
                          description: 'Manage notification preferences',
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const HOwnerNotificationSetting(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Security Section
                  FadeTransition(
                    opacity: _settingsFadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAnimatedSettingItem(
                          index: 1,
                          icon: Icons.lock_rounded,
                          label: 'Password Manager',
                          description: 'Change your password',
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const HOwnerPasswordManager(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Account Section
                  FadeTransition(
                    opacity: _settingsFadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAnimatedSettingItem(
                          index: 2,
                          icon: Icons.person_remove_rounded,
                          label: 'Delete Account',
                          description: 'Permanently delete your account',
                          isDangerous: true,
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const HOwnerDeleteAccount(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProfileCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: Colors.blue.shade50,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture with Hover Animation
            Center(
              child: Stack(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade300.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage('assets/avatar.png') as ImageProvider,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 1.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: MouseRegion(
                          onEnter: (_) {
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade400.withOpacity(0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Name Field with Focus Animation
            Text(
              'Full Name',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            _buildAnimatedTextField(
              controller: _nameController,
              hintText: 'Enter your name',
            ),
            const SizedBox(height: 18),
            // Email Field with Focus Animation
            Text(
              'Email Address',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            _buildAnimatedTextField(
              controller: _emailController,
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            // Update Button with Interactive Animation
            SizedBox(
              width: double.infinity,
              child: _buildAnimatedButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: Colors.grey.shade50, end: Colors.grey.shade50),
      duration: const Duration(milliseconds: 300),
      builder: (context, color, child) {
        return TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            prefixIcon: Icon(
              keyboardType == TextInputType.emailAddress ? Icons.email_outlined : Icons.person_outline,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          onTap: () => HapticFeedback.lightImpact(),
        );
      },
    );
  }

  Widget _buildAnimatedButton() {
    return AnimatedBuilder(
      animation: _isLoading ? AlwaysStoppedAnimation(1.0) : AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            if (!_isLoading) HapticFeedback.lightImpact();
          },
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: _isLoading ? 4 : 0,
              shadowColor: Colors.blue.shade600.withOpacity(0.4),
            ),
            onPressed: _isLoading ? null : _updateUserInfo,
            child: _isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.blue.shade100,
                      ),
                    ),
                  )
                : const Text(
                    'Update Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSettingItem({
    required int index,
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
    bool isDangerous = false,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero),
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
        onEnter: (_) => HapticFeedback.lightImpact(),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDangerous
                        ? Colors.red.shade200.withOpacity(0.15)
                        : Colors.blue.shade200.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 0.5,
                  ),
                ],
                border: Border.all(
                  color: isDangerous
                      ? Colors.red.shade100.withOpacity(0.5)
                      : Colors.grey.shade100,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDangerous
                            ? [Colors.red.shade300, Colors.red.shade600]
                            : [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDangerous
                              ? Colors.red.shade400.withOpacity(0.3)
                              : Colors.blue.shade400.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDangerous ? Colors.red.shade600 : Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
