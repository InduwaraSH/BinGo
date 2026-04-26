import 'package:bingo/Common/app_theme.dart';
import 'package:bingo/Models/job_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DriJobs extends StatefulWidget {
  final String driverEmail;
  final String driverName;

  const DriJobs({
    super.key,
    required this.driverEmail,
    required this.driverName,
  });

  @override
  State<DriJobs> createState() => _DriJobsState();
}

class _DriJobsState extends State<DriJobs>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<GarbageJob> _jobs = [];
  bool _isLoading = true;
  String _filter = 'All';

  late DatabaseReference _jobsRef;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    final safeEmail = AppTheme.safeEmail(widget.driverEmail);
    _jobsRef = FirebaseDatabase.instance.ref().child("Driver_Jobs/$safeEmail");
    _listenToJobs();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _listenToJobs() {
    _jobsRef.onValue.listen((event) {
      List<GarbageJob> jobs = [];
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          jobs.add(GarbageJob.fromMap(key.toString(), value as Map<dynamic, dynamic>));
        });
        jobs.sort((a, b) {
          const order = {'Pending': 0, 'In_Progress': 1, 'Completed': 2};
          return (order[a.status] ?? 3).compareTo(order[b.status] ?? 3);
        });
      }
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    }, onError: (_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<GarbageJob> get _filteredJobs {
    if (_filter == 'All') return _jobs;
    return _jobs.where((j) => j.status == _filter).toList();
  }

  Future<void> _updateJobStatus(GarbageJob job, String newStatus) async {
    try {
      Map<String, dynamic> updates = {'Status': newStatus};
      if (newStatus == 'Completed') {
        updates['Completed_Date'] = DateTime.now().toIso8601String();
      }
      await _jobsRef.child(job.id).update(updates);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _jobs.where((j) => j.isPending).length;
    final inProgress = _jobs.where((j) => j.isInProgress).length;
    final completed = _jobs.where((j) => j.isCompleted).length;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
            ),
            SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    sliver: SliverToBoxAdapter(child: _buildHeader()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildStatsRow(pending, inProgress, completed),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    sliver: SliverToBoxAdapter(child: _buildFilterChips()),
                  ),
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CupertinoActivityIndicator(color: Colors.white54),
                      ),
                    )
                  else if (_filteredJobs.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildJobCard(_filteredJobs[index]),
                          ),
                          childCount: _filteredJobs.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Iconsax.task_square, color: AppTheme.accentCyan, size: 24),
        const SizedBox(width: 10),
        const Text(
          'Collection Jobs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_jobs.length} Total',
            style: const TextStyle(
              color: AppTheme.accentCyan,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int pending, int inProgress, int completed) {
    return Row(
      children: [
        Expanded(child: _buildMiniStat('Pending', pending, AppTheme.warningOrange)),
        const SizedBox(width: 10),
        Expanded(child: _buildMiniStat('Active', inProgress, AppTheme.primaryBlue)),
        const SizedBox(width: 10),
        Expanded(child: _buildMiniStat('Done', completed, AppTheme.successGreen)),
      ],
    );
  }

  Widget _buildMiniStat(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: AppTheme.glassCard(opacity: 0.04),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'In_Progress', 'Completed'];
    final labels = ['All', 'Pending', 'In Progress', 'Completed'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = _filter == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = filters[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.2)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.5)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: isSelected ? AppTheme.accentCyan : Colors.white54,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.task_square, color: Colors.white24, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            _filter == 'All' ? 'No Jobs Yet' : 'No $_filter Jobs',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jobs will appear here once assigned\nby the admin.',
            style: TextStyle(color: Colors.white38, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(GarbageJob job) {
    Color statusColor;
    IconData statusIcon;
    switch (job.status) {
      case 'In_Progress':
        statusColor = AppTheme.primaryBlue;
        statusIcon = Iconsax.truck_fast;
        break;
      case 'Completed':
        statusColor = AppTheme.successGreen;
        statusIcon = Iconsax.tick_circle;
        break;
      default:
        statusColor = AppTheme.warningOrange;
        statusIcon = Iconsax.clock;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(opacity: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.ownerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'House ID: ${job.houseId}',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.status.replaceAll('_', ' '),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Iconsax.location, color: Colors.white30, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job.address.replaceAll('_', '/'),
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.call, color: Colors.white30, size: 14),
              const SizedBox(width: 6),
              Text(
                job.mobile,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const Spacer(),
              const Icon(Iconsax.calendar_1, color: Colors.white30, size: 14),
              const SizedBox(width: 6),
              Text(
                _formatDate(job.assignedDate),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (job.isPending)
                Expanded(
                  child: _buildActionButton(
                    'Start Collection',
                    AppTheme.primaryBlue,
                    () => _updateJobStatus(job, 'In_Progress'),
                  ),
                ),
              if (job.isInProgress)
                Expanded(
                  child: _buildActionButton(
                    'Mark Complete',
                    AppTheme.successGreen,
                    () => _confirmComplete(job),
                  ),
                ),
              if (job.isPending || job.isInProgress)
                const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  'Report Issue',
                  AppTheme.errorRed,
                  () => _showReportDialog(job),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmComplete(GarbageJob job) async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Complete Job'),
        content: Text('Mark collection for ${job.ownerName} as completed?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Complete'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _updateJobStatus(job, 'Completed');
    }
  }

  void _showReportDialog(GarbageJob job) {
    final descController = TextEditingController();
    String selectedType = 'Missed Collection';
    final types = [
      'Missed Collection',
      'Road Blocked',
      'Bin Not Accessible',
      'Wrong Address',
      'Vehicle Issue',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Icon(Iconsax.warning_2, color: AppTheme.errorRed, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Report an Issue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Job: ${job.ownerName} — ${job.houseId}',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Issue Type',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: types.map((type) {
                      final isSelected = type == selectedType;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedType = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.errorRed.withOpacity(0.2)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.errorRed.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.errorRed
                                  : Colors.white54,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Description (optional)',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: TextField(
                      controller: descController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Describe the issue...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _submitComplaint(
                          job,
                          selectedType,
                          descController.text.trim(),
                        );
                      },
                      child: const Text(
                        'Submit Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitComplaint(
    GarbageJob job,
    String issueType,
    String description,
  ) async {
    try {
      final safeEmail = AppTheme.safeEmail(widget.driverEmail);
      final complaintRef =
          FirebaseDatabase.instance.ref().child("Complaints").push();

      await complaintRef.set({
        'Job_ID': job.id,
        'House_ID': job.houseId,
        'Owner_Name': job.ownerName,
        'Address': job.address,
        'Issue_Type': issueType,
        'Description': description,
        'Reported_By': widget.driverName,
        'Reporter_Email': widget.driverEmail,
        'Reporter_Type': 'Driver',
        'Status': 'Open',
        'Created_At': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Issue reported successfully',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit report'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
