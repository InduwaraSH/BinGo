import 'package:bingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DriverQuickActions extends StatefulWidget {
  const DriverQuickActions({super.key});

  @override
  State<DriverQuickActions> createState() => _DriverQuickActionsState();
}

class _DriverQuickActionsState extends State<DriverQuickActions> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButton(
              index: 0,
              icon: Icons.map_outlined,
              label: 'Live Map',
              onTap: () {},
            ),
            _buildActionButton(
              index: 1,
              icon: Icons.phone_outlined,
              label: 'Support',
              onTap: () {},
            ),
            _buildActionButton(
              index: 2,
              icon: Icons.rate_review_outlined,
              label: 'Rating',
              onTap: () {},
            ),
            _buildActionButton(
              index: 3,
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isHovered = _hoveredIndex == index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isHovered
                  ? [
                      AppColors.accentGreen.withOpacity(0.2),
                      AppColors.accentGreen.withOpacity(0.1),
                    ]
                  : [
                      Colors.white.withOpacity(0.03),
                      Colors.white.withOpacity(0.02),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovered
                  ? AppColors.accentGreen.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: AppColors.accentGreen.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: isHovered ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  icon,
                  color: AppColors.accentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
