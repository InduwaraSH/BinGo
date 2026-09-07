import 'package:bingo/Common/auth_checker.dart';
import 'package:bingo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? firebaseError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error) {
    firebaseError = error;
  }

  runApp(MyApp(firebaseError: firebaseError));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.firebaseError});

  final Object? firebaseError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07121A),
      ),
      home: firebaseError == null
          ? const AuthChecker()
          : StartupError(error: firebaseError!),
    );
  }
}

class StartupError extends StatelessWidget {
  const StartupError({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Unable to initialize the app.\n$error'),
        ),
      ),
    );
  }
}
