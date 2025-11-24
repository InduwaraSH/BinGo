import 'package:flutter/material.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Add Card', style: TextStyle(color: Colors.black)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.blue.shade400),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    const Text('000 000 000 00', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('John Doe', style: TextStyle(color: Colors.white70)),
                        Text('04/28', style: TextStyle(color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildField('Card Holder Name', controller: _name, hint: 'John Doe'),
            const SizedBox(height: 12),
            _buildField('Card Number', controller: _number, hint: '000 000 000 00'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildField('Expiry Date', controller: _expiry, hint: '04/28')),
                const SizedBox(width: 10),
                Expanded(child: _buildField('CVV', controller: _cvv, hint: '0000')),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C6BFF), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
              onPressed: () {
                // For now, just pop and pretend we saved
                Navigator.of(context).pop();
              },
              child: const Text('Save Card', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, {required TextEditingController controller, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(controller: controller, decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.blue.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      ],
    );
  }
}
