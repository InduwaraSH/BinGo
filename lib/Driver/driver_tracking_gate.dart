import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'driver_jobs_query.dart';
import 'driver_location_service.dart';
import 'driver_session.dart';

/// Mounted once above the driver's tab views. Watches whether the driver
/// has any pickup assigned for today and starts/stops the background
/// location writer accordingly, independent of which tab is showing.
class DriverTrackingGate extends StatefulWidget {
  final DriverSessionController session;
  final Widget child;

  const DriverTrackingGate({super.key, required this.session, required this.child});

  @override
  State<DriverTrackingGate> createState() => _DriverTrackingGateState();
}

class _DriverTrackingGateState extends State<DriverTrackingGate> {
  StreamSubscription<QuerySnapshot>? _jobsSub;
  String? _watchingDriverId;

  @override
  void initState() {
    super.initState();
    widget.session.driverId.listen(_onDriverIdChanged);
    if (widget.session.driverId.value != null) {
      _onDriverIdChanged(widget.session.driverId.value);
    }
  }

  void _onDriverIdChanged(String? driverId) {
    _jobsSub?.cancel();
    _jobsSub = null;
    _watchingDriverId = driverId;

    if (driverId == null) {
      DriverLocationService.instance.stopTracking();
      return;
    }

    _jobsSub = DriverJobsQuery.assignedToDriver(driverId).listen((snapshot) {
      if (_watchingDriverId != driverId) return;

      final activeJobs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'assigned' && DriverJobsQuery.isToday(DriverJobsQuery.assignedAtOf(data));
      }).toList();

      if (activeJobs.isNotEmpty) {
        DriverLocationService.instance.startTracking(driverId, activeRequestId: activeJobs.first.id);
      } else {
        DriverLocationService.instance.stopTracking();
      }
    });
  }

  @override
  void dispose() {
    _jobsSub?.cancel();
    DriverLocationService.instance.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
