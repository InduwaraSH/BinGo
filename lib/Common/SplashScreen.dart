import 'package:bingo/Common/Logging.dart';
import 'package:bingo/Common/app_theme.dart';
import 'package:bingo/Driver/Dri_Nav_Bar.dart';
import 'package:bingo/H_Owner/H_Owner_NAv_Bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _checkAuthState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || !mounted) {
      _navigateTo(const Logging());
      return;
    }

    try {
      final safeEmail = AppTheme.safeEmail(user.email ?? '');
      final dbRef = FirebaseDatabase.instance.ref().child("Persons/$safeEmail");

      final typeSnap = await dbRef.child('Type').get();
      final nameSnap = await dbRef.child('Name').get();

      if (!typeSnap.exists || !nameSnap.exists || !mounted) {
        await FirebaseAuth.instance.signOut();
        _navigateTo(const Logging());
        return;
      }

      final type = typeSnap.value.toString();
      final name = nameSnap.value.toString();
      final email = user.email ?? '';

      if (type == 'House_Owner') {
        _navigateTo(HOwnerNavBar(office_location: name, username: email));
      } else {
        _navigateTo(DriNavBar(office_location: name, username: email));
      }
    } catch (_) {
      if (mounted) _navigateTo(const Logging());
    }
  }

  void _navigateTo(Widget destination) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.4),
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
                  const SizedBox(height: 28),
                  const Text(
                    'BinGo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Smart Waste Collection',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppTheme.accentCyan.withOpacity(0.6),
                    ),
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
