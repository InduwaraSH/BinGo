import 'package:bingo/Common/app_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

class DriRoute extends StatefulWidget {
  final String driverEmail;
  final String driverName;

  const DriRoute({
    super.key,
    required this.driverEmail,
    required this.driverName,
  });

  @override
  State<DriRoute> createState() => _DriRouteState();
}

class _DriRouteState extends State<DriRoute>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final MapController _mapController = MapController();

  List<_RouteData> _routes = [];
  int _selectedRouteIndex = 0;
  bool _isLoading = true;
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _loadRoutes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    try {
      final safeEmail = AppTheme.safeEmail(widget.driverEmail);
      final snap = await FirebaseDatabase.instance
          .ref()
          .child("Driver_Routes/$safeEmail")
          .get();

      List<_RouteData> routes = [];
      if (snap.exists && snap.value != null) {
        final data = snap.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final route = value as Map<dynamic, dynamic>;

          List<_LocationPin> pins = [];
          if (route['Locations'] != null) {
            final locs = route['Locations'] as Map<dynamic, dynamic>;
            locs.forEach((lKey, lVal) {
              final loc = lVal as Map<dynamic, dynamic>;
              final lat = double.tryParse(loc['Lat']?.toString() ?? '');
              final lng = double.tryParse(loc['Lng']?.toString() ?? '');
              if (lat != null && lng != null) {
                pins.add(_LocationPin(
                  position: LatLng(lat, lng),
                  label: loc['Label']?.toString() ?? 'Unknown',
                  address: loc['Address']?.toString() ?? '',
                ));
              }
            });
          }

          final centerLat = double.tryParse(route['Center_Lat']?.toString() ?? '');
          final centerLng = double.tryParse(route['Center_Lng']?.toString() ?? '');

          routes.add(_RouteData(
            id: key.toString(),
            area: route['Area']?.toString() ?? 'Unknown Area',
            ward: route['Ward']?.toString() ?? '',
            addressCount: route['Address_Count']?.toString() ?? '0',
            schedule: route['Schedule']?.toString() ?? 'Not Assigned',
            status: route['Status']?.toString() ?? 'Active',
            center: (centerLat != null && centerLng != null)
                ? LatLng(centerLat, centerLng)
                : const LatLng(6.0530, 80.5320),
            pins: pins,
          ));
        });
      }

      if (mounted) {
        setState(() {
          _routes = routes;
          _isLoading = false;
        });
        if (routes.isNotEmpty) {
          _animateToRoute(0);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _animateToRoute(int index) {
    if (index >= _routes.length) return;
    setState(() => _selectedRouteIndex = index);
    _mapController.move(_routes[index].center, 16.0);
  }

  List<Marker> get _currentMarkers {
    if (_routes.isEmpty) return [];
    final route = _routes[_selectedRouteIndex];
    return route.pins.map((pin) {
      return Marker(
        point: pin.position,
        width: 160,
        height: 50,
        child: GestureDetector(
          onTap: () => _showPinDetails(pin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  pin.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Icon(
                Icons.location_on,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showPinDetails(_LocationPin pin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Iconsax.home_2, color: AppTheme.primaryBlue, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pin.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pin.address,
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Iconsax.location, color: Colors.white30, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${pin.position.latitude.toStringAsFixed(4)}, ${pin.position.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _mapController.move(pin.position, 18.0);
                },
                child: const Text(
                  'Zoom to Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            if (_isLoading)
              Container(
                decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
                child: const Center(
                  child: CupertinoActivityIndicator(color: Colors.white54),
                ),
              )
            else if (_routes.isEmpty)
              Container(
                decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
                child: _buildEmptyState(),
              )
            else ...[
              // Full-screen map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _routes.isNotEmpty
                      ? _routes[_selectedRouteIndex].center
                      : const LatLng(6.0530, 80.5320),
                  initialZoom: 16.0,
                  maxZoom: 19.0,
                  minZoom: 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bingo.bingotrash',
                  ),
                  MarkerLayer(markers: _currentMarkers),
                ],
              ),

              // Top header overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.scaffoldDark.withOpacity(0.95),
                        AppTheme.scaffoldDark.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 12),
                          _buildRouteSelector(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom info card
              Positioned(
                left: 16,
                right: 16,
                bottom: 110,
                child: _buildBottomCard(),
              ),

              // List toggle button
              Positioned(
                right: 16,
                bottom: 210,
                child: GestureDetector(
                  onTap: () => setState(() => _showList = !_showList),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark.withOpacity(0.92),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _showList ? Iconsax.map : Iconsax.element_3,
                      color: AppTheme.accentCyan,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // Recenter button
              Positioned(
                right: 16,
                bottom: 260,
                child: GestureDetector(
                  onTap: () => _animateToRoute(_selectedRouteIndex),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark.withOpacity(0.92),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Iconsax.gps, color: Colors.white70, size: 22),
                  ),
                ),
              ),
            ],

            // Location list overlay
            if (_showList && _routes.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildLocationList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Iconsax.map, color: AppTheme.accentCyan, size: 24),
        const SizedBox(width: 10),
        const Text(
          'My Routes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.location, color: AppTheme.accentCyan, size: 14),
              const SizedBox(width: 4),
              Text(
                _routes.isNotEmpty
                    ? '${_routes[_selectedRouteIndex].pins.length} Pins'
                    : '0 Pins',
                style: const TextStyle(
                  color: AppTheme.accentCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_routes.length, (i) {
          final isSelected = i == _selectedRouteIndex;
          final route = _routes[i];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _animateToRoute(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.25)
                      : AppTheme.cardDark.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.6)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.route_square,
                      color: isSelected ? AppTheme.accentCyan : Colors.white38,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.area,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          route.schedule,
                          style: TextStyle(
                            color: isSelected ? Colors.white54 : Colors.white30,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomCard() {
    if (_routes.isEmpty) return const SizedBox.shrink();
    final route = _routes[_selectedRouteIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Iconsax.truck_fast, color: AppTheme.accentCyan, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.area,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${route.ward}  •  ${route.addressCount} houses  •  ${route.schedule}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              route.status,
              style: const TextStyle(
                color: AppTheme.successGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationList() {
    final route = _routes[_selectedRouteIndex];
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Icon(Iconsax.building_4, color: AppTheme.accentCyan, size: 20),
                const SizedBox(width: 10),
                Text(
                  '${route.area} — Locations',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showList = false),
                  child: const Icon(Icons.close, color: Colors.white38, size: 22),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              itemCount: route.pins.length,
              itemBuilder: (_, i) {
                final pin = route.pins[i];
                return GestureDetector(
                  onTap: () {
                    setState(() => _showList = false);
                    _mapController.move(pin.position, 18.0);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: AppTheme.accentCyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pin.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                pin.address,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Iconsax.arrow_right_3,
                          color: Colors.white24,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.map, color: Colors.white24, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Routes Assigned',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Routes will appear here once the\nadmin assigns them to you.',
            style: TextStyle(color: Colors.white38, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RouteData {
  final String id;
  final String area;
  final String ward;
  final String addressCount;
  final String schedule;
  final String status;
  final LatLng center;
  final List<_LocationPin> pins;

  _RouteData({
    required this.id,
    required this.area,
    required this.ward,
    required this.addressCount,
    required this.schedule,
    required this.status,
    required this.center,
    required this.pins,
  });
}

class _LocationPin {
  final LatLng position;
  final String label;
  final String address;

  _LocationPin({
    required this.position,
    required this.label,
    required this.address,
  });
}
