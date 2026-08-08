import 'package:flutter/material.dart';
import 'payment_method.dart';
import 'payment_success.dart';

class PaymentPage extends StatefulWidget {
  final double amount;

  const PaymentPage({super.key, this.amount = 299.99});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
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
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Order Summary',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
        ),
        child: Column(
          children: [
            SlideTransition(
              position: Tween<Offset>(
                  begin: const Offset(0, -0.3), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOutCubic)),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2C6BFF),
                      Color(0xFF1E4BA5),
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Text('Total Amount',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Text('\$${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.2, 0.8,
                            curve: Curves.easeOut)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(
                        icon: Icons.info_outline,
                        title: 'Premium Membership',
                        subtitle: 'Annual subscription',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      _buildDetailSection(),
                      const SizedBox(height: 28),
                      _buildPricingBreakdown(),
                      const SizedBox(height: 28),
                      _buildPaymentMethodSelector(),
                      const SizedBox(height: 32),
                      _buildPaymentButton(context),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                              color: Color(0xFF2C6BFF), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back',
                            style: TextStyle(
                                color: Color(0xFF2C6BFF),
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _detailRow('Subscription Period',
              'April 22, 2026 - April 21, 2027'),
          const Divider(height: 16),
          _detailRow('Renewal Date', 'April 21, 2027'),
          const Divider(height: 16),
          _detailRow('Features', '✓ Unlimited Access + Support'),
        ],
      ),
    );
  }

  Widget _buildPricingBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _detailRow('Membership Fee', '\$${(widget.amount * 0.9).toStringAsFixed(2)}',
              isBold: false),
          const SizedBox(height: 12),
          _detailRow('Platform Fee', '\$${(widget.amount * 0.1).toStringAsFixed(2)}',
              isBold: false),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade300, height: 1),
          ),
          _detailRow('Total', '\$${widget.amount.toStringAsFixed(2)}',
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C6BFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.credit_card,
                        color: Color(0xFF2C6BFF), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Credit Card',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black87)),
                      Text('4532 •••• •••• 8901',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const PaymentMethodPage())),
                child: const Text('Change',
                    style: TextStyle(color: Color(0xFF2C6BFF))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.check_circle_outline, size: 20),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C6BFF),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const PaymentSuccessPage()));
      },
      label: const Text('Complete Payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _detailRow(String title, String value,
      {bool isBold = true, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 12,
              color: isTotal ? const Color(0xFF2C6BFF) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

