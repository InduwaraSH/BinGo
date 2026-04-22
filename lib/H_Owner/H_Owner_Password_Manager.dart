import 'package:flutter/material.dart';

class HOwnerPasswordManager extends StatefulWidget {
  const HOwnerPasswordManager({super.key});

  @override
  State<HOwnerPasswordManager> createState() => _HOwnerPasswordManagerState();
}

class _HOwnerPasswordManagerState extends State<HOwnerPasswordManager>
    with SingleTickerProviderStateMixin {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Password Manager',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Security Info Card
              SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(-0.3, 0), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.0, 0.4,
                            curve: Curves.easeOut))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lock_outline,
                            color: Colors.blue.shade700, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Secure Your Account',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use a strong, unique password',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Current Password
              _buildPasswordField(
                label: 'Current Password',
                controller: _currentPasswordController,
                isObscured: !_showCurrentPassword,
                onVisibilityChanged: (value) {
                  setState(() => _showCurrentPassword = value);
                },
                suffixText: 'Forgot?',
                onSuffixTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Password reset link sent to your email'),
                      backgroundColor: Colors.blue.shade600,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                delay: 0.15,
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                label: 'New Password',
                controller: _newPasswordController,
                isObscured: !_showNewPassword,
                onVisibilityChanged: (value) {
                  setState(() => _showNewPassword = value);
                },
                hintText: 'Min. 8 characters, mix of letters & numbers',
                delay: 0.25,
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                isObscured: !_showConfirmPassword,
                onVisibilityChanged: (value) {
                  setState(() => _showConfirmPassword = value);
                },
                delay: 0.35,
              ),
              const SizedBox(height: 32),
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C6BFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _handlePasswordChange(context);
                  },
                  label: const Text(
                    'Update Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF2C6BFF), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF2C6BFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscured,
    required Function(bool) onVisibilityChanged,
    String? suffixText,
    String? hintText,
    VoidCallback? onSuffixTap,
    required double delay,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(delay, delay + 0.25,
                  curve: Curves.easeOut))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (suffixText != null)
                GestureDetector(
                  onTap: onSuffixTap,
                  child: Text(
                    suffixText,
                    style: const TextStyle(
                      color: Color(0xFF2C6BFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            obscureText: isObscured,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF2C6BFF), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: const Icon(Icons.lock_outline,
                  color: Color(0xFF2C6BFF), size: 20),
              suffixIcon: GestureDetector(
                onTap: () => onVisibilityChanged(!isObscured),
                child: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    String strength = 'Weak';
    Color strengthColor = Colors.red;
    double strengthValue = 0.3;

    if (_newPasswordController.text.length >= 8) {
      strength = 'Good';
      strengthColor = Colors.orange;
      strengthValue = 0.6;
    }
    if (_newPasswordController.text.length >= 12) {
      strength = 'Strong';
      strengthColor = Colors.green;
      strengthValue = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password Strength',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: strengthValue,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strength,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: strengthColor,
          ),
        ),
      ],
    );
  }

  void _handlePasswordChange(BuildContext context) {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_newPasswordController.text !=
        _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New passwords do not match'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Password must be at least 8 characters long'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password updated successfully!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
