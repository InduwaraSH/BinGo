import 'package:bingo/core/theme/app_colors.dart';
import 'package:bingo/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class DriverRecentActivities extends StatelessWidget {
  const DriverRecentActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activities', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.check_circle_outlined,
          title: 'Delivery Completed',
          subtitle: 'Package delivered to customer',
          time: '2 hours ago',
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.location_on_outlined,
          title: 'Route Updated',
          subtitle: 'New delivery route assigned',
          time: '5 hours ago',
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.notifications_outlined,
          title: 'New Delivery Request',
          subtitle: 'You have a new delivery task',
          time: '1 day ago',
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accentGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
