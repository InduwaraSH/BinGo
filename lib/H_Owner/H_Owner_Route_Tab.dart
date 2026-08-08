import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'driver_live_map_view.dart';

/// The house owner's "Route" tab: automatically shows the live map for
/// whichever of their requests currently has a driver assigned, instead
/// of requiring them to open a specific job card first.
class HOwnerRouteTab extends StatelessWidget {
  const HOwnerRouteTab({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return Container(
      color: const Color(0xFF07121A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text('Live Tracking', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: email == null
                  ? _buildEmptyState()
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('requests')
                          .where('userEmail', isEqualTo: email)
                          .where('status', isEqualTo: 'assigned')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)));
                        }
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return _buildEmptyState();
                        }

                        final requests = docs.map((d) => {'id': d.id, ...(d.data() as Map<String, dynamic>)}).toList();
                        requests.sort((a, b) {
                          final tA = a['assignedAt'];
                          final tB = b['assignedAt'];
                          if (tA is! Timestamp || tB is! Timestamp) return 0;
                          return tB.compareTo(tA);
                        });
                        final active = requests.first;
                        final driverId = active['assignedDriverId'] as String?;
                        final driverName = active['assignedDriverName'] as String? ?? 'Driver';

                        if (driverId == null) {
                          return _buildEmptyState();
                        }

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          child: DriverLiveMapView(assignedDriverId: driverId, driverName: driverName),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Iconsax.routing, size: 48, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'No driver is assigned to a pickup right now.\nOnce admin assigns one, you\'ll see them live here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
