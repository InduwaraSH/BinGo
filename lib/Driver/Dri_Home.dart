import 'package:bingo/Common/Logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'Dri_Job_Details.dart';
import 'Dri_Nav_Bar.dart';
import 'Dri_Profile.dart';
import 'driver_jobs_query.dart';
import 'driver_location_service.dart';
import 'driver_session.dart';

Future<void> driverSignOut(BuildContext context) async {
  await DriverLocationService.instance.stopTracking();
  await FirebaseAuth.instance.signOut();
  if (context.mounted) {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Logging()),
      (route) => false,
    );
  }
  // Dri_Nav_Bar recreates these fresh on the next login; drop the stale
  // instances now that nothing on screen is bound to them anymore.
  Get.delete<RMNavigControll>();
  Get.delete<DriverSessionController>();
}

class DriHome extends StatelessWidget {
  const DriHome({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<DriverSessionController>();

    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      body: SafeArea(
        child: Obx(() {
          if (!session.isLoaded.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)));
          }
          final driverId = session.driverId.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, session),
                const SizedBox(height: 24),
                _buildTrackingStatus(),
                const SizedBox(height: 24),
                if (driverId == null)
                  _buildNotLinkedCard()
                else
                  _buildTodayJobsSummary(driverId),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DriverSessionController session) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriProfile())),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)]),
              ),
              child: const Icon(Iconsax.truck, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome Back,', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text(
                  session.driverName.value.isNotEmpty ? session.driverName.value : 'Driver',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        ),
        IconButton(
          icon: const Icon(Iconsax.logout, color: Colors.white70),
          onPressed: () => driverSignOut(context),
        ),
      ],
    );
  }

  Widget _buildTrackingStatus() {
    return Obx(() {
      final tracking = DriverLocationService.instance.isTracking.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tracking ? Colors.greenAccent : Colors.white24,
                boxShadow: tracking ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.6), blurRadius: 8, spreadRadius: 2)] : [],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tracking ? 'Live — sharing your location for an active pickup' : 'Offline — no active pickup right now',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNotLinkedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Iconsax.warning_2, color: Colors.orangeAccent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your login isn\'t linked to a driver profile yet. Ask admin to add this email to the Driver Fleet.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayJobsSummary(String driverId) {
    return StreamBuilder<QuerySnapshot>(
      stream: DriverJobsQuery.assignedToDriver(driverId),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final all = docs.map((d) => {'id': d.id, ...(d.data() as Map<String, dynamic>)}).toList();
        final today = all.where((r) => r['status'] == 'assigned' && DriverJobsQuery.isToday(DriverJobsQuery.assignedAtOf(r))).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Jobs", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF00B4FF).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('${today.length}', style: const TextStyle(color: Color(0xFF00B4FF), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (today.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No pickups assigned to you today.', style: TextStyle(color: Colors.white38))),
              )
            else
              ...today.map((job) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriJobDetails(requestData: job))),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(14),
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
                                  Text(job['userName'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                  Text(job['userAddress'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white24),
                          ],
                        ),
                      ),
                    ),
                  )),
          ],
        );
      },
    );
  }
}
