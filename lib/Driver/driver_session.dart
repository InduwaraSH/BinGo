import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Resolves the logged-in BinGo driver (Firebase Auth email) to their
/// admin-registered `drivers` Firestore doc, so the rest of the driver
/// side can key everything (assigned jobs, live location doc) off one id.
class DriverSessionController extends GetxController {
  final RxBool isLoaded = false.obs;
  final RxnString driverId = RxnString();
  final RxString driverName = ''.obs;
  final RxString driverMobile = ''.obs;
  final RxString driverNic = ''.obs;
  final RxString driverEmail = ''.obs;
  final RxInt driverAge = 0.obs;
  final Rxn<DateTime> lastLicenseRenewed = Rxn<DateTime>();
  final Rxn<DateTime> workStartedDate = Rxn<DateTime>();

  bool get isLinked => driverId.value != null;

  @override
  void onInit() {
    super.onInit();
    loadDriverRecord();
  }

  Future<void> loadDriverRecord() async {
    isLoaded.value = false;
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      isLoaded.value = true;
      return;
    }
    try {
      final query = await FirebaseFirestore.instance
          .collection('drivers')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        driverId.value = doc.id;
        driverName.value = data['name'] ?? '';
        driverMobile.value = data['mobile'] ?? '';
        driverNic.value = data['nic'] ?? '';
        driverEmail.value = data['email'] ?? '';
        driverAge.value = (data['age'] as num?)?.toInt() ?? 0;
        lastLicenseRenewed.value =
            data['lastLicenseRenewed'] != null ? (data['lastLicenseRenewed'] as Timestamp).toDate() : null;
        workStartedDate.value =
            data['workStartedDate'] != null ? (data['workStartedDate'] as Timestamp).toDate() : null;
      }
    } catch (_) {
      // Leave driverId null; UI shows a "not linked to a driver profile" state.
    } finally {
      isLoaded.value = true;
    }
  }
}
