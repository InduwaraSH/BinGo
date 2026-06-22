import 'package:bingo/core/theme/app_colors.dart';
import 'package:bingo/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class DriverUserHeader extends StatelessWidget {
  const DriverUserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.darkCard,
          child: Icon(
            Icons.person,
            color: AppColors.accentGreen,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Driver', style: AppTextStyles.heading1),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text('Yogyakarta, Indonesia', style: AppTextStyles.subtitle),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.textPrimary,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.menu,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ],
    );
  }
}
