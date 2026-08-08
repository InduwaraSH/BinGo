import 'package:bingo/H_Owner/feature/payment/presentation/pages/payment_success_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'add_card_page.dart';
import '../widgets/payment_background.dart';

class PaymentMethodPage extends StatefulWidget {
  final double amount;
  const PaymentMethodPage({super.key, required this.amount});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String _selected = 'card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Payment Method',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: PaymentBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Credit & Debit Card',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() => _selected = 'card');
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => const AddCardPage(),
                          ),
                        )
                        .then((_) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PaymentSuccessPage(amount: widget.amount),
                            ),
                          );
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selected == 'card'
                            ? const Color(0xFF00B4FF).withOpacity(0.5)
                            : Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B4FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Iconsax.card,
                            color: Color(0xFF00B4FF),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Add New Card',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.white54,
                          ),
                          child: Radio<String>(
                            value: 'card',
                            groupValue: _selected,
                            onChanged: (v) =>
                                setState(() => _selected = v ?? 'card'),
                            activeColor: const Color(0xFF00B4FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'More Payment Options',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _optionRow(
                  icon: Icons.apple,
                  label: 'Apple Pay',
                  value: 'apple',
                ),
                const SizedBox(height: 12),
                _optionRow(
                  icon: Icons.paypal,
                  label: 'Paypal',
                  value: 'paypal',
                ),
                const SizedBox(height: 12),
                _optionRow(
                  icon: Icons.g_mobiledata,
                  label: 'Google Pay',
                  value: 'google',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    bool isSelected = _selected == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selected = value);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(amount: widget.amount),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00B4FF).withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00B4FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00B4FF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Theme(
              data: ThemeData(unselectedWidgetColor: Colors.white54),
              child: Radio<String>(
                value: value,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v ?? value),
                activeColor: const Color(0xFF00B4FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
