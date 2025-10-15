import 'package:bingo/Common/UserIdentifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Logging extends StatefulWidget {
  const Logging({super.key});

  @override
  State<Logging> createState() => _LoggingState();
}

class _LoggingState extends State<Logging> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisibleButton = true;
  bool isVisibleLoading = false;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF111827), Color(0xFF1F2937)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.cyanAccent.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.pinkAccent.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Login Card
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome Back 👋",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: "sfProRoundSemiB",
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Sign in to continue to your account",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: "sfproRoundRegular",
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ID Field
                      _buildInputField(
                        controller: usernameController,
                        hintText: "Enter your ID Number",
                        icon: Iconsax.user,
                      ),
                      const SizedBox(height: 25),

                      // Password Field
                      _buildInputField(
                        controller: passwordController,
                        hintText: "Enter your Password",
                        icon: Iconsax.lock,
                        isPassword: true,
                      ),

                      const SizedBox(height: 30),

                      // Login Button
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: isVisibleButton
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isVisibleButton = false;
                                    isVisibleLoading = true;
                                  });

                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      setState(() {
                                        isVisibleButton = true;
                                        isVisibleLoading = false;
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00C6FF),
                                        Color(0xFF0072FF),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent.withOpacity(
                                          0.4,
                                        ),
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

                      // Forgot password
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

                      const SizedBox(height: 30),
                      Divider(color: Colors.white24, thickness: 1),
                      const SizedBox(height: 20),

                      // Create Account Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.of(context).push(_createRoute());
                            },
                            child: const CircleAvatar(
                              radius: 26,
                              backgroundColor: Color(0xFF00C853),
                              child: Icon(
                                Iconsax.building_4,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "No account yet?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: "sfproRoundSemiB",
                            ),
                          ),
                          const SizedBox(width: 12),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.of(context).push(_createRoute());
                            },
                            child: const CircleAvatar(
                              radius: 26,
                              backgroundColor: Color(0xFF1E88E5),
                              child: Icon(
                                Iconsax.user_add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Use CupertinoPageRoute for native smooth + swipe-back
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
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscurePassword : false,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: "sfproRoundRegular",
        ),
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
