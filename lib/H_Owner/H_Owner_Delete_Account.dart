import 'package:flutter/material.dart';
import 'package:bingo/Common/Logging.dart';

class HOwnerDeleteAccount extends StatefulWidget {
  const HOwnerDeleteAccount({super.key});

  @override
  State<HOwnerDeleteAccount> createState() => _HOwnerDeleteAccountState();
}

class _HOwnerDeleteAccountState extends State<HOwnerDeleteAccount> {
  bool _agreedToDelete = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Warning Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade400,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Center(
              child: Text(
                'Delete Account?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Description
            const Center(
              child: Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Warning Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What will be deleted:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDeleteItem('Your profile information'),
                  const SizedBox(height: 8),
                  _buildDeleteItem('All payment methods'),
                  const SizedBox(height: 8),
                  _buildDeleteItem('All job history'),
                  const SizedBox(height: 8),
                  _buildDeleteItem('All account settings'),
                  const SizedBox(height: 8),
                  _buildDeleteItem('Any associated data'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Checkbox
            Row(
              children: [
                Checkbox(
                  value: _agreedToDelete,
                  onChanged: (value) {
                    setState(() => _agreedToDelete = value ?? false);
                  },
                  activeColor: Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _agreedToDelete = !_agreedToDelete);
                    },
                    child: const Text(
                      'I understand and want to delete my account permanently',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Delete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _agreedToDelete ? Colors.red : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: _agreedToDelete && !_isLoading
                    ? () {
                        _showDeleteConfirmationDialog(context);
                      }
                    : null,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Cancel Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.red, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Account Deletion'),
          content: const Text(
            'This is your final confirmation. Your account and all associated data will be permanently deleted. This action cannot be reversed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount(context);
              },
              child: const Text(
                'Delete Permanently',
                style: TextStyle(color: Colors.red),
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
      // TODO: Call API to delete account
      // Simulating API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to login page after successful deletion
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            duration: Duration(seconds: 1),
          ),
        );

        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Logging()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
          ),
        );
      }
    }
  }
}
