import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class DriReg extends StatefulWidget {
  const DriReg({super.key});

  @override
  State<DriReg> createState() => _DriRegState();
}

class _DriRegState extends State<DriReg> with TickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circlePulse;
  late Animation<Offset> _circleMove1;
  late Animation<Offset> _circleMove2;

  late AnimationController _pageController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late DatabaseReference personReference;
  late DatabaseReference DeiverProfileRef;

  bool _isSubmitting = false;

  // Text controllers
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    personReference = FirebaseDatabase.instance.ref().child("Persons");
    DeiverProfileRef = FirebaseDatabase.instance.ref().child("Driver_Profiles");

    // Background animations
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _circlePulse = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    _circleMove1 =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.05, -0.09),
        ).animate(
          CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
        );

    _circleMove2 =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.05, 0.09),
        ).animate(
          CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
        );

    // Page animation
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeInOutCubic,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));

    _pageController.forward();
  }

  @override
  void dispose() {
    _circleController.dispose();
    _pageController.dispose();
    idController.dispose();
    nameController.dispose();
    nicController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // ------------------ Logic ------------------
  Future<void> _submitData() async {
    setState(() => _isSubmitting = true);

    bool result = await InternetConnection().hasInternetAccess;
    if (!result) {
      _showSnack('No internet connection', Colors.grey);
      setState(() => _isSubmitting = false);
      return;
    }

    if (idController.text.isEmpty ||
        nameController.text.isEmpty ||
        mobileController.text.isEmpty ||
        nicController.text.isEmpty ||
        addressController.text.isEmpty ||
        passwordController.text.isEmpty ||
        emailController.text.isEmpty ||
        rePasswordController.text.isEmpty ||
        passwordController.text != rePasswordController.text) {
      _showSnack('Please fill all fields correctly', Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }

    Map<String, String> driverData = {
      "Id": idController.text,
      "Name": nameController.text,
      "Mobile": mobileController.text,
      "Type": "Driver",
      "Mail": emailController.text,
      "Address": addressController.text,
      "Password": passwordController.text,
    };

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      String safeEmail = emailController.text.trim().replaceAll('.', '_');

      await personReference.child(safeEmail).set(driverData);
      await DeiverProfileRef.child(
        "House_Profile",
      ).child(safeEmail).child("Profile_Info").set({
        "Owner_Name": nameController.text.trim(),
        "Owner_Mobile": mobileController.text.trim(),
        "Owner_NIC": nicController.text.trim(),
        "Owner_Email": emailController.text.trim(),
        "Owner_Address": addressController.text.trim().replaceAll('/', '_'),
        "Registered_House_ID": idController.text.trim().replaceAll('/', '_'),
      });
      _showSnack(
        '${nameController.text} Registration Request Sent Successfully',
        Colors.green,
      );

      idController.clear();
      nameController.clear();
      nicController.clear();
      mobileController.clear();
      passwordController.clear();
      rePasswordController.clear();
      emailController.clear();
      addressController.clear();
    } catch (error) {
      _showSnack("Failed to save data: $error", Colors.redAccent);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ------------------ Snackbar UI ------------------
  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF00B4FF), const Color(0xFF6DD3FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                color == Colors.green
                    ? Icons.check_circle
                    : color == Colors.red
                    ? Icons.error
                    : Icons.info,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final themeAccent = LinearGradient(
      colors: [const Color(0xFF00B4FF), const Color(0xFF6DD3FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Stack(
            children: [
              // Tech background
              Positioned.fill(child: _buildTechBackground()),

              // Animated glowing circles
              _buildAnimatedBackground(),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: themeAccent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.6),
                                  offset: const Offset(0, 6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.truck,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'BinGo',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Driver',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Header card
                      _headerCard(),
                      const SizedBox(height: 18),

                      // Form
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Iconsax.profile_2user,
                                  color: Color(0xFF8EE7FF),
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Driver Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            _buildLabeledField(
                              'Job ID',
                              'E.g. D-125',
                              Iconsax.card,
                              idController,
                            ),
                            _buildLabeledField(
                              'Email',
                              'driver@example.com',
                              Icons.mail_outline,
                              emailController,
                            ),
                            _buildLabeledField(
                              'Address',
                              'Street, City, ZIP',
                              Iconsax.location,
                              addressController,
                              maxLines: 2,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLabeledField(
                                    'Full Name',
                                    'John Doe',
                                    Iconsax.user,
                                    nameController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildLabeledField(
                                    'NIC',
                                    '123456789V',
                                    Iconsax.personalcard,
                                    nicController,
                                  ),
                                ),
                              ],
                            ),
                            _buildLabeledField(
                              'Mobile',
                              '+94 7x xxx xxxx',
                              Iconsax.call,
                              mobileController,
                              keyboardType: TextInputType.phone,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLabeledField(
                                    'Password',
                                    '••••••••',
                                    Iconsax.lock,
                                    passwordController,
                                    isPassword: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildLabeledField(
                                    'Confirm',
                                    '••••••••',
                                    Iconsax.lock,
                                    rePasswordController,
                                    isPassword: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: GestureDetector(
                                onTap: _isSubmitting ? null : _submitData,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: themeAccent,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00B4FF,
                                        ).withOpacity(0.18),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isSubmitting
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Submitting...',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            'Send Registration Request',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),
                      Row(
                        children: const [
                          Icon(
                            Iconsax.info_circle,
                            color: Colors.white30,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your details will be verified by admin. Keep information accurate.',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),

              if (_isSubmitting)
                Container(
                  color: Colors.black.withOpacity(0.55),
                  child: Center(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1.2, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _pageController,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00B4FF).withOpacity(0.18),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00B4FF,
                                ).withOpacity(0.35),
                                blurRadius: 40,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Color(0xFF6DD3FF),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Verifying...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ UI Helpers ------------------
  Widget _buildTechBackground() {
    return CustomPaint(
      painter: _GridPainter(),
      child: Container(color: Colors.transparent),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _circleController,
      builder: (context, child) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Transform.translate(
                offset: Offset(
                  90 * _circleMove1.value.dx,
                  70 * _circleMove1.value.dy,
                ),
                child: Transform.scale(
                  scale: _circlePulse.value,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0E5AA7).withOpacity(0.18),
                          const Color(0xFF00B4FF).withOpacity(0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B4FF).withOpacity(0.12),
                          blurRadius: 60,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Transform.translate(
                offset: Offset(
                  -50 * _circleMove2.value.dx,
                  -40 * _circleMove2.value.dy,
                ),
                child: Transform.scale(
                  scale: _circlePulse.value,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6A0FA6).withOpacity(0.08),
                          const Color(0xFF00B4FF).withOpacity(0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A0FA6).withOpacity(0.12),
                          blurRadius: 80,
                          spreadRadius: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Iconsax.truck, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Register as Driver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Register once so admins can assign pickups. Your data is secure.',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '*',
                style: TextStyle(color: Color(0xFF6DD3FF), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white30, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.02);
    final step = 28.0;
    for (double x = 0; x < size.width; x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    final paint2 = Paint()..color = Colors.white.withOpacity(0.008);
    for (double x = -size.height; x < size.width; x += 56) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
