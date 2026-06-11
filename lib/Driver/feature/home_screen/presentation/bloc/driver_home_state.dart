part of 'driver_home_cubit.dart';

abstract class DriverHomeState {}

class DriverHomeInitial extends DriverHomeState {}

class DriverHomeLoading extends DriverHomeState {}

class DriverHomeLoaded extends DriverHomeState {
  // In a full app, you would pass a Domain Entity here instead of separate strings
  final String activeDeliveryNumber;
  final String currentLocation;
  final String status;

  DriverHomeLoaded({
    required this.activeDeliveryNumber,
    required this.currentLocation,
    required this.status,
  });
}

class DriverHomeError extends DriverHomeState {
  final String message;

  DriverHomeError(this.message);
}
