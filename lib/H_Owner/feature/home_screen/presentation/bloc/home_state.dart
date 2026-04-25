part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  // In a full app, you would pass a Domain Entity here instead of separate strings
  final String activeTrackingNumber;
  final String currentLocation;
  final String status;

  HomeLoaded({
    required this.activeTrackingNumber,
    required this.currentLocation,
    required this.status,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
