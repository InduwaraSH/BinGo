import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const JobDetailsScreen({super.key, required this.requestData});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  int _rating = 0;
  final TextEditingController _complaintController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.requestData['rating'] ?? 0;
    _complaintController.text = widget.requestData['complaint'] ?? '';
  }

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0 && _complaintController.text.trim().isEmpty) {
      _showSnack('Please provide a rating or a complaint.', Colors.orange);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestData['id'])
          .update({
        'rating': _rating,
        'complaint': _complaintController.text.trim(),
        'feedbackSubmittedAt': FieldValue.serverTimestamp(),
      });
      _showSnack('Feedback submitted successfully!', Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _showSnack('Failed to submit feedback.', Colors.red);
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        backgroundColor: color.withOpacity(0.9),
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.requestData;
    final String statusStr = req['status'] ?? 'pending';

    DateTime? createdDate;
    if (req['requestedDateTime'] != null) {
      createdDate = (req['requestedDateTime'] as Timestamp).toDate();
    }

    DateTime? changedDate;
    if (req['statusChangedDateTime'] != null) {
      changedDate = (req['statusChangedDateTime'] as Timestamp).toDate();
    }

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

    Color statusColor = Colors.orange;
    String statusDisplay = 'Pending';
    if (statusStr == 'collected') {
      statusColor = Colors.green;
      statusDisplay = 'Completed';
    } else if (statusStr == 'rejected') {
      statusColor = Colors.red;
      statusDisplay = 'Canceled';
    }

    final bool isEditable = statusStr == 'collected' || statusStr == 'rejected';

    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Header Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeDisplay,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${req['id'].substring(0, 8).toUpperCase()}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusDisplay,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Timeline Section
            const Text(
              'Request Timeline',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Timeline Steps
            _buildTimelineSteps(statusStr, createdDate, changedDate, req),

            const SizedBox(height: 32),

            // Weight chip if exists
            if (req['weightInKg'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.07)),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.weight, color: Colors.white54, size: 18),
                    const SizedBox(width: 10),
                    const Text('Estimated Weight', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const Spacer(),
                    Text(
                      '${req['weightInKg']} kg',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Feedback Section
            if (isEditable) ...[
              const Divider(color: Colors.white10),
              const SizedBox(height: 24),
              const Text(
                'Rate & Complain',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Rate this service or leave a complaint if you had any issues.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Star Rating
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final filled = _rating >= index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: AnimatedScale(
                          scale: filled ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            filled ? Iconsax.star1 : Iconsax.star,
                            color: filled ? Colors.amber : Colors.white24,
                            size: 38,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Complaint TextField
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: _complaintController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Write your complaint or feedback here...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: _isSubmitting ? null : _submitFeedback,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B4FF).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Submit Feedback',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: const [
                      Icon(Iconsax.clock, size: 36, color: Colors.white24),
                      SizedBox(height: 12),
                      Text(
                        'Feedback available once completed.',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSteps(
    String status,
    DateTime? createdDate,
    DateTime? changedDate,
    Map<String, dynamic> req,
  ) {
    // Define the steps
    final steps = [
      _TimelineStep(
        icon: Iconsax.document_text,
        title: 'Request Placed',
        subtitle: createdDate != null
            ? DateFormat('MMM dd, yyyy • hh:mm a').format(createdDate)
            : 'Unknown date',
        stepStatus: _StepStatus.done,
        color: const Color(0xFF00B4FF),
      ),
      _TimelineStep(
        icon: Iconsax.timer_1,
        title: 'Awaiting Pickup',
        subtitle: 'Your request is in the queue',
        stepStatus: status == 'pending' ? _StepStatus.active : _StepStatus.done,
        color: Colors.orangeAccent,
      ),
      if (status == 'collected')
        _TimelineStep(
          icon: Iconsax.tick_circle,
          title: 'Completed',
          subtitle: changedDate != null
              ? DateFormat('MMM dd, yyyy • hh:mm a').format(changedDate)
              : 'Date unavailable',
          stepStatus: _StepStatus.done,
          color: Colors.greenAccent,
        ),
      if (status == 'rejected')
        _TimelineStep(
          icon: Iconsax.close_circle,
          title: 'Canceled',
          subtitle: changedDate != null
              ? DateFormat('MMM dd, yyyy • hh:mm a').format(changedDate)
              : 'Date unavailable',
          stepStatus: _StepStatus.failed,
          color: Colors.redAccent,
        ),
      if (status == 'pending')
        _TimelineStep(
          icon: Iconsax.tick_circle,
          title: 'Completion',
          subtitle: 'Pending...',
          stepStatus: _StepStatus.pending,
          color: Colors.white24,
        ),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;
        return _buildTimelineItem(step, isLast);
      }),
    );
  }

  Widget _buildTimelineItem(_TimelineStep step, bool isLast) {
    Widget indicator;

    if (step.stepStatus == _StepStatus.done) {
      indicator = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: step.color.withOpacity(0.15),
          border: Border.all(color: step.color, width: 2),
        ),
        child: Icon(Icons.check_rounded, color: step.color, size: 18),
      );
    } else if (step.stepStatus == _StepStatus.failed) {
      indicator = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.redAccent.withOpacity(0.15),
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 18),
      );
    } else if (step.stepStatus == _StepStatus.active) {
      indicator = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00B4FF).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Icon(Icons.radio_button_on_rounded, color: Colors.white, size: 18),
      );
    } else {
      // pending
      indicator = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: Colors.white12, width: 2),
        ),
        child: const Icon(Icons.circle_outlined, color: Colors.white24, size: 18),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: vertical line + indicator
          SizedBox(
            width: 36,
            child: Column(
              children: [
                indicator,
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              step.stepStatus == _StepStatus.pending
                                  ? Colors.white12
                                  : step.color.withOpacity(0.4),
                              Colors.white12,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Right: Card content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: step.stepStatus == _StepStatus.pending
                      ? Colors.white.withOpacity(0.02)
                      : step.color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: step.stepStatus == _StepStatus.pending
                        ? Colors.white.withOpacity(0.04)
                        : step.color.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      step.icon,
                      color: step.stepStatus == _StepStatus.pending
                          ? Colors.white24
                          : step.color,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              color: step.stepStatus == _StepStatus.pending
                                  ? Colors.white38
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              decoration: step.stepStatus == _StepStatus.done &&
                                      step.title != 'Request Placed' &&
                                      step.title != 'Completed' &&
                                      step.title != 'Canceled'
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.subtitle,
                            style: TextStyle(
                              color: step.stepStatus == _StepStatus.pending
                                  ? Colors.white24
                                  : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepStatus { done, active, failed, pending }

class _TimelineStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final _StepStatus stepStatus;
  final Color color;

  _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stepStatus,
    required this.color,
  });
}
