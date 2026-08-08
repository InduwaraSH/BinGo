import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Writes the driver's live GPS position to `driver_locations/{driverId}`
/// while at least one job is assigned to them for today. Runs in the
/// background (not just while a driver screen is open) via geolocator's
/// Android foreground-service / iOS background-location support.
class DriverLocationService {
  DriverLocationService._();
  static final DriverLocationService instance = DriverLocationService._();

  StreamSubscription<Position>? _subscription;
  String? _activeDriverId;

  final RxBool isTracking = false.obs;

  Future<bool> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return false;
    if (permission == LocationPermission.denied) return false;

    // Ask again for "always" (background) access on platforms that
    // distinguish it — starting from "while in use" prompts the upgrade.
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  LocationSettings _buildLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'BinGo Driver',
          notificationText: "Sharing your live location for today's pickup",
          enableWakeLock: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 15,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15);
  }

  Future<void> startTracking(String driverId, {String? activeRequestId}) async {
    if (_activeDriverId == driverId && _subscription != null) return;
    await stopTracking();

    final granted = await _ensurePermission();
    if (!granted) return;

    _activeDriverId = driverId;

    _subscription = Geolocator.getPositionStream(locationSettings: _buildLocationSettings())
        .listen((Position position) {
      FirebaseFirestore.instance.collection('driver_locations').doc(driverId).set({
        'lat': position.latitude,
        'lng': position.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
        'activeRequestId': activeRequestId,
      }, SetOptions(merge: true));
    });

    isTracking.value = true;
  }

  Future<void> stopTracking() async {
    await _subscription?.cancel();
    _subscription = null;
    _activeDriverId = null;
    isTracking.value = false;
  }
}
