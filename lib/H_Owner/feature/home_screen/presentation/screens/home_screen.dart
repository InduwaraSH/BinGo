import 'package:bingo/H_Owner/feature/home_screen/presentation/bloc/home_cubit.dart';
import 'package:bingo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/user_header.dart';
import '../widgets/search_section.dart';
import '../widgets/current_tracking_card.dart';
import '../widgets/features_row.dart';
import '../widgets/recent_activities.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              const UserHeader(),

              //const SearchSection(),
              const SizedBox(height: 32),

              // Listen to Cubit state changes here
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    );
                  } else if (state is HomeError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is HomeLoaded) {
                    // Pass the loaded state data to your widget
                    // Note: You will need to update CurrentTrackingCard to accept these parameters!
                    return CurrentTrackingCard(
                      trackingNumber: state.activeTrackingNumber,
                      location: state.currentLocation,
                      status: state.status,
                    );
                  }

                  return const SizedBox.shrink(); // Initial state fallback
                },
              ),

              const SizedBox(height: 32),
              const FeaturesRow(),
              const SizedBox(height: 32),
              const RecentActivities(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
