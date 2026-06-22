import 'package:bingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DriverRecentDeliveries extends StatelessWidget {
  const DriverRecentDeliveries({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Deliveries',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'View All',
              style: TextStyle(
                color: AppColors.accentGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDeliveryItem(
          icon: Icons.check_circle,
          title: 'Delivery #DRV001',
          subtitle: 'Completed at 2:30 PM',
          location: 'Jalan Gatot Subroto, Jakarta',
          timeAgo: '2 hours ago',
          status: 'completed',
        ),
        const SizedBox(height: 10),
        _buildDeliveryItem(
          icon: Icons.local_shipping,
          title: 'Delivery #DRV002',
          subtitle: 'In Transit',
          location: 'Jalan Sudirman, Jakarta',
          timeAgo: '30 minutes ago',
          status: 'in_transit',
        ),
        const SizedBox(height: 10),
        _buildDeliveryItem(
          icon: Icons.schedule,
          title: 'Delivery #DRV003',
          subtitle: 'Scheduled for today',
          location: 'Jalan Ahmad Yani, Jakarta',
          timeAgo: '5 minutes ago',
          status: 'pending',
        ),
      ],
    );
  }

  Widget _buildDeliveryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String location,
    required String timeAgo,
    required String status,
  }) {
    Color statusColor = AppColors.accentGreen;
    Color statusBgColor = AppColors.accentGreen.withOpacity(0.1);

    if (status == 'pending') {
      statusColor = const Color(0xFFFFA500);
      statusBgColor = const Color(0xFFFFA500).withOpacity(0.1);
    } else if (status == 'in_transit') {
      statusColor = const Color(0xFF00A8FF);
      statusBgColor = const Color(0xFF00A8FF).withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status == 'completed'
                            ? 'Completed'
                            : status == 'in_transit'
                                ? 'In Transit'
                                : 'Pending',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
