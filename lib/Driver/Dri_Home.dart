import 'package:bingo/Common/Logging.dart';
import 'package:bingo/Common/app_theme.dart';
import 'package:bingo/Driver/Dri_Location_Service.dart';
import 'package:bingo/Driver/Dri_Nav_Bar.dart';
import 'package:bingo/Driver/Dri_Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DriHome extends StatefulWidget {
  final String driverName;
  final String driverEmail;

  const DriHome({
    super.key,
    required this.driverName,
    required this.driverEmail,
  });

  @override
  State<DriHome> createState() => _DriHomeState();
}

class _DriHomeState extends State<DriHome> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  int _pendingJobs = 0;
  int _inProgressJobs = 0;
  int _completedJobs = 0;
  String _driverAddress = '';
  String _driverMobile = '';
  bool _isLoading = true;
  bool _isOnDuty = false;
  bool _dutyBusy = false;

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
    _isOnDuty = DriverLocationService.instance.isPublishing;
    _loadDashboardData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleDuty() async {
    if (_dutyBusy) return;
    setState(() => _dutyBusy = true);
    try {
      if (_isOnDuty) {
        await DriverLocationService.instance.stop();
        if (mounted) setState(() => _isOnDuty = false);
      } else {
        await DriverLocationService.instance.start(
          driverEmail: widget.driverEmail,
          driverName: widget.driverName,
        );
        if (mounted) setState(() => _isOnDuty = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.errorRed,
            content: Text(
              e is StateError ? e.message : 'Failed to update duty status.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _dutyBusy = false);
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final safeEmail = AppTheme.safeEmail(widget.driverEmail);

      final profileSnap = await FirebaseDatabase.instance
          .ref()
          .child("Driver_Profiles/Driver_Profile/$safeEmail/Profile_Info")
          .get();

      if (profileSnap.exists) {
        final data = profileSnap.value as Map<dynamic, dynamic>;
        _driverAddress = data['Driver_Address']?.toString() ?? '';
        _driverMobile = data['Driver_Mobile']?.toString() ?? '';
      }

      final jobsSnap = await FirebaseDatabase.instance
          .ref()
          .child("Driver_Jobs/$safeEmail")
          .get();

      int pending = 0, inProgress = 0, completed = 0;
      if (jobsSnap.exists && jobsSnap.value != null) {
        final jobs = jobsSnap.value as Map<dynamic, dynamic>;
        for (final entry in jobs.entries) {
          final job = entry.value as Map<dynamic, dynamic>;
          final status = job['Status']?.toString() ?? '';
          if (status == 'Pending') pending++;
          else if (status == 'In_Progress') inProgress++;
          else if (status == 'Completed') completed++;
        }
      }

      if (mounted) {
        setState(() {
          _pendingJobs = pending;
          _inProgressJobs = inProgress;
          _completedJobs = completed;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Logout'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DriverLocationService.instance.stop();
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Logging()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient)),
            SafeArea(
              child: RefreshIndicator(
                color: AppTheme.primaryBlue,
                backgroundColor: AppTheme.cardDark,
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),
                      _buildStatsSection(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildProfileCard(),
                    ],
                  ),
                ),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: const [
              Icon(Iconsax.truck, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'BinGo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DriProfile(
                driverEmail: widget.driverEmail,
                driverName: widget.driverName,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.user, color: Colors.white70, size: 22),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _logout,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.logout, color: Colors.redAccent, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            widget.driverName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _toggleDuty,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _isOnDuty
                    ? AppTheme.successGreen.withOpacity(0.22)
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isOnDuty
                      ? AppTheme.successGreen.withOpacity(0.6)
                      : Colors.white.withOpacity(0.18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_dutyBusy)
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 6,
                      ),
                    )
                  else
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isOnDuty
                            ? AppTheme.successGreen
                            : Colors.white70,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _isOnDuty ? 'On Duty — Sharing Location' : 'Off Duty — Tap to Go Live',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CupertinoActivityIndicator(color: Colors.white54),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  _pendingJobs.toString(),
                  Iconsax.clock,
                  AppTheme.warningOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'In Progress',
                  _inProgressJobs.toString(),
                  Iconsax.truck_fast,
                  AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Done',
                  _completedJobs.toString(),
                  Iconsax.tick_circle,
                  AppTheme.successGreen,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(opacity: 0.05),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _switchTab(int index) {
    try {
      final controller = Get.find<DriNavigController>();
      controller.selectedIndex.value = index;
    } catch (_) {}
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                'View Jobs',
                Iconsax.task_square,
                AppTheme.primaryBlue,
                () => _switchTab(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                'My Route',
                Iconsax.map,
                AppTheme.accentCyan,
                () => _switchTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionTile(
                'My Profile',
                Iconsax.user,
                AppTheme.warningOrange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriProfile(
                      driverEmail: widget.driverEmail,
                      driverName: widget.driverName,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: AppTheme.glassCard(opacity: 0.04),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassCard(opacity: 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Iconsax.profile_circle, color: AppTheme.accentCyan, size: 20),
              SizedBox(width: 10),
              Text(
                'My Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Iconsax.sms, widget.driverEmail),
          if (_driverMobile.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(Iconsax.call, _driverMobile),
          ],
          if (_driverAddress.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(Iconsax.location, _driverAddress.replaceAll('_', '/')),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
