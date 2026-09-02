import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'Dri_Job_Details.dart';
import 'driver_jobs_query.dart';
import 'driver_session.dart';

class DriJobs extends StatefulWidget {
  const DriJobs({super.key});

  @override
  State<DriJobs> createState() => _DriJobsState();
}

class _DriJobsState extends State<DriJobs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          if (driverId == null) {
            return _buildNotLinked();
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('My Jobs', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [Tab(text: "Today's Jobs"), Tab(text: 'Completed')],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: DriverJobsQuery.assignedToDriver(driverId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    final all = docs.map((d) => {'id': d.id, ...(d.data() as Map<String, dynamic>)}).toList();

                    // Today's jobs require both the assigned status and a
                    // local-calendar assignedAt date; completed jobs are kept
                    // by status and are not limited to today's date.
                    final today = all.where((r) {
                      return r['status'] == 'assigned' && DriverJobsQuery.isToday(DriverJobsQuery.assignedAtOf(r));
                    }).toList();
                    final completed = all.where((r) => r['status'] == 'collected').toList();

                    today.sort((a, b) => _compareByAssignedAt(a, b));
                    completed.sort((a, b) => _compareByAssignedAt(a, b));

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildJobList(today, emptyMessage: 'No pickups assigned to you today.'),
                        _buildJobList(completed, emptyMessage: 'No completed jobs yet.'),
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

  int _compareByAssignedAt(Map<String, dynamic> a, Map<String, dynamic> b) {
    // Newer assignments appear first, while records without a timestamp stay
    // at the end instead of causing a failed comparison.
    final tA = DriverJobsQuery.assignedAtOf(a);
    final tB = DriverJobsQuery.assignedAtOf(b);
    if (tA == null && tB == null) return 0;
    if (tA == null) return 1;
    if (tB == null) return -1;
    return tB.compareTo(tA);
  }

  Widget _buildNotLinked() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Iconsax.warning_2, size: 48, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'Your login isn\'t linked to a driver profile yet.\nAsk admin to add this email to the Driver Fleet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(List<Map<String, dynamic>> jobs, {required String emptyMessage}) {
    if (jobs.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Colors.white38, fontSize: 14)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).copyWith(bottom: 100),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _buildJobCard(jobs[index]),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> request) {
    String typeStr = request['garbageType'] ?? '';
    String typeDisplay = 'Unknown';
    IconData typeIcon = Iconsax.box;
    Color typeColor = Colors.white54;
    if (typeStr == 'biodegradable') {
      typeDisplay = 'දිරණ (Biodegradable)';
      typeIcon = Icons.eco;
      typeColor = Colors.greenAccent;
    } else if (typeStr == 'nonBiodegradable') {
      typeDisplay = 'නොදිරණ (Non-biodegradable)';
      typeIcon = Iconsax.trash;
      typeColor = Colors.orangeAccent;
    } else if (typeStr == 'glass') {
      typeDisplay = 'වීදුරු (Glass)';
      typeIcon = Iconsax.glass;
      typeColor = Colors.lightBlueAccent;
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriJobDetails(requestData: request))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request['userName'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(typeDisplay, style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white24),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Iconsax.location, size: 14, color: Colors.white54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request['userAddress'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
