import 'package:bingo/H_Owner/job_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class pgthree extends StatefulWidget {
  const pgthree({super.key});

  @override
  State<pgthree> createState() => _pgthreeState();
}

class _pgthreeState extends State<pgthree> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRequests();
  }

  void _fetchRequests() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() => _isLoading = false);
      return;
    }

    FirebaseFirestore.instance
        .collection('requests')
        .where('userEmail', isEqualTo: user.email)
        .snapshots()
        .listen(
          (snapshot) {
            if (mounted) {
              setState(() {
                var docs = snapshot.docs.map((doc) {
                  return {'id': doc.id, ...doc.data()};
                }).toList();

                docs.sort((a, b) {
                  Timestamp? tA = a['requestedDateTime'] as Timestamp?;
                  Timestamp? tB = b['requestedDateTime'] as Timestamp?;
                  if (tA == null && tB == null) return 0;
                  if (tA == null) return 1;
                  if (tB == null) return -1;
                  return tB.compareTo(tA);
                });

                _allRequests = docs;
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            print("Error fetching jobs: $error");
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Jobs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Canceled'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B4FF),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRequestList('pending'),
                        _buildRequestList('collected'),
                        _buildRequestList('rejected'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(String filterStatus) {
    var filteredList = _allRequests.where((req) {
      String status = req['status'] ?? 'pending';
      return status == filterStatus;
    }).toList();

    if (filteredList.isEmpty) {
      return _buildEmptyState(filterStatus);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ).copyWith(bottom: 100),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return _buildJobCard(filteredList[index], filterStatus);
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> request, String currentStatus) {
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

    // Determine which date to show
    DateTime? displayDate;
    String dateLabel = '';

    if (currentStatus == 'pending') {
      if (request['requestedDateTime'] != null) {
        displayDate = (request['requestedDateTime'] as Timestamp).toDate();
        dateLabel = 'Created on:';
      }
    } else {
      // For collected or rejected, show the status changed date if available
      if (request['statusChangedDateTime'] != null) {
        displayDate = (request['statusChangedDateTime'] as Timestamp).toDate();
      } else if (request['requestedDateTime'] != null) {
        displayDate = (request['requestedDateTime'] as Timestamp).toDate();
      }

      if (currentStatus == 'collected') {
        dateLabel = 'Completed on:';
      } else {
        dateLabel = 'Canceled on:';
      }
    }

    String formattedDate = displayDate != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(displayDate)
        : 'Unknown Date';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailsScreen(requestData: request),
          ),
        );
      },
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
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Iconsax.clock, size: 12, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            '$dateLabel $formattedDate',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${request['id'].substring(0, 8).toUpperCase()}${request['weightInKg'] != null ? ' • ${request['weightInKg']}kg' : ''}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (request['userAddress'] != null)
                  Expanded(
                    child: Text(
                      request['userAddress'],
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message = '';
    IconData icon = Iconsax.folder_open;

    if (status == 'pending') {
      message = 'No pending requests.';
      icon = Iconsax.timer;
    } else if (status == 'collected') {
      message = 'No completed jobs yet.';
      icon = Iconsax.tick_circle;
    } else if (status == 'rejected') {
      message = 'No canceled jobs.';
      icon = Iconsax.close_circle;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
