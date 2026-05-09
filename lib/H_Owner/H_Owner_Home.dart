import 'package:bingo/Common/Logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HOwnerHome extends StatefulWidget {
  const HOwnerHome({super.key});

  @override
  State<HOwnerHome> createState() => _HOwnerHomeState();
}

class _HOwnerHomeState extends State<HOwnerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 100),
          const Center(child: Text('H Owner Home Screen')),
          CupertinoButton(
            child: const Text("Logout"),
            onPressed: () {
              FirebaseAuth.instance.signOut().whenComplete(() {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => Logging()),
                  (route) => false,
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
