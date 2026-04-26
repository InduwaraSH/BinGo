import 'package:flutter/material.dart';
import 'models/job_model.dart';

class HOwnerJobs extends StatefulWidget {
  const HOwnerJobs({super.key});

  @override
  State<HOwnerJobs> createState() => _HOwnerJobsState();
}

class _HOwnerJobsState extends State<HOwnerJobs>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2C6BFF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Jobs',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5)),
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ===== PROFILE BANNER WITH ANIMATION =====
              SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(-0.3, 0), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.0, 0.4, curve: Curves.easeOut))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2C6BFF).withOpacity(0.1),
                          const Color(0xFF5A7FFF).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFF2C6BFF).withOpacity(0.3),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C6BFF).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.1, 0.5,
                                    curve: Curves.elasticOut))),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2C6BFF),
                                  Color(0xFF5A7FFF)
                                ],
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  AssetImage('assets/avatar.png'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFF2C6BFF)
                                      .withOpacity(0.2),
                                  width: 1),
                            ),
                            alignment: Alignment.centerLeft,
                            child: const Text('House Owner',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ===== JOBS LIST WITH ANIMATIONS =====
              jobsList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60.0),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.4, 0.8)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inbox,
                                size: 64,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('No jobs available',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: jobsList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final job = jobsList[idx];
                        final dateLabel =
                            '${job.dateCreated.day}/${job.dateCreated.month}/${job.dateCreated.year}';
                        final timeLabel =
                            '${job.dateCreated.hour.toString().padLeft(2, '0')}:${job.dateCreated.minute.toString().padLeft(2, '0')}';
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1.0)
                              .animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                      0.2 + (idx * 0.1),
                                      0.6 + (idx * 0.1),
                                      curve: Curves.easeOut))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFF2C6BFF)
                                        .withOpacity(0.2),
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    // Date and Actions Row
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 12,
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF2C6BFF),
                                                Color(0xFF5A7FFF)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(dateLabel,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12)),
                                              const SizedBox(height: 4),
                                              Text(timeLabel,
                                                  style: const TextStyle(
                                                      color:
                                                          Colors.white70,
                                                      fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(
                                                  context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      const Text(
                                                          'Job accepted'),
                                                  backgroundColor:
                                                      Colors.green
                                                          .shade600,
                                                  behavior:
                                                      SnackBarBehavior
                                                          .floating,
                                                  margin:
                                                      const EdgeInsets
                                                          .all(16),
                                                ),
                                              );
                                            },
                                            icon: Icon(
                                                Icons.check_circle,
                                                color: Colors.green.shade600),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(
                                                  context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      const Text(
                                                          'Job rejected'),
                                                  backgroundColor:
                                                      Colors.red.shade600,
                                                  behavior:
                                                      SnackBarBehavior
                                                          .floating,
                                                  margin:
                                                      const EdgeInsets
                                                          .all(16),
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.cancel,
                                                color:
                                                    Colors.red.shade600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Job Details Grid
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildDetailRow(
                                                  'Full Name',
                                                  Colors.grey.shade600),
                                              const SizedBox(
                                                  height: 10),
                                              _buildDetailRow(
                                                  'Address',
                                                  Colors.grey.shade600),
                                              const SizedBox(
                                                  height: 10),
                                              _buildDetailRow(
                                                  'Contact No.',
                                                  Colors.grey.shade600),
                                              const SizedBox(
                                                  height: 10),
                                              _buildDetailRow(
                                                  'Type',
                                                  Colors.grey.shade600),
                                              const SizedBox(
                                                  height: 10),
                                              _buildDetailRow(
                                                  'Weight (Kg)',
                                                  Colors.grey.shade600),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              _buildDetailRow(
                                                  job.fullName,
                                                  Colors.black87,
                                                  isBold: true),
                                              const SizedBox(
                                                  height: 10),
                                              _buildDetailRow(
                                                  job.address,
                                                  Colors.black87,
                                                  isBold: true),
                                              const SizedBox(
                                                  height: 10),
                                              _buildDetailRow(
                                                  job.contact,
                                                  Colors.black87,
                                                  isBold: true),
                                              const SizedBox(
                                                  height: 10),
                                              _buildDetailRow(
                                                  job.type,
                                                  Colors.black87,
                                                  isBold: true),
                                              const SizedBox(
                                                  height: 10),
                                              _buildDetailRow(
                                                  job.weight,
                                                  Colors.black87,
                                                  isBold: true),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String text, Color color,
      {bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
      ),
    );
  }
}
