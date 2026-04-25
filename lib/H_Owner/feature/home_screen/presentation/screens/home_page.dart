import 'package:bingo/H_Owner/feature/home_screen/presentation/bloc/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/home_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Cubit and trigger the initial fetch immediately
    return BlocProvider(
      create: (context) => HomeCubit()..fetchDashboardData(),
      child: const HomeScreen(),
    );
  }
}
