import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared helpers for querying a driver's assigned pickups from `requests`.
class DriverJobsQuery {
  /// Streams every request assigned to this driver; status and date filtering
  /// stays with each screen because the same stream feeds different views.
  static Stream<QuerySnapshot> assignedToDriver(String driverId) {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('assignedDriverId', isEqualTo: driverId)
        .snapshots();
  }

  /// Compares calendar fields using the device's local `DateTime.now()` value.
  static bool isToday(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// Reads Firestore's timestamp shape and returns null for missing/other data.
  static DateTime? assignedAtOf(Map<String, dynamic> data) {
    final v = data['assignedAt'];
    return v is Timestamp ? v.toDate() : null;
  }
}
