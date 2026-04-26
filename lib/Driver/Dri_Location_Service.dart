import 'dart:async';

import 'package:bingo/Common/app_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

/// Publishes the driver's real-time GPS location to Firebase Realtime Database
/// at `Driver_Live_Location/{safeEmail}` while the driver is On Duty.
///
/// Consumers (admin dashboard) can subscribe to that node and render markers
/// on a map.
class DriverLocationService {
  DriverLocationService._internal();
  static final DriverLocationService instance =
      DriverLocationService._internal();

  StreamSubscription<Position>? _positionSub;
  DatabaseReference? _liveRef;
  bool _isPublishing = false;
  String? _currentEmail;
  String? _currentName;

  /// Incremented on every [start]/[stop]. Used to make sure a slow
  /// in-flight position write can't clobber a subsequent session state
  /// (e.g. write `Status: Online` after [stop] wrote `Offline`).
  int _session = 0;

  bool get isPublishing => _isPublishing;

  /// Ensures permission is granted and location services are enabled.
  /// Returns null on success, or an error message suitable for showing to the user.
  Future<String?> ensurePermissions() async {
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      return 'Location services are disabled. Please enable GPS to go on duty.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return 'Location permission was denied.';
    }
    if (permission == LocationPermission.deniedForever) {
      return 'Location permission is permanently denied. Enable it from app settings.';
    }
    return null;
  }

  /// Starts publishing GPS to RTDB. Safe to call repeatedly; no-op if already
  /// running for the same driver. Throws [StateError] with a user-facing
  /// message if permissions aren't granted.
  Future<void> start({
    required String driverEmail,
    required String driverName,
  }) async {
    if (_isPublishing && _currentEmail == driverEmail) return;
    await stop();

    final permissionError = await ensurePermissions();
    if (permissionError != null) {
      throw StateError(permissionError);
    }

    final session = ++_session;
    final safeEmail = AppTheme.safeEmail(driverEmail);
    final ref = FirebaseDatabase.instance
        .ref()
        .child('Driver_Live_Location')
        .child(safeEmail);

    _liveRef = ref;
    _currentEmail = driverEmail;
    _currentName = driverName;

    // Flip to offline automatically if the app/process goes away.
    try {
      await ref.onDisconnect().update({
        'Status': 'Offline',
        'Updated_At': ServerValue.timestamp,
      });
    } catch (_) {
      // Don't fail start() for onDisconnect setup issues; we'll still write updates.
    }

    if (_session != session) return; // stop() ran while we were awaiting.

    // Seed one immediate position so the admin sees the driver instantly.
    try {
      final seed = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      await _writePosition(seed, session: session, initial: true);
    } catch (_) {
      if (_session == session) {
        try {
          await ref.update({
            'Driver_Name': driverName,
            'Driver_Email': driverEmail,
            'Status': 'Online',
            'Updated_At': ServerValue.timestamp,
            'Started_At': ServerValue.timestamp,
          });
        } catch (_) {}
      }
    }

    if (_session != session) return;

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).listen(
      (pos) => _writePosition(pos, session: session),
      onError: (_) {},
      cancelOnError: false,
    );

    _isPublishing = true;
  }

  /// Stops publishing and marks the driver Offline.
  Future<void> stop() async {
    _session++;
    final sub = _positionSub;
    _positionSub = null;
    if (sub != null) {
      try {
        await sub.cancel();
      } catch (_) {}
    }

    final ref = _liveRef;
    _liveRef = null;
    _isPublishing = false;
    _currentEmail = null;
    _currentName = null;

    if (ref != null) {
      try {
        await ref.onDisconnect().cancel();
      } catch (_) {}
      try {
        await ref.update({
          'Status': 'Offline',
          'Updated_At': ServerValue.timestamp,
        });
      } catch (_) {}
    }
  }

  Future<void> _writePosition(
    Position pos, {
    required int session,
    bool initial = false,
  }) async {
    // Reject stale events belonging to a previous session so we can't
    // overwrite an Offline state written by a newer [stop]/[start] cycle.
    if (session != _session) return;

    final ref = _liveRef;
    final email = _currentEmail;
    final name = _currentName;
    if (ref == null || email == null) return;

    final payload = <String, Object?>{
      'Lat': pos.latitude,
      'Lng': pos.longitude,
      'Accuracy': pos.accuracy,
      'Heading': pos.heading,
      'Speed': pos.speed,
      'Status': 'Online',
      'Updated_At': ServerValue.timestamp,
      'Driver_Email': email,
      if (name != null) 'Driver_Name': name,
    };
    if (initial) {
      payload['Started_At'] = ServerValue.timestamp;
    }

    try {
      await ref.update(payload);
    } catch (_) {
      // Swallow transient network errors; the stream will keep retrying.
    }
  }
}
