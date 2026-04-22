import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class HOwnerProfileEdit extends StatefulWidget {
  final Function(File?)? onImageSelected;

  const HOwnerProfileEdit({super.key, this.onImageSelected});

  @override
  State<HOwnerProfileEdit> createState() => _HOwnerProfileEditState();
}

class _HOwnerProfileEditState extends State<HOwnerProfileEdit>
    with TickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _userTypeController = TextEditingController();

  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _isLoadingUserData = true;

  // Firebase instances
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _fieldsAnimationController;
  late Animation<double> _headerScaleAnimation;
  late Animation<double> _fieldsFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fieldsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Setup Animations
    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut),
    );

    _fieldsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fieldsAnimationController, curve: Curves.easeIn),
    );

    // Start animations and load user data
    _headerAnimationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Get email from Firebase Auth
        _emailController.text = user.email ?? 'Not provided';

        // Try to fetch additional user data from Realtime Database
        final DatabaseReference ref = _firebaseDatabase.ref('users/${user.uid}');
        final snapshot = await ref.get();

        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            _fullNameController.text = data['fullName'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _dobController.text = data['dateOfBirth'] ?? 'DD / MM / YYYY';
            _userTypeController.text = data['userType'] ?? 'User';
          }
        } else {
          // Set default values if no database record exists
          _fullNameController.text = user.displayName ?? '';
          _phoneController.text = '';
          _dobController.text = 'DD / MM / YYYY';
          _userTypeController.text = 'User';
        }
      }

      if (mounted) {
        setState(() => _isLoadingUserData = false);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _fieldsAnimationController.forward();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUserData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: $e'),
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
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _userTypeController.dispose();
    _headerAnimationController.dispose();
    _fieldsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        HapticFeedback.mediumImpact();
        widget.onImageSelected?.call(_profileImage);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile image updated successfully! 📸'),
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
      HapticFeedback.vibrate();
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

  Future<void> _updateProfile() async {
    if (_fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your full name'),
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
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Update user display name in Firebase Auth
        await user.updateDisplayName(_fullNameController.text);

        // Update user data in Realtime Database
        final DatabaseReference ref = _firebaseDatabase.ref('users/${user.uid}');
        await ref.update({
          'fullName': _fullNameController.text,
          'phone': _phoneController.text,
          'dateOfBirth': _dobController.text,
          'userType': _userTypeController.text,
          'email': _emailController.text,
          'lastUpdated': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully! ✓'),
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
    if (_isLoadingUserData) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          /// Premium Animated Header
          SliverAppBar(
            expandedHeight: 220,
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
                        Colors.blue.shade600,
                        Colors.blue.shade400,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated Background Elements
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
                              color: Colors.blue.shade300.withOpacity(0.2),
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
                              color: Colors.blue.shade200.withOpacity(0.15),
                            ),
                          ),
                        ),
                      ),
                      // Profile Picture with Upload Animation
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 1000),
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
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.shade300
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 58,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.1),
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : const AssetImage('assets/avatar.png')
                                              as ImageProvider,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        onEnter: (_) {
                                          HapticFeedback.lightImpact();
                                        },
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                              begin: 1.0, end: 1.0),
                                          duration: const Duration(
                                              milliseconds: 500),
                                          builder: (context, scale, child) {
                                            return Transform.scale(
                                              scale: scale,
                                              child: child,
                                            );
                                          },
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.green.shade400,
                                                  Colors.green.shade600,
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green.shade400
                                                      .withOpacity(0.5),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeTransition(
                              opacity: _headerScaleAnimation,
                              child: Column(
                                children: [
                                  const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Update your information',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.8),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
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
          ),
          /// Animated Form Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fieldsFadeAnimation,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Profile Information Card
                    _buildAnimatedProfileCard(),
                    const SizedBox(height: 32),

                    /// Update Button
                    SizedBox(
                      width: double.infinity,
                      child: _buildAnimatedButton(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
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
        padding: const EdgeInsets.all(24),
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
            _buildAnimatedField(
              index: 0,
              label: 'Full Name',
              controller: _fullNameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildAnimatedField(
              index: 1,
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 20),
            _buildAnimatedField(
              index: 2,
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
              isReadOnly: true,
            ),
            const SizedBox(height: 20),
            _buildAnimatedField(
              index: 3,
              label: 'Date Of Birth',
              controller: _dobController,
              hint: 'DD / MM / YYYY',
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 20),
            _buildAnimatedField(
              index: 4,
              label: 'User Type',
              controller: _userTypeController,
              isReadOnly: true,
              icon: Icons.verified_user_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedField({
    required int index,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    bool isReadOnly = false,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              begin: Colors.grey.shade50,
              end: Colors.grey.shade50,
            ),
            duration: const Duration(milliseconds: 300),
            builder: (context, color, child) {
              return TextField(
                controller: controller,
                keyboardType: keyboardType,
                readOnly: isReadOnly,
                onTap: () => HapticFeedback.lightImpact(),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: color,
                  prefixIcon: Icon(
                    icon,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: Colors.grey.shade200, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: Colors.blue.shade400, width: 2.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton() {
    return AnimatedBuilder(
      animation:
          _isLoading ? AlwaysStoppedAnimation(1.0) : AlwaysStoppedAnimation(0.0),
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
            onPressed: _isLoading ? null : _updateProfile,
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
}
