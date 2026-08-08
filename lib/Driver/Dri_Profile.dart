import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'Dri_Home.dart';
import 'driver_session.dart';

class DriProfile extends StatelessWidget {
  const DriProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<DriverSessionController>();

    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (!session.isLoaded.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)));
        }
        if (!session.isLinked) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.warning_2, size: 48, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    "Your login isn't linked to a driver profile yet.\nAsk admin to add this email to the Driver Fleet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)]),
                      ),
                      child: Center(
                        child: Text(
                          session.driverName.value.isNotEmpty ? session.driverName.value[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(session.driverName.value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF00B4FF).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Driver', style: TextStyle(color: Color(0xFF00B4FF), fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _sectionLabel('Contact Details'),
              const SizedBox(height: 10),
              _infoTile(Iconsax.call, 'Mobile', session.driverMobile.value),
              _infoTile(Icons.mail_outline_rounded, 'Login Email', session.driverEmail.value),
              const SizedBox(height: 24),
              _sectionLabel('Driver Details'),
              const SizedBox(height: 10),
              _infoTile(Iconsax.personalcard, 'NIC', session.driverNic.value),
              _infoTile(Iconsax.cake, 'Age', session.driverAge.value > 0 ? '${session.driverAge.value} years' : '—'),
              _infoTile(
                Iconsax.calendar_1,
                'License Renewed',
                session.lastLicenseRenewed.value != null ? DateFormat('MMM dd, yyyy').format(session.lastLicenseRenewed.value!) : '—',
              ),
              _infoTile(
                Iconsax.briefcase,
                'Service Started',
                session.workStartedDate.value != null ? DateFormat('MMM dd, yyyy').format(session.workStartedDate.value!) : '—',
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => driverSignOut(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: const Center(
                    child: Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5));
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const Spacer(),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
