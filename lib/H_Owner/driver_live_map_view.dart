import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

/// Live map body: the house owner's own position, the assigned driver's
/// live position (from `driver_locations/{assignedDriverId}`), and a
/// road-following route between them. Used both as a full-screen page
/// (pushed from a job card's "Track" button) and embedded in the
/// house owner's "Route" tab for whichever pickup is active today.
class DriverLiveMapView extends StatefulWidget {
  final String assignedDriverId;
  final String driverName;

  const DriverLiveMapView({super.key, required this.assignedDriverId, required this.driverName});

  @override
  State<DriverLiveMapView> createState() => _DriverLiveMapViewState();
}

class _DriverLiveMapViewState extends State<DriverLiveMapView> {
  static const LatLng _defaultCenter = LatLng(6.9271, 79.8612); // Colombo, Sri Lanka

  LatLng? _myPosition;
  StreamSubscription<Position>? _positionSub;
  final MapController _mapController = MapController();

  List<LatLng> _routePoints = [];
  Timer? _routeTimer;
  LatLng? _lastRouteDriverPoint;
  bool _fetchingRoute = false;

  @override
  void initState() {
    super.initState();
    _startWatchingMyPosition();
    _routeTimer = Timer.periodic(const Duration(seconds: 25), (_) => _maybeRefreshRoute());
  }

  @override
  void didUpdateWidget(covariant DriverLiveMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assignedDriverId != widget.assignedDriverId) {
      setState(() {
        _routePoints = [];
        _lastRouteDriverPoint = null;
      });
    }
  }

  Future<void> _startWatchingMyPosition() async {
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

  void _maybeRefreshRoute([LatLng? driverPoint]) {
    final myPos = _myPosition;
    final drvPos = driverPoint ?? _lastRouteDriverPoint;
    if (myPos == null || drvPos == null || _fetchingRoute) return;
    _fetchRoute(myPos, drvPos);
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    _fetchingRoute = true;
    _lastRouteDriverPoint = to;
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=geojson',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final coords = routes.first['geometry']['coordinates'] as List;
          final points = coords.map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
          if (mounted) setState(() => _routePoints = points);
        }
      }
    } catch (_) {
      // Route is a nice-to-have; silently keep showing markers without a line.
    } finally {
      _fetchingRoute = false;
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _routeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('driver_locations').doc(widget.assignedDriverId).snapshots(),
      builder: (context, snapshot) {
        LatLng? driverPosition;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final lat = (data['lat'] as num?)?.toDouble();
          final lng = (data['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            driverPosition = LatLng(lat, lng);
            if (_lastRouteDriverPoint == null ||
                Distance().as(LengthUnit.Meter, _lastRouteDriverPoint!, driverPosition) > 100) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRefreshRoute(driverPosition));
            }
          }
        }

        final markers = <Marker>[
          if (_myPosition != null)
            Marker(
              point: _myPosition!,
              width: 40,
              height: 40,
              child: const Icon(Icons.person_pin_circle_rounded, color: Colors.greenAccent, size: 36),
            ),
          if (driverPosition != null)
            Marker(
              point: driverPosition,
              width: 40,
              height: 40,
              child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF00B4FF), size: 34),
            ),
        ];

        final center = _myPosition ?? driverPosition ?? _defaultCenter;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: center, initialZoom: 13),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bingo.app',
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(polylines: [
                      Polyline(points: _routePoints, color: const Color(0xFF00B4FF), strokeWidth: 4),
                    ]),
                  MarkerLayer(markers: markers),
                ],
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07121A).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        driverPosition == null ? Iconsax.info_circle : Iconsax.location_tick,
                        color: driverPosition == null ? Colors.orangeAccent : Colors.greenAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          driverPosition == null
                              ? 'Waiting for ${widget.driverName} to start sharing location...'
                              : '${widget.driverName} is on the way',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
