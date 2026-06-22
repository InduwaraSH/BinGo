import 'package:bingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DriverStatsRow extends StatelessWidget {
  const DriverStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.local_shipping_outlined,
          label: 'Completed',
          value: '12',
          color: AppColors.accentGreen,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.pending_actions_outlined,
          label: 'Pending',
          value: '3',
          color: const Color(0xFFFFA500),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.timeline,
          label: 'Distance',
          value: '24km',
          color: const Color(0xFF00A8FF),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
