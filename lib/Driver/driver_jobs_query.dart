import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared helpers for querying a driver's assigned pickups from `requests`.
class DriverJobsQuery {
  static Stream<QuerySnapshot> assignedToDriver(String driverId) {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('assignedDriverId', isEqualTo: driverId)
        .snapshots();
  }

  static bool isToday(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  static DateTime? assignedAtOf(Map<String, dynamic> data) {
    final v = data['assignedAt'];
    return v is Timestamp ? v.toDate() : null;
  }
}
