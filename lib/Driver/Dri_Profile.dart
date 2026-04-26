import 'package:bingo/Common/app_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class DriProfile extends StatefulWidget {
  final String driverEmail;
  final String driverName;

  const DriProfile({
    super.key,
    required this.driverEmail,
    required this.driverName,
  });

  @override
  State<DriProfile> createState() => _DriProfileState();
}

class _DriProfileState extends State<DriProfile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  String _driverId = '';
  String _driverNic = '';
  bool _isLoading = true;
  bool _isSaving = false;

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
    _loadProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final safeEmail = AppTheme.safeEmail(widget.driverEmail);
      final snap = await FirebaseDatabase.instance
          .ref()
          .child("Driver_Profiles/Driver_Profile/$safeEmail/Profile_Info")
          .get();

      if (snap.exists && snap.value != null) {
        final data = snap.value as Map<dynamic, dynamic>;
        _nameController.text = data['Driver_Name']?.toString() ?? widget.driverName;
        _mobileController.text = data['Driver_Mobile']?.toString() ?? '';
        _addressController.text = (data['Driver_Address']?.toString() ?? '').replaceAll('_', '/');
        _driverId = data['Driver_ID']?.toString() ?? '';
        _driverNic = data['Driver_NIC']?.toString() ?? '';
      } else {
        _nameController.text = widget.driverName;
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      _nameController.text = widget.driverName;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty) {
      _showSnack('Name and Mobile are required', AppTheme.errorRed);
      return;
    }

    setState(() => _isSaving = true);

    try {
      bool hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        _showSnack('No internet connection', Colors.grey);
        setState(() => _isSaving = false);
        return;
      }

      final safeEmail = AppTheme.safeEmail(widget.driverEmail);
      final profileRef = FirebaseDatabase.instance
          .ref()
          .child("Driver_Profiles/Driver_Profile/$safeEmail/Profile_Info");

      await profileRef.update({
        "Driver_Name": _nameController.text.trim(),
        "Driver_Mobile": _mobileController.text.trim(),
        "Driver_Address": _addressController.text.trim().replaceAll('/', '_'),
      });

      await FirebaseDatabase.instance
          .ref()
          .child("Persons/$safeEmail")
          .update({
        "Name": _nameController.text.trim(),
        "Mobile": _mobileController.text.trim(),
        "Address": _addressController.text.trim(),
      });

      _showSnack('Profile updated successfully', AppTheme.successGreen);
    } catch (e) {
      _showSnack('Failed to update profile', AppTheme.errorRed);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                color == AppTheme.successGreen
                    ? Icons.check_circle
                    : color == AppTheme.errorRed
                        ? Icons.error
                        : Icons.info,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
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
              child: _isLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(color: Colors.white54),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          const SizedBox(height: 24),
                          _buildAvatarSection(),
                          const SizedBox(height: 30),
                          _buildReadOnlySection(),
                          const SizedBox(height: 24),
                          _buildEditableSection(),
                          const SizedBox(height: 30),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.driverName.isNotEmpty
                    ? widget.driverName[0].toUpperCase()
                    : 'D',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.driverName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Driver',
              style: TextStyle(color: AppTheme.accentCyan, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlySection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassCard(opacity: 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Iconsax.shield_tick, color: AppTheme.accentCyan, size: 18),
              SizedBox(width: 8),
              Text(
                'Account Info',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem('Email', widget.driverEmail, Iconsax.sms),
          if (_driverId.isNotEmpty)
            _buildInfoItem('Driver ID', _driverId, Iconsax.card),
          if (_driverNic.isNotEmpty)
            _buildInfoItem('NIC', _driverNic, Iconsax.personalcard),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white30, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassCard(opacity: 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Iconsax.edit, color: AppTheme.accentCyan, size: 18),
              SizedBox(width: 8),
              Text(
                'Edit Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField('Full Name', _nameController, Iconsax.user),
          _buildField('Mobile', _mobileController, Iconsax.call,
              keyboardType: TextInputType.phone),
          _buildField('Address', _addressController, Iconsax.location,
              maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white30, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      hintText: 'Enter $label',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _saveProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
