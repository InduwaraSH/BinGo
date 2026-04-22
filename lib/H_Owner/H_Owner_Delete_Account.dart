import 'package:flutter/material.dart';
import 'package:bingo/Common/Logging.dart';

class HOwnerDeleteAccount extends StatefulWidget {
  const HOwnerDeleteAccount({super.key});

  @override
  State<HOwnerDeleteAccount> createState() => _HOwnerDeleteAccountState();
}

class _HOwnerDeleteAccountState extends State<HOwnerDeleteAccount>
    with SingleTickerProviderStateMixin {
  bool _agreedToDelete = false;
  bool _isLoading = false;
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
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Delete Account',
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
              const SizedBox(height: 20),
              // Warning Icon with animation
              ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade400,
                      size: 56,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Title
              const Center(
                child: Text(
                  'Delete Account?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Description
              const Center(
                child: Text(
                  'This action cannot be undone. All your data, bookings, and payment information will be permanently removed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Warning Box
              SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(-0.3, 0), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.2, 0.6,
                            curve: Curves.easeOut))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This will delete:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDeleteItem('Your profile and personal information'),
                      const SizedBox(height: 10),
                      _buildDeleteItem('All payment methods and billing history'),
                      const SizedBox(height: 10),
                      _buildDeleteItem('Complete booking history and records'),
                      const SizedBox(height: 10),
                      _buildDeleteItem('All saved preferences and settings'),
                      const SizedBox(height: 10),
                      _buildDeleteItem('Any associated media and files'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Checkbox
              SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(-0.3, 0), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.35, 0.7,
                            curve: Curves.easeOut))),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: _agreedToDelete
                            ? Colors.red.shade400
                            : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _agreedToDelete,
                        onChanged: (value) {
                          setState(() => _agreedToDelete = value ?? false);
                        },
                        activeColor: Colors.red,
                        side: const BorderSide(
                            color: Colors.red, width: 2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() =>
                                _agreedToDelete = !_agreedToDelete);
                          },
                          child: const Text(
                            'Yes, I understand that this action is permanent',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Delete Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.delete_outline, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _agreedToDelete
                        ? Colors.red.shade600
                        : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      _agreedToDelete && !_isLoading
                          ? () =>
                              _showDeleteConfirmationDialog(context)
                          : null,
                  label: Text(
                    _isLoading ? 'Deleting...' : 'Delete Account',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Cancel Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(
                      color: Colors.black87, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

  Widget _buildDeleteItem(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Final Confirmation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            'This is your final confirmation. Your account and all associated data will be permanently deleted. This action cannot be reversed.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount(context);
              },
              label: const Text(
                'Delete Permanently',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // Simulating API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account deleted successfully'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );

        // Navigate to login page
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => Logging()),
            (route) => false,
          );
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
