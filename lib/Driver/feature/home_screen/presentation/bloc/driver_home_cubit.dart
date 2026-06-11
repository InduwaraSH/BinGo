import 'package:flutter_bloc/flutter_bloc.dart';

part 'driver_home_state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  // In a real app, you would inject a UseCase or Repository here
  DriverHomeCubit() : super(DriverHomeInitial());

  void fetchDashboardData() async {
    emit(DriverHomeLoading());

    try {
      // Simulating an API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Emitting success state with dummy data
      emit(
        DriverHomeLoaded(
          activeDeliveryNumber: '#DRV01-EUFD24C',
          currentLocation: 'Condong Catur, Yogyakarta',
          status: 'in transit',
        ),
      );
    } catch (e) {
      emit(DriverHomeError('Failed to load delivery data.'));
    }
  }
}
