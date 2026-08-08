import 'package:bingo/core/theme/app_colors.dart';
import 'package:bingo/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class FeaturesRow extends StatelessWidget {
  const FeaturesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Feature', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFeatureItem(Icons.inventory_2_outlined, 'Order'),
            _buildFeatureItem(Icons.attach_money, 'Shipping Cost'),
            _buildFeatureItem(Icons.support_agent, 'Call Center'),
            _buildFeatureItem(Icons.receipt_long, 'Check Receipt'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.darkCard,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accentGreen, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.subtitle.copyWith(fontSize: 11)),
      ],
    );
  }
}
