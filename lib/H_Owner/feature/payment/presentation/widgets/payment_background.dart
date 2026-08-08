import 'package:flutter/material.dart';

class PaymentBackground extends StatefulWidget {
  final Widget child;

  const PaymentBackground({super.key, required this.child});

  @override
  State<PaymentBackground> createState() => _PaymentBackgroundState();
}

class _PaymentBackgroundState extends State<PaymentBackground> with TickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circlePulse;
  late Animation<Offset> _circleMove1;
  late Animation<Offset> _circleMove2;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _circlePulse = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    _circleMove1 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, -0.09),
    ).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    _circleMove2 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.05, 0.09),
    ).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
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
                              const Color(0xFF0E5AA7).withOpacity(0.15),
                              const Color(0xFF00B4FF).withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B4FF).withOpacity(0.1),
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
                              const Color(0xFF00B4FF).withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6A0FA6).withOpacity(0.1),
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
        ),
        widget.child,
      ],
    );
  }
}
