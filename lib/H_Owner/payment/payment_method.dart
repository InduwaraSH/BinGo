import 'package:flutter/material.dart';
import 'add_card.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String _selected = 'card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Payment Method', style: TextStyle(color: Colors.black)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Credit & Debit Card', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() => _selected = 'card');
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCardPage()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Add New Card', style: TextStyle(color: Colors.black54))),
                    Radio<String>(value: 'card', groupValue: _selected, onChanged: (v) => setState(() => _selected = v ?? 'card')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('More Payment Option', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _optionRow(icon: Icons.apple, label: 'Apple Play', value: 'apple'),
            const SizedBox(height: 10),
            _optionRow(icon: Icons.paypal, label: 'Paypal', value: 'paypal'),
            const SizedBox(height: 10),
            _optionRow(icon: Icons.g_mobiledata, label: 'Google Play', value: 'google'),
          ],
        ),
      ),
    );
  }

  Widget _optionRow({required IconData icon, required String label, required String value}) {
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.black54))),
            Radio<String>(value: value, groupValue: _selected, onChanged: (v) => setState(() => _selected = v ?? value)),
          ],
        ),
      ),
    );
  }
}
