import 'package:flutter/material.dart';
import 'driver_live_map_view.dart';

class HOwnerTrackingMap extends StatelessWidget {
  final String assignedDriverId;
  final String driverName;

  const HOwnerTrackingMap({super.key, required this.assignedDriverId, required this.driverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tracking $driverName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: DriverLiveMapView(assignedDriverId: assignedDriverId, driverName: driverName),
    );
  }
}
