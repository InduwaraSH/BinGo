import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class DriJobDetails extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const DriJobDetails({super.key, required this.requestData});

  @override
  State<DriJobDetails> createState() => _DriJobDetailsState();
}

class _DriJobDetailsState extends State<DriJobDetails> {
  bool _isUpdating = false;

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        backgroundColor: color.withOpacity(0.9),
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _markCollected() async {
    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance.collection('requests').doc(widget.requestData['id']).update({
        'status': 'collected',
        'statusChangedDateTime': FieldValue.serverTimestamp(),
      });
      _showSnack('Marked as collected!', Colors.green);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack('Failed to update job.', Colors.red);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _unassignJob() async {
    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance.collection('requests').doc(widget.requestData['id']).update({
        'status': 'pending',
        'assignedDriverId': null,
        'assignedDriverName': null,
        'assignedDriverMobile': null,
        'assignedAt': null,
      });
      _showSnack('Job handed back to admin.', Colors.orange);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack('Failed to update job.', Colors.red);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.requestData;
    final String status = req['status'] ?? 'pending';
    final bool isActive = status == 'assigned';

    String typeStr = req['garbageType'] ?? '';
    String typeDisplay = 'Unknown';
    IconData typeIcon = Iconsax.box;
    Color typeColor = Colors.white54;
    if (typeStr == 'biodegradable') {
      typeDisplay = 'දිරණ (Biodegradable)';
      typeIcon = Icons.eco_outlined;
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

    DateTime? requestedDate;
    if (req['requestedDateTime'] is Timestamp) {
      requestedDate = (req['requestedDateTime'] as Timestamp).toDate();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Job Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                  child: Icon(typeIcon, color: typeColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(typeDisplay, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        requestedDate != null ? DateFormat('MMM dd, yyyy • hh:mm a').format(requestedDate) : '',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _infoCard(
              icon: Iconsax.user,
              title: 'House Owner',
              lines: [req['userName'] ?? 'Unknown', if (req['userAddress'] != null) req['userAddress']],
              trailing: (req['userMobile'] as String?)?.isNotEmpty == true
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.call, color: Color(0xFF00B4FF), size: 16),
                        const SizedBox(width: 6),
                        Text(req['userMobile'], style: const TextStyle(color: Color(0xFF00B4FF), fontWeight: FontWeight.w600)),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            if (req['weightInKg'] != null)
              _infoCard(icon: Iconsax.weight, title: 'Estimated Weight', lines: ['${req['weightInKg']} kg']),
            const SizedBox(height: 32),
            if (isActive) ...[
              GestureDetector(
                onTap: _isUpdating ? null : _markCollected,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isUpdating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Mark as Collected', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isUpdating ? null : _unassignJob,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: const Center(
                    child: Text("Can't Do This Job — Hand Back", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(status == 'collected' ? Iconsax.tick_circle : Iconsax.clock, size: 36, color: Colors.white24),
                      const SizedBox(height: 12),
                      Text('This job is $status.', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required List<String> lines, Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                for (final line in lines)
                  Text(line, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
