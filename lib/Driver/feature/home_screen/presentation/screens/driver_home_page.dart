import 'package:bingo/Driver/feature/home_screen/presentation/bloc/driver_home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'driver_home_screen.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverHomeCubit()..fetchDashboardData(),
      child: const DriverHomeScreen(),
    );
  }
}

