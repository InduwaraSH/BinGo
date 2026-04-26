import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color scaffoldDark = Color(0xFF07121A);
  static const Color cardDark = Color(0xFF0D1B2A);
  static const Color surfaceDark = Color(0xFF112240);

  static const Color primaryBlue = Color(0xFF00B4FF);
  static const Color accentCyan = Color(0xFF6DD3FF);
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFFF5252);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0E1628), Color(0xFF122844), Color(0xFF0E1628)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration glassCard({double opacity = 0.03}) => BoxDecoration(
    color: Colors.white.withOpacity(opacity),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.06)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static String safeEmail(String email) => email.trim().replaceAll('.', '_');
}
