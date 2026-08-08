import 'package:bingo/Common/Logging.dart';
import 'package:bingo/Driver/Dri_Nav_Bar.dart';
import 'package:bingo/H_Owner/h_owner_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  // We will store the destination screen here once we know it
  Widget? _targetScreen;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    // 1. If not logged in, go straight to Logging
    if (user == null || user.email == null) {
      if (mounted) {
        setState(() => _targetScreen = const Logging());
      }
      return;
    }

    // 2. Logged in -> Fetch role with a 10-second timeout so it never hangs forever
    try {
      String safeEmailKey = user.email!.replaceAll('.', '_');
      DatabaseReference dbref = FirebaseDatabase.instance
          .ref()
          .child("Persons")
          .child(safeEmailKey);

      final snapshotType = await dbref
          .child('Type')
          .get()
          .timeout(const Duration(seconds: 10));
      final snapshotName = await dbref
          .child('Name')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snapshotType.exists && snapshotName.exists) {
        String type = snapshotType.value.toString();
        String name = snapshotName.value.toString();

        if (mounted) {
          if (type == 'House_Owner') {
            setState(
              () => _targetScreen = HOwnerNavBar(
                office_location: name,
                username: user.email!,
              ),
            );
          } else {
            setState(
              () => _targetScreen = DriNavBar(
                office_location: name,
                username: user.email!,
              ),
            );
          }
        }
      } else {
        // Data missing -> log out
        await FirebaseAuth.instance.signOut();
        if (mounted) setState(() => _targetScreen = const Logging());
      }
    } catch (e) {
      // If network fails or timeout hits -> log out and show login
      await FirebaseAuth.instance.signOut();
      if (mounted) setState(() => _targetScreen = const Logging());
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we have found the screen, render it immediately! No navigator needed.
    if (_targetScreen != null) {
      return _targetScreen!;
    }

    // Otherwise, show the loading spinner while we check
    return const Scaffold(
      backgroundColor: Color(0xFF0B1220),
      body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
    );
  }
}
