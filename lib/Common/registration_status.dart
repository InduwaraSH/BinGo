import 'package:cloud_firestore/cloud_firestore.dart';

/// Looks up `registration_requests/{type}_{safeEmail}` and reports where
/// this registration stands. Returns null when there's no request doc at
/// all (grandfathers accounts created before this approval flow existed)
/// or when it's explicitly approved. Otherwise returns 'pending' or 'rejected'.
Future<String?> checkApprovalStatus(String type, String email) async {
  final safeEmail = email.trim().toLowerCase().replaceAll('.', '_');
  final doc = await FirebaseFirestore.instance.collection('registration_requests').doc('${type}_$safeEmail').get();
  if (!doc.exists) return null;
  final status = doc.data()?['status'] as String?;
  if (status == 'approved') return null;
  return status ?? 'pending';
}
