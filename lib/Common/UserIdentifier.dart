import 'package:bingo/Driver/Dri_Reg.dart';
import 'package:bingo/H_Owner/H_Owner_Reg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Useridentifier extends StatefulWidget {
  const Useridentifier({super.key});

  @override
  State<Useridentifier> createState() => _UseridentifierState();
}

class _UseridentifierState extends State<Useridentifier>
    with SingleTickerProviderStateMixin {
  int _selectedRole = 0;
  bool _animateShapes = false;
  bool _animateContent = false;

  static const double _kItemExtent = 40.0;
  static const List<String> _roles = <String>['Driver', 'House Owner'];

  @override
  void initState() {
    super.initState();

    // Trigger smooth animation after build
    Future.delayed(const Duration(milliseconds: 00), () {
      setState(() {
        _animateShapes = true;
      });
    });

    // Content fade-in after shapes move
    Future.delayed(const Duration(milliseconds: 00), () {
      setState(() {
        _animateContent = true;
      });
    });
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 260,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF111827), Color(0xFF1F2937)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(top: false, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E141E),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF141E30), Color(0xFF243B55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🔵 Animated Top Circle
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOutCubic,
            top: _animateShapes ? -50 : -200,
            right: _animateShapes ? -40 : -100,
            child: AnimatedOpacity(
              opacity: _animateShapes ? 1 : 0,
              duration: const Duration(seconds: 3),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.cyanAccent.shade100],
                  ),
                ),
              ),
            ),
          ),

          // 🟣 Animated Bottom Circle
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOutCubic,
            bottom: _animateShapes ? -70 : -250,
            left: _animateShapes ? -50 : -120,
            child: AnimatedOpacity(
              opacity: _animateShapes ? 1 : 0,
              duration: const Duration(seconds: 3),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.pinkAccent.shade100,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✨ Main Content (Animated Fade-in)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: AnimatedOpacity(
                opacity: _animateContent ? 1 : 0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "Who Are You?",
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "sfProRoundSemiB",
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Before registering, please select your role.\nThis helps us verify your information properly.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: "sfproRoundRegular",
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),

                    // Glassmorphic role selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Select Your Role",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: "sfProRoundSemiB",
                            ),
                          ),
                          const SizedBox(height: 20),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _showDialog(
                              CupertinoPicker(
                                magnification: 1.3,
                                squeeze: 1.2,
                                useMagnifier: true,
                                itemExtent: _kItemExtent,
                                scrollController: FixedExtentScrollController(
                                  initialItem: _selectedRole,
                                ),
                                selectionOverlay:
                                    CupertinoPickerDefaultSelectionOverlay(
                                      background: Colors.blueAccent.withOpacity(
                                        0.15,
                                      ),
                                    ),
                                onSelectedItemChanged: (int selectedItem) {
                                  setState(() {
                                    _selectedRole = selectedItem;
                                  });
                                },
                                children: List<Widget>.generate(_roles.length, (
                                  int index,
                                ) {
                                  return Center(
                                    child: Text(
                                      _roles[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: "sfProRoundSemiB",
                                        fontSize: 24,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 30,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Iconsax.briefcase,
                                    color: Colors.white70,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _roles[_selectedRole],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: "sfProRoundSemiB",
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Iconsax.arrow_down_1,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white24, thickness: 1),
                          const SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Driver - Tractor Driver",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  fontFamily: "sfproRoundRegular",
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "House Owner - Person who owns a house",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  fontFamily: "sfproRoundRegular",
                                ),
                              ),
                              SizedBox(height: 6),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),

                    // 🌈 Next button (glowing gradient)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          String selected = _roles[_selectedRole];
                          if (selected == 'Driver') {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (_) => DriReg()),
                            // );
                          } else if (selected == 'House Owner') {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (_) => HOwnerReg()),
                            // );
                          }
                        },
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeInOutCubic,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.9 + (0.1 * value),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Iconsax.arrow_right_3,
                              color: Colors.white,
                              size: 32,
                            ),
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
      ),
    );
  }
}
