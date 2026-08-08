import 'package:bingo/Common/Logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'H_Owner_NAv_Bar.dart';
import 'H_Owner_Tracking_Map.dart';
import 'pickup_location_picker.dart';

class HOwnerHome extends StatefulWidget {
  final String? displayName;

  const HOwnerHome({super.key, this.displayName});

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
        final profileData = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (mounted) {
          setState(() {
            _userProfile = profileData;
            _isLoading = false;
          });
        }
        if (Get.isRegistered<RMNavigControll>()) {
          Get.find<RMNavigControll>().userProfile.value = profileData;
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  Future<void> _showNewRequestModal() async {
    if (_userProfile.isEmpty) {
      _showSnack('User profile not loaded yet.', Colors.orange);
      return;
    }

    String selectedType = 'biodegradable'; // default
    bool isSubmitting = false;
    bool isLocating = false;
    TextEditingController weightController = TextEditingController();
    TextEditingController saveLabelController = TextEditingController();

    LatLng? pickupLocation;
    String? pickupLabel;
    bool pickupFromSaved = false;

    List<Map<String, dynamic>> savedLocations = [];
    if (_safeEmail != null) {
      try {
        final snap = await FirebaseDatabase.instance
            .ref('House_Owner_Profiles/House_Profile/$_safeEmail/Saved_Locations')
            .get();
        if (snap.value != null) {
          final raw = Map<String, dynamic>.from(snap.value as Map);
          savedLocations = raw.entries.map((e) {
            final v = Map<String, dynamic>.from(e.value as Map);
            return {'key': e.key, 'label': v['label'], 'lat': v['lat'], 'lng': v['lng']};
          }).toList();
        }
      } catch (_) {
        // No saved locations yet, or offline — fine, just start with none.
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> useCurrentLocation() async {
              setModalState(() => isLocating = true);
              try {
                bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) {
                  _showSnack('Please enable location services', Colors.orange);
                  return;
                }
                LocationPermission permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                }
                if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                  _showSnack('Location permission denied', Colors.orange);
                  return;
                }
                final position = await Geolocator.getCurrentPosition();
                setModalState(() {
                  pickupLocation = LatLng(position.latitude, position.longitude);
                  pickupLabel = null;
                  pickupFromSaved = false;
                });
              } catch (_) {
                _showSnack('Could not get current location', Colors.red);
              } finally {
                setModalState(() => isLocating = false);
              }
            }

            Future<void> pickOnMap() async {
              final result = await Navigator.push<LatLng>(
                context,
                MaterialPageRoute(builder: (_) => PickupLocationPicker(initialCenter: pickupLocation)),
              );
              if (result != null) {
                setModalState(() {
                  pickupLocation = result;
                  pickupLabel = null;
                  pickupFromSaved = false;
                });
              }
            }

            void selectSaved(Map<String, dynamic> loc) {
              setModalState(() {
                pickupLocation = LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
                pickupLabel = loc['label'] as String?;
                pickupFromSaved = true;
              });
            }

            Future<void> saveCurrentAsLocation(String label) async {
              if (pickupLocation == null || _safeEmail == null) return;
              final trimmed = label.trim().isEmpty ? 'Saved' : label.trim();
              final key = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
              try {
                await FirebaseDatabase.instance
                    .ref('House_Owner_Profiles/House_Profile/$_safeEmail/Saved_Locations/$key')
                    .set({'label': trimmed, 'lat': pickupLocation!.latitude, 'lng': pickupLocation!.longitude});
                setModalState(() {
                  savedLocations.removeWhere((l) => l['key'] == key);
                  savedLocations.add({'key': key, 'label': trimmed, 'lat': pickupLocation!.latitude, 'lng': pickupLocation!.longitude});
                  pickupLabel = trimmed;
                  pickupFromSaved = true;
                  saveLabelController.clear();
                });
              } catch (_) {
                _showSnack('Could not save location', Colors.red);
              }
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    'Pickup Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: isLocating ? null : useCurrentLocation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Center(
                              child: isLocating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Iconsax.gps, size: 16, color: Colors.white70),
                                        SizedBox(width: 8),
                                        Text('Current Location', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: pickOnMap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Iconsax.map, size: 16, color: Colors.white70),
                                  SizedBox(width: 8),
                                  Text('Pick on Map', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (savedLocations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: savedLocations.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final loc = savedLocations[index];
                          final bool selected = pickupFromSaved && pickupLabel == loc['label'];
                          final String label = (loc['label'] as String?) ?? 'Saved';
                          return GestureDetector(
                            onTap: () => selectSaved(loc),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFF00B4FF).withOpacity(0.15) : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: selected ? const Color(0xFF00B4FF) : Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    label.toLowerCase() == 'home'
                                        ? Iconsax.home
                                        : label.toLowerCase() == 'office'
                                            ? Iconsax.briefcase
                                            : Iconsax.location,
                                    size: 14,
                                    color: selected ? const Color(0xFF00B4FF) : Colors.white54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(label, style: TextStyle(color: selected ? const Color(0xFF00B4FF) : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (pickupLocation != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: Colors.greenAccent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pickupLabel ?? '${pickupLocation!.latitude.toStringAsFixed(5)}, ${pickupLocation!.longitude.toStringAsFixed(5)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (!pickupFromSaved) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: saveLabelController,
                                    textInputAction: TextInputAction.done,
                                    keyboardAppearance: Brightness.dark,
                                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Save as (e.g. Home)',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => saveCurrentAsLocation(saveLabelController.text),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(color: const Color(0xFF00B4FF).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                    child: const Text('Save', style: TextStyle(color: Color(0xFF00B4FF), fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
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
                      textInputAction: TextInputAction.done,
                      keyboardAppearance: Brightness.dark,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                            if (pickupLocation == null) {
                              _showSnack('Please set a pickup location', Colors.orange);
                              return;
                            }
                            setModalState(() => isSubmitting = true);
                            await _submitRequest(selectedType, weightController.text.trim(), pickupLocation!);
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
              ),
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

  Future<void> _submitRequest(String type, String weight, LatLng pickupLocation) async {
    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'userName': _userProfile['Owner_Name'] ?? 'Unknown User',
        'userMobile': _userProfile['Owner_Mobile'] ?? '',
        'userAddress': _userProfile['Owner_Address']?.replaceAll('_', '/') ?? '',
        'userEmail': _currentUserEmail,
        'requestedDateTime': FieldValue.serverTimestamp(),
        'garbageType': type,
        'weightInKg': double.tryParse(weight) ?? 0.0,
        'pickupLat': pickupLocation.latitude,
        'pickupLng': pickupLocation.longitude,
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
    return Container(
      color: const Color(0xFF07121A),
      child: Stack(
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('requests')
                        .where('userEmail', isEqualTo: FirebaseAuth.instance.currentUser?.email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00B4FF),
                          ),
                        );
                      }

                      var docs = snapshot.data!.docs.map((doc) {
                        return {
                          'id': doc.id,
                          ...doc.data() as Map<String, dynamic>,
                        };
                      }).toList();

                      // Sort by date
                      docs.sort((a, b) {
                        final aTime = a['requestedDateTime'];
                        final bTime = b['requestedDateTime'];
                        Timestamp? tA = aTime is Timestamp ? aTime : null;
                        Timestamp? tB = bTime is Timestamp ? bTime : null;
                        if (tA == null && tB == null) return 0;
                        if (tA == null) return 1;
                        if (tB == null) return -1;
                        return tB.compareTo(tA);
                      });

                      if (docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Show only the latest 2 requests
                      var recentDocs = docs.take(2).toList();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true, // Add shrinkWrap as it's often better for small lists in Column
                        physics: const NeverScrollableScrollPhysics(), // Disable scrolling as it's a fixed small list
                        itemCount: recentDocs.length,
                        itemBuilder: (context, index) {
                          return _buildRequestCard(recentDocs[index]);
                        },
                      );
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
    if (statusStr == 'assigned') statusColor = const Color(0xFF00B4FF);
    if (statusStr == 'collected') statusColor = Colors.green;
    if (statusStr == 'rejected') statusColor = Colors.red;

    final String? assignedDriverId = request['assignedDriverId'];
    final String? assignedDriverName = request['assignedDriverName'];

    DateTime? reqDate;
    final rDate = request['requestedDateTime'];
    if (rDate is Timestamp) {
      reqDate = rDate.toDate();
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
              Expanded(
                child: Row(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            typeDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
          ),
          if (assignedDriverId != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Iconsax.truck, size: 16, color: Color(0xFF00B4FF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Driver: ${assignedDriverName ?? 'Assigned'}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HOwnerTrackingMap(
                        assignedDriverId: assignedDriverId,
                        driverName: assignedDriverName ?? 'Driver',
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Track', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
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
              Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Container(
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
                  );
                }
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
