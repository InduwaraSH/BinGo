import 'package:flutter/material.dart';
import 'payment_method.dart';
import 'payment_success.dart';

class PaymentPage extends StatelessWidget {
  final double amount;

  const PaymentPage({super.key, this.amount = 100.0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Payment', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF2C6BFF),
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text('Package Renewal', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C6BFF))),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _detailRow('Date/Time', 'Month 24, Year / 10:00 AM'),
                  const SizedBox(height: 10),
                  _detailRow('Duration', '30 Days'),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 12),
                  _detailRow('Amount', '\$${"100.00"}'),
                  const SizedBox(height: 10),
                  _detailRow('Duration', '30 Minutes'),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _detailRow('Total', '\$${"100"}'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Payment Method', style: TextStyle(color: Colors.black54)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentMethodPage())),
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C6BFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentSuccessPage()));
                    },
                    child: const Text('Pay Now', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const Spacer(),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
