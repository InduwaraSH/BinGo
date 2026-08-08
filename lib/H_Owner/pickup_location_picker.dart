import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Full-screen "pick a point on the map" picker. The pin stays fixed in
/// the center of the screen while the map pans underneath it; confirming
/// pops the map's current center back to the caller.
class PickupLocationPicker extends StatefulWidget {
  final LatLng? initialCenter;

  const PickupLocationPicker({super.key, this.initialCenter});

  @override
  State<PickupLocationPicker> createState() => _PickupLocationPickerState();
}

class _PickupLocationPickerState extends State<PickupLocationPicker> {
  static const LatLng _defaultCenter = LatLng(6.9271, 79.8612); // Colombo, Sri Lanka

  final MapController _mapController = MapController();
  late LatLng _center;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _center = widget.initialCenter ?? _defaultCenter;
    if (widget.initialCenter == null) _useCurrentLocation();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _center = point);
      _mapController.move(point, 16);
    } catch (_) {
      // Keep whatever center we had; user can still pan manually.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

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
        title: const Text('Pick Pickup Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) _center = position.center;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bingo.app',
              ),
            ],
          ),
          const IgnorePointer(
            child: Padding(
              padding: EdgeInsets.only(bottom: 36),
              child: Icon(Icons.location_on_rounded, color: Color(0xFF00B4FF), size: 46),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 110,
            child: FloatingActionButton(
              heroTag: 'recenter',
              backgroundColor: const Color(0xFF0F1B25),
              onPressed: _locating ? null : _useCurrentLocation,
              child: _locating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.my_location_rounded, color: Colors.white),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _center),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00B4FF).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Center(
                  child: Text('Confirm This Location', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
