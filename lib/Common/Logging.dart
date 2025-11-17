import 'package:bingo/Common/UserIdentifier.dart';
import 'package:bingo/Driver/Dri_Nav_Bar.dart';
import 'package:bingo/H_Owner/H_Owner_NAv_Bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class Logging extends StatefulWidget {
  const Logging({super.key});

  @override
  State<Logging> createState() => _LoggingState();
}

class _LoggingState extends State<Logging> with TickerProviderStateMixin {
  final useremailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisibleButton = true;
  bool isVisibleLoading = false;
  bool obscurePassword = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          // ✨ Gradient background
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0E1628),
                  Color(0xFF122844),
                  Color(0xFF0E1628),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🔵 Animated background glows
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              final glow = (_glowController.value * 0.5) + 0.5;
              return Stack(
                children: [
                  Positioned(
                    top: -80,
                    right: -60,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(glow * 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -60,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyanAccent.withOpacity(glow * 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 💎 Login Form
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 60,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🧠 App Icon
                    Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BFFF), Color(0xFF0072FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.truck,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Title
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontFamily: "sfProRoundSemiB",
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Login to continue managing your account.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: "sfproRoundRegular",
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 45),

                    // 🧩 Glass input fields
                    _buildInputField(
                      controller: useremailController,
                      hintText: "Enter your Email",
                      icon: Iconsax.user,
                    ),
                    const SizedBox(height: 25),
                    _buildInputField(
                      controller: passwordController,
                      hintText: "Enter your Password",
                      icon: Iconsax.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 40),

                    // Login button
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: isVisibleButton
                          ? GestureDetector(
                              onTap: () async {
                                if (useremailController.text.isEmpty ||
                                    passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please fill in all fields.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'sfpro',
                                          fontSize: 18,
                                        ),
                                      ),
                                      duration: Duration(seconds: 5),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isVisibleButton = false;
                                  isVisibleLoading = true;
                                });

                                bool result =
                                    await InternetConnectionChecker.createInstance()
                                        .hasConnection;

                                if (!result) {
                                  setState(() {
                                    isVisibleButton = true;
                                    isVisibleLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'No internet connection',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'sfpro',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.grey,
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  await FirebaseAuth.instance.signOut();
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                        email: useremailController.text.trim(),
                                        password: passwordController.text,
                                      );

                                  // Firebase keys cannot contain ".", "#", "$", "[", or "]"
                                  String safeEmailKey = useremailController.text
                                      .trim()
                                      .replaceAll('.', '_');

                                  DatabaseReference dbref = FirebaseDatabase
                                      .instance
                                      .ref()
                                      .child("Persons")
                                      .child(safeEmailKey);

                                  final snapshotType = await dbref
                                      .child('Type')
                                      .get();
                                  final snapshotName = await dbref
                                      .child('Name')
                                      .get();

                                  if (snapshotType.exists &&
                                      snapshotName.exists) {
                                    String type = snapshotType.value.toString();
                                    String name = snapshotName.value.toString();

                                    if (type == 'House_Owner') {
                                      await Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HOwnerNavBar(
                                            office_location: name,
                                            username: useremailController.text
                                                .trim(),
                                          ),
                                        ),
                                      );
                                    } else {
                                      await Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DriNavBar(
                                            office_location: name,
                                            username: useremailController.text
                                                .trim(),
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No user data found.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'sfpro',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        duration: Duration(seconds: 3),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Login failed: ${e.toString()}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'sfpro',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      duration: Duration(seconds: 4),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isVisibleButton = true;
                                      isVisibleLoading = false;
                                    });
                                  }
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00C6FF),
                                      Color(0xFF0072FF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      fontFamily: "sfProRoundSemiB",
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const CupertinoActivityIndicator(
                              radius: 14,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 25),

                    // Forgot Password
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.blueAccent.shade100,
                          fontSize: 15,
                          fontFamily: "sfproRoundSemiB",
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Divider
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "or",
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // 🌍 Register Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.of(context).push(_createRoute());
                          },
                          child: const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFF00C853),
                            child: Icon(
                              Iconsax.building_4,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text(
                          "No account yet?",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontFamily: "sfproRoundSemiB",
                          ),
                        ),
                        const SizedBox(width: 20),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.of(context).push(_createRoute());
                          },
                          child: const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFF1E88E5),
                            child: Icon(Iconsax.user_add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Navigation animation
  Route _createRoute() {
    return CupertinoPageRoute(builder: (context) => const Useridentifier());
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscurePassword : false,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                )
              : null,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
