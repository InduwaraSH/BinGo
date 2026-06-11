import 'package:bingo/Driver/feature/home_screen/presentation/bloc/driver_home_cubit.dart';
import 'package:bingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bingo/Driver/feature/home_screen/presentation/widgets/driver_user_header.dart';
import 'package:bingo/Driver/feature/home_screen/presentation/widgets/driver_current_tracking_card.dart';
import 'package:bingo/Driver/feature/home_screen/presentation/widgets/driver_features_row.dart';
import 'package:bingo/Driver/feature/home_screen/presentation/widgets/driver_recent_activities.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DriverUserHeader(),

              //const SearchSection(),
              const SizedBox(height: 32),

              // Listen to Cubit state changes here
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
                    // Pass the loaded state data to your widget
                    // Note: You will need to update DriverCurrentTrackingCard to accept these parameters!
                    return DriverCurrentTrackingCard(
                      deliveryNumber: state.activeDeliveryNumber,
                      location: state.currentLocation,
                      status: state.status,
                    );
                  }

                  return const SizedBox.shrink(); // Initial state fallback
                },
              ),

              const SizedBox(height: 32),
              const DriverFeaturesRow(),
              const SizedBox(height: 32),
              const DriverRecentActivities(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
