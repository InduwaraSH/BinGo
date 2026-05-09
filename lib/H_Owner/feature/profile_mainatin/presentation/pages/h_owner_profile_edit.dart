import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HOwnerProfileEdit extends StatefulWidget {
  const HOwnerProfileEdit({super.key});

  @override
  State<HOwnerProfileEdit> createState() => _HOwnerProfileEditState();
}

class _HOwnerProfileEditState extends State<HOwnerProfileEdit> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nicController = TextEditingController();
  final _addressController = TextEditingController();
  final _houseIdController = TextEditingController();

  bool _isLoading = true;
  String? _safeEmail;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _emailController.text = user.email!;
      _safeEmail = user.email!.replaceAll('.', '_');
      
      try {
        DatabaseEvent event = await FirebaseDatabase.instance
            .ref()
            .child("House_Owner_Profiles/House_Profile/$_safeEmail/Profile_Info")
            .once();
            
        if (event.snapshot.value != null) {
          Map data = event.snapshot.value as Map;
          setState(() {
            _fullNameController.text = data['Owner_Name'] ?? '';
            _phoneController.text = data['Owner_Mobile'] ?? '';
            _emailController.text = data['Owner_Email'] ?? '';
            _nicController.text = data['Owner_NIC'] ?? '';
            _addressController.text = data['Owner_Address'] ?? '';
            _houseIdController.text = data['Registered_House_ID'] ?? '';
            _isLoading = false;
          });
        } else {
           setState(() => _isLoading = false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
     if (_safeEmail == null) return;
     
     setState(() => _isLoading = true);
     try {
       await FirebaseDatabase.instance
            .ref()
            .child("House_Owner_Profiles/House_Profile/$_safeEmail/Profile_Info")
            .update({
              'Owner_Name': _fullNameController.text,
              'Owner_NIC': _nicController.text,
              'Owner_Address': _addressController.text,
            });
            
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
         );
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
         );
       }
     } finally {
       if (mounted) {
         setState(() => _isLoading = false);
       }
     }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nicController.dispose();
    _addressController.dispose();
    _houseIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)))
        : SingleChildScrollView(
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
                      backgroundColor: Colors.white10,
                      child: const Icon(Icons.person, size: 70, color: Colors.white54),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B4FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF07121A), width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
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
                isReadOnly: true,
              ),
              const SizedBox(height: 20),
              // Email
              _buildField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isReadOnly: true,
              ),
              const SizedBox(height: 20),
              // NIC
              _buildField(
                label: 'NIC Number',
                controller: _nicController,
              ),
              const SizedBox(height: 20),
              // Address
              _buildField(
                label: 'Address',
                controller: _addressController,
              ),
              const SizedBox(height: 20),
              // Registered House ID
              _buildField(
                label: 'Registered House ID',
                controller: _houseIdController,
                isReadOnly: true,
              ),
              const SizedBox(height: 40),
              // Update Profile Button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B4FF).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _updateProfile,
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
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: isReadOnly,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00B4FF)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintStyle: TextStyle(
              color: Colors.white30,
            ),
          ),
        ),
      ],
    );
  }
}
