import 'package:flutter/material.dart';
import 'add_card.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage>
    with SingleTickerProviderStateMixin {
  String _selected = 'card';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Payment Methods',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Credit & Debit Cards', 'Secure payment method'),
              const SizedBox(height: 16),
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.0, 0.5, curve: Curves.easeOut))),
                child: _buildCardOption(),
              ),
              const SizedBox(height: 40),
              _buildSectionHeader('Digital Wallets', 'Fast & convenient payments'),
              const SizedBox(height: 16),
              ..._buildPaymentOptions(),
              const SizedBox(height: 32),
              _buildSecurityInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCardOption() {
    return GestureDetector(
      onTap: () {
        setState(() => _selected = 'card');
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AddCardPage()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _selected == 'card'
              ? const Color(0xFF2C6BFF).withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: _selected == 'card'
                ? const Color(0xFF2C6BFF)
                : Colors.grey.shade200,
            width: _selected == 'card' ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C6BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.credit_card,
                  color: Color(0xFF2C6BFF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add New Card',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('VISA, MasterCard, Amex',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Radio<String>(
              value: 'card',
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v ?? 'card'),
              activeColor: const Color(0xFF2C6BFF),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPaymentOptions() {
    final options = [
      {
        'icon': Icons.apple,
        'label': 'Apple Pay',
        'value': 'apple',
        'desc': 'Fast and secure',
        'color': Colors.black87
      },
      {
        'icon': Icons.paypal,
        'label': 'PayPal',
        'value': 'paypal',
        'desc': 'Buyer protection',
        'color': const Color(0xFF0070BA)
      },
      {
        'icon': Icons.g_mobiledata,
        'label': 'Google Pay',
        'value': 'google',
        'desc': 'Save time & money',
        'color': const Color(0xFF3C4043)
      },
    ];

    return List.generate(
      options.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(-0.5, 0), end: Offset.zero)
              .animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(0.1 + (index * 0.15), 0.6 + (index * 0.15),
                      curve: Curves.easeOut))),
          child: _optionRow(
            icon: options[index]['icon'] as IconData,
            label: options[index]['label'] as String,
            desc: options[index]['desc'] as String,
            value: options[index]['value'] as String,
            color: options[index]['color'] as Color,
          ),
        ),
      ),
    );
  }

  Widget _optionRow({
    required IconData icon,
    required String label,
    required String desc,
    required String value,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _selected == value ? color.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color:
                _selected == value ? color : Colors.grey.shade200,
            width: _selected == value ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v ?? value),
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user, color: Colors.green.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Secure Payment',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text('All transactions are encrypted & protected',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
