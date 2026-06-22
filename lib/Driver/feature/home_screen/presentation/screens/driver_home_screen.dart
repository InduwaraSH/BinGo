import 'package:bingo/Driver/feature/home_screen/presentation/bloc/driver_home_cubit.dart';
import 'package:bingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bingo/Driver/feature/home_screen/presentation/widgets/driver_user_header.dart';
import 'package:bingo/Driver/feature/home_screen/presentation/widgets/driver_current_delivery_card.dart';
import 'package:bingo/Driver/feature/home_screen/presentation/widgets/driver_stats_row.dart';
import 'package:bingo/Driver/feature/home_screen/presentation/widgets/driver_quick_actions.dart';
import 'package:bingo/Driver/feature/home_screen/presentation/widgets/driver_recent_deliveries.dart';
import 'package:bingo/Driver/feature/profile_maintain/presentation/widgets/driver_profile_drawer.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      drawer: const DriverProfileDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DriverUserHeader(),
                const SizedBox(height: 28),

                // Stats Row with animations
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                  ),
                  child: const DriverStatsRow(),
                ),
                const SizedBox(height: 28),

                // Current Delivery Card with Bloc
                BlocBuilder<DriverHomeCubit, DriverHomeState>(
                  builder: (context, state) {
                    if (state is DriverHomeLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: AppColors.accentGreen,
                          ),
                        ),
                      );
                    } else if (state is DriverHomeError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is DriverHomeLoaded) {
                      return DriverCurrentDeliveryCard(
                        deliveryNumber: state.activeDeliveryNumber,
                        location: state.currentLocation,
                        status: state.status,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 28),

                // Quick Actions with stagger animation
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                  ),
                  child: const DriverQuickActions(),
                ),
                const SizedBox(height: 28),

                // Recent Deliveries
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                  ),
                  child: const DriverRecentDeliveries(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

