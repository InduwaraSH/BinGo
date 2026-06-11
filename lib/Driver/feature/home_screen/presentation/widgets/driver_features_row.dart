import 'package:bingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DriverFeaturesRow extends StatelessWidget {
  const DriverFeaturesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFeatureBox(
          icon: Icons.location_on_outlined,
          label: 'Live Map',
          color: AppColors.accentGreen,
        ),
        _buildFeatureBox(
          icon: Icons.phone_outlined,
          label: 'Support',
          color: AppColors.accentGreen,
        ),
        _buildFeatureBox(
          icon: Icons.history,
          label: 'History',
          color: AppColors.accentGreen,
        ),
        _buildFeatureBox(
          icon: Icons.settings_outlined,
          label: 'Settings',
          color: AppColors.accentGreen,
        ),
      ],
    );
  }

  Widget _buildFeatureBox({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
