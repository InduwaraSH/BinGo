import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import '../Common/map_pin.dart';
import 'driver_jobs_query.dart';
import 'driver_session.dart';

class DriRouteMap extends StatefulWidget {
  const DriRouteMap({super.key});

  @override
  State<DriRouteMap> createState() => _DriRouteMapState();
}

class _DriRouteMapState extends State<DriRouteMap> {
  static const LatLng _defaultCenter = LatLng(6.9271, 79.8612); // Colombo, Sri Lanka

  LatLng? _myPosition;
  StreamSubscription<Position>? _positionSub;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _startWatchingMyPosition();
  }

  Future<void> _startWatchingMyPosition() async {
    // This subscription updates the open map only; background driver tracking
    // is managed separately by DriverTrackingGate.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((pos) {
      if (!mounted) return;
      setState(() => _myPosition = LatLng(pos.latitude, pos.longitude));
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = Get.find<DriverSessionController>();

    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      body: SafeArea(
        child: Obx(() {
          final driverId = session.driverId.value;
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Route', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: driverId == null
                    ? const Center(child: Text('Not linked to a driver profile.', style: TextStyle(color: Colors.white38)))
                    : StreamBuilder<QuerySnapshot>(
                        stream: DriverJobsQuery.assignedToDriver(driverId),
                        builder: (context, snapshot) {
                          final docs = snapshot.data?.docs ?? [];
                          final activeJobs = docs
                              .map((d) => {'id': d.id, ...(d.data() as Map<String, dynamic>)})
                              .where((r) => r['status'] == 'assigned' && DriverJobsQuery.isToday(DriverJobsQuery.assignedAtOf(r)))
                              .toList();

                              // Coordinates can be rendered as map markers; jobs
                              // without both values remain visible in the list.
                          final jobsWithCoords = activeJobs.where((j) => j['pickupLat'] != null && j['pickupLng'] != null).toList();
                          final jobsWithoutCoords = activeJobs.where((j) => j['pickupLat'] == null || j['pickupLng'] == null).toList();

                          return Column(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: FlutterMap(
                                      mapController: _mapController,
                                      options: MapOptions(initialCenter: _myPosition ?? _defaultCenter, initialZoom: 14),
                                      children: [
                                        TileLayer(
                                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName: 'com.bingo.driver',
                                        ),
                                        MarkerLayer(markers: [
                                          if (_myPosition != null)
                                            Marker(
                                              point: _myPosition!,
                                              width: 54,
                                              height: 62,
                                              alignment: Alignment.bottomCenter,
                                              child: const MapPin(icon: Icons.local_shipping_rounded, color: Color(0xFF00B4FF)),
                                            ),
                                          for (final job in jobsWithCoords)
                                            Marker(
                                              point: LatLng((job['pickupLat'] as num).toDouble(), (job['pickupLng'] as num).toDouble()),
                                              width: 150,
                                              height: 100,
                                              alignment: Alignment.bottomCenter,
                                              child: MapPin(
                                                icon: Icons.delete_rounded,
                                                color: const Color(0xFFFF9F43),
                                                label: job['userName'] ?? 'Pickup',
                                              ),
                                            ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Today's Active Pickups", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                flex: 2,
                                child: activeJobs.isEmpty
                                    ? const Center(child: Text('No active pickups right now.', style: TextStyle(color: Colors.white38)))
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 100),
                                        itemCount: jobsWithoutCoords.length,
                                        itemBuilder: (context, index) {
                                          final job = jobsWithoutCoords[index];
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.03),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Iconsax.location, color: Color(0xFF00B4FF), size: 18),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(job['userName'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                                      Text(job['userAddress'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

