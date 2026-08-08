import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  // In a real app, you would inject a UseCase or Repository here
  HomeCubit() : super(HomeInitial());

  void fetchDashboardData() async {
    emit(HomeLoading());

    try {
      // Simulating an API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Emitting success state with dummy data
      emit(
        HomeLoaded(
          activeTrackingNumber: '#TKP01-EUFD24C',
          currentLocation: 'Condong Catur, Yogyakarta',
          status: 'in transit',
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load tracking data.'));
    }
  }
}
