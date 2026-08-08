import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../Common/Logging.dart';
import '../Common/auth_checker.dart';

class HOwnerPendingApproval extends StatelessWidget {
  final bool isRejected;

  const HOwnerPendingApproval({super.key, this.isRejected = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isRejected ? Colors.redAccent : const Color(0xFF00B4FF)).withOpacity(0.12),
                ),
                child: Icon(
                  isRejected ? Iconsax.close_circle : Iconsax.timer_1,
                  color: isRejected ? Colors.redAccent : const Color(0xFF00B4FF),
                  size: 44,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                isRejected ? 'Registration Declined' : 'Awaiting Approval',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isRejected
                    ? "Your registration wasn't approved by admin. Please contact support if you think this is a mistake."
                    : "Your registration is being reviewed by admin. You'll be able to use BinGo once it's approved.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              if (!isRejected)
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthChecker()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00B4FF),
                    side: const BorderSide(color: Color(0xFF00B4FF)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Check Again', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Logging()),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Sign Out', style: TextStyle(color: Colors.white38)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
