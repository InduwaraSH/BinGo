import 'package:bingo/Common/Logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class HOwnerHome extends StatefulWidget {
  const HOwnerHome({super.key});

  @override
  State<HOwnerHome> createState() => _HOwnerHomeState();
}

class _HOwnerHomeState extends State<HOwnerHome> with TickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circlePulse;
  late Animation<Offset> _circleMove1;
  late Animation<Offset> _circleMove2;

  bool _isLoading = true;
  Map<String, dynamic> _userProfile = {};
  List<Map<String, dynamic>> _myRequests = [];
  String? _currentUserEmail;
  String? _safeEmail;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchUserDataAndRequests();
  }

  void _setupAnimations() {
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _circlePulse = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    _circleMove1 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, -0.09),
    ).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    _circleMove2 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.05, 0.09),
    ).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );
  }

  Future<void> _fetchUserDataAndRequests() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Logging()),
        (route) => false,
      );
      return;
    }
    _currentUserEmail = user.email;
    _safeEmail = _currentUserEmail!.replaceAll('.', '_');

    try {
      // Fetch user profile from RTDB
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child("House_Owner_Profiles/House_Profile/$_safeEmail/Profile_Info")
          .once();

      if (event.snapshot.value != null) {
        setState(() {
          _userProfile = Map<String, dynamic>.from(event.snapshot.value as Map);
        });
      }

      // Listen to Firestore requests
      FirebaseFirestore.instance
          .collection('requests')
          .where('userEmail', isEqualTo: _currentUserEmail)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          var docs = snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();

          docs.sort((a, b) {
            Timestamp? tA = a['requestedDateTime'] as Timestamp?;
            Timestamp? tB = b['requestedDateTime'] as Timestamp?;
            if (tA == null && tB == null) return 0;
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tB.compareTo(tA);
          });

          _myRequests = docs.take(2).toList();
          _isLoading = false;
        });
      }, onError: (error) {
        print("Firestore stream error: $error");
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  void _showNewRequestModal() {
    if (_userProfile.isEmpty) {
      _showSnack('User profile not loaded yet.', Colors.orange);
      return;
    }

    String selectedType = 'biodegradable'; // default
    bool isSubmitting = false;
    TextEditingController weightController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF07121A),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4FF).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
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
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Place New Request',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select garbage type to place a collection request. Your profile details will be attached automatically.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Garbage Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTypeOption(
                    title: 'දිරණ (Biodegradable)',
                    value: 'biodegradable',
                    groupValue: selectedType,
                    icon: Icons.eco,
                    color: Colors.greenAccent,
                    onChanged: (val) {
                      setModalState(() => selectedType = val!);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTypeOption(
                    title: 'නොදිරණ (Non-biodegradable)',
                    value: 'nonBiodegradable',
                    groupValue: selectedType,
                    icon: Iconsax.trash,
                    color: Colors.orangeAccent,
                    onChanged: (val) {
                      setModalState(() => selectedType = val!);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTypeOption(
                    title: 'වීදුරු (Glass)',
                    value: 'glass',
                    groupValue: selectedType,
                    icon: Iconsax.glass,
                    color: Colors.lightBlueAccent,
                    onChanged: (val) {
                      setModalState(() => selectedType = val!);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Estimated Weight (kg)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'e.g. 5.5',
                        hintStyle: TextStyle(color: Colors.white30),
                        icon: Icon(Iconsax.weight, color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: isSubmitting
                        ? null
                        : () async {
                            if (weightController.text.trim().isEmpty) {
                              _showSnack('Please enter estimated weight', Colors.orange);
                              return;
                            }
                            setModalState(() => isSubmitting = true);
                            await _submitRequest(selectedType, weightController.text.trim());
                            Navigator.pop(context);
                            _showSnack(
                              'Request placed successfully!',
                              Colors.green,
                            );
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                          )
                        ],
                      ),
                      child: Center(
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit Request',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeOption({
    required String title,
    required String value,
    required String groupValue,
    required IconData icon,
    required Color color,
    required Function(String?) onChanged,
  }) {
    bool isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white54, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest(String type, String weight) async {
    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'userName': _userProfile['Owner_Name'] ?? 'Unknown User',
        'userMobile': _userProfile['Owner_Mobile'] ?? '',
        'userAddress': _userProfile['Owner_Address']?.replaceAll('_', '/') ?? '',
        'userEmail': _currentUserEmail,
        'requestedDateTime': FieldValue.serverTimestamp(),
        'garbageType': type,
        'weightInKg': double.tryParse(weight) ?? 0.0,
        'status': 'pending',
        'statusChangedDateTime': null,
      });
    } catch (e) {
      print('Error submitting request: $e');
      _showSnack('Failed to place request.', Colors.red);
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
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Requests',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showNewRequestModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'New',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00B4FF),
                          ),
                        )
                      : _myRequests.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _myRequests.length,
                              itemBuilder: (context, index) {
                                return _buildRequestCard(_myRequests[index]);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    String typeStr = request['garbageType'] ?? '';
    String statusStr = request['status'] ?? 'pending';

    String typeDisplay = 'Unknown';
    IconData typeIcon = Iconsax.box;
    Color typeColor = Colors.white54;

    if (typeStr == 'biodegradable') {
      typeDisplay = 'දිරණ (Biodegradable)';
      typeIcon = Icons.eco;
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
    if (statusStr == 'collected') statusColor = Colors.green;
    if (statusStr == 'rejected') statusColor = Colors.red;

    DateTime? reqDate;
    if (request['requestedDateTime'] != null) {
      reqDate = (request['requestedDateTime'] as Timestamp).toDate();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reqDate != null
                            ? DateFormat('MMM dd, yyyy - hh:mm a').format(reqDate)
                            : 'Unknown Date',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusStr.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ${request['id'].substring(0, 8).toUpperCase()}${request['weightInKg'] != null ? ' • ${request['weightInKg']}kg' : ''}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              if (request['userAddress'] != null)
                Expanded(
                  child: Text(
                    request['userAddress'],
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_text, size: 60, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'No requests found',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Place your first garbage collection request.',
            style: TextStyle(color: Colors.white30, fontSize: 13),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _showNewRequestModal,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00B4FF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Place Request',
              style: TextStyle(color: Color(0xFF00B4FF)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B4FF).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Iconsax.user, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back,',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    _userProfile['Owner_Name'] ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Iconsax.logout, color: Colors.white70),
            onPressed: () {
              FirebaseAuth.instance.signOut().whenComplete(() {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Logging()),
                  (route) => false,
                );
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _circleController,
      builder: (context, child) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Transform.translate(
                offset: Offset(
                  90 * _circleMove1.value.dx,
                  70 * _circleMove1.value.dy,
                ),
                child: Transform.scale(
                  scale: _circlePulse.value,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0E5AA7).withOpacity(0.15),
                          const Color(0xFF00B4FF).withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B4FF).withOpacity(0.1),
                          blurRadius: 60,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Transform.translate(
                offset: Offset(
                  -50 * _circleMove2.value.dx,
                  -40 * _circleMove2.value.dy,
                ),
                child: Transform.scale(
                  scale: _circlePulse.value,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6A0FA6).withOpacity(0.08),
                          const Color(0xFF00B4FF).withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A0FA6).withOpacity(0.1),
                          blurRadius: 80,
                          spreadRadius: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
