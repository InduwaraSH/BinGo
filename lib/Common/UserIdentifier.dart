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
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _animateShapes = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 400), () {
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
            colors: [Color(0xFF0A0F1F), Color(0xFF1A2238)],
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
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          // 🌀 Dynamic background gradient
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

          // 🔵 Floating glow particles
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOutCubic,
            top: _animateShapes ? -50 : -200,
            right: _animateShapes ? -40 : -100,
            child: AnimatedOpacity(
              opacity: _animateShapes ? 1 : 0,
              duration: const Duration(seconds: 3),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOutCubic,
            bottom: _animateShapes ? -60 : -250,
            left: _animateShapes ? -50 : -120,
            child: AnimatedOpacity(
              opacity: _animateShapes ? 1 : 0,
              duration: const Duration(seconds: 3),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.cyanAccent.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ⚡ Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 50),
              child: AnimatedOpacity(
                opacity: _animateContent ? 1 : 0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🧠 App logo or icon
                    Container(
                      height: 100,
                      width: 100,
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
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.user_octagon,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 🧩 Title
                    const Text(
                      "Identify Yourself",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontFamily: "sfProRoundSemiB",
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Select your role to continue registration.\nYour experience will be tailored accordingly.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                        fontFamily: "sfproRoundRegular",
                      ),
                    ),
                    const SizedBox(height: 50),

                    // 🧭 Role Selector
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Choose Role",
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
                                magnification: 1.2,
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
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    _selectedRole = index;
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
                                        fontSize: 22,
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
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Iconsax.personalcard,
                                    color: Colors.white70,
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
                          const Text(
                            "Driver → Operates garbage collection vehicles.\nHouse Owner → Resident registering for pickups.",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                              height: 1.4,
                              fontFamily: "sfproRoundRegular",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),

                    // 🚀 Next Button
                    GestureDetector(
                      onTap: () {
                        String selected = _roles[_selectedRole];
                        if (selected == 'Driver') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DriReg()),
                          );
                        } else if (selected == 'House Owner') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => HOwnerReg()),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Iconsax.arrow_right_3,
                          color: Colors.white,
                          size: 36,
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
