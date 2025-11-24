import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C6BFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 56, backgroundColor: Colors.white, child: Icon(Icons.check, size: 64, color: Color(0xFF2C6BFF))),
                  SizedBox(height: 20),
                  Text('Congratulation', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Payment is Successfully', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                child: Column(
                  children: const [
                    Text('You have successfully renewed your Membership', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    SizedBox(height: 10),
                    Text('Month 24, Year', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
