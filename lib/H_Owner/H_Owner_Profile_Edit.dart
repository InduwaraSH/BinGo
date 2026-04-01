import 'package:flutter/material.dart';

class HOwnerProfileEdit extends StatefulWidget {
  const HOwnerProfileEdit({super.key});

  @override
  State<HOwnerProfileEdit> createState() => _HOwnerProfileEditState();
}

class _HOwnerProfileEditState extends State<HOwnerProfileEdit> {
  final _fullNameController = TextEditingController(text: 'John Doe');
  final _phoneController = TextEditingController(text: '+123 567 89000');
  final _emailController = TextEditingController(text: 'johndoe@example.com');
  final _dobController = TextEditingController(text: 'DD / MM / YYYY');
  final _userTypeController = TextEditingController(text: 'Admin');

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _userTypeController.dispose();
    super.dispose();
  }

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
          'Profile',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.blue),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: const AssetImage('assets/avatar.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Full Name
              _buildField(
                label: 'Full Name',
                controller: _fullNameController,
              ),
              const SizedBox(height: 20),
              // Phone Number
              _buildField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              // Email
              _buildField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Date of Birth
              _buildField(
                label: 'Date Of Birth',
                controller: _dobController,
                hint: 'DD / MM / YYYY',
              ),
              const SizedBox(height: 20),
              // User Type
              _buildField(
                label: 'User Type',
                controller: _userTypeController,
                isReadOnly: true,
              ),
              const SizedBox(height: 40),
              // Update Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement profile update
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.blue.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}
