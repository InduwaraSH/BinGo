import 'package:bingo/Common/Logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HOwnerHome extends StatefulWidget {
  final String? displayName;

  const HOwnerHome({super.key, this.displayName});

  @override
  State<HOwnerHome> createState() => _HOwnerHomeState();
}

class _HOwnerHomeState extends State<HOwnerHome> {
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descController = TextEditingController();
  // Controllers for the "Add Jobs" form (kept separate from complaints)
  final _jobFullNameController = TextEditingController();
  final _jobAddressController = TextEditingController();
  final _jobContactController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _jobWeightController = TextEditingController();
  bool _showComplaintForm = false;
  @override
  void initState() {
    super.initState();
    // Debug: log when this widget is built so we can confirm updated UI is used
    // Look for this message in the flutter run logs: "HOwnerHome: built (updated UI)"
    // Remove this when confirmed.
    // ignore: avoid_print
    print('HOwnerHome: built (updated UI)');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Header / greeting row
              Row(
                children: [
                  const CircleAvatar(radius: 22, backgroundImage: AssetImage('assets/avatar.png')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hi, WelcomeBack', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          widget.displayName == null || widget.displayName!.isEmpty ? 'John Doe' : widget.displayName!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Small date pills row (simplified)
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = 9 + index;
                    final isSelected = index == 2; // Wednesday selected in sample
                    return Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ['MON','TUE','WED','THU','FRI','SAT','SUN'][index],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : Colors.black45),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // Route card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Text("Today's Route", style: TextStyle(color: Colors.blueAccent)),
                    SizedBox(height: 8),
                    Text('Route A / Service Unavailable Today', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ADD JOBS card with form fields
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: Text('ADD JOBS', style: TextStyle(fontWeight: FontWeight.bold))),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _jobFullNameController, label: 'Full Name', hint: 'Jane Doe'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: _jobAddressController, label: 'Address', hint: 'Address'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: _jobContactController, label: 'Contact No.', hint: 'Number', keyboardType: TextInputType.phone),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(controller: _jobTypeController, label: 'Type (Plastic / Organic)', hint: 'Type')),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField(controller: _jobWeightController, label: 'Weight (Kg)', hint: 'Weight', keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('+ ADD JOBS', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            if (_jobFullNameController.text.isEmpty || _jobAddressController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job added')));
                            setState(() {
                              _jobFullNameController.clear();
                              _jobAddressController.clear();
                              _jobContactController.clear();
                              _jobTypeController.clear();
                              _jobWeightController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // COMPLAINTS header
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF36C2FF), Color(0xFF4A5BFF)]),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text('COMPLAINTS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 12),

              const Center(child: Text('ADD YOUR COMPLAINTS HERE . USING FOLLOWING\nADD BUTTON YOU CAN ADD YOUR COMPLAINTS', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12))),

              const SizedBox(height: 12),

              // + ADD button
              Center(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('+ ADD', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    setState(() => _showComplaintForm = !_showComplaintForm);
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Complaint form - shown when toggled
              if (_showComplaintForm)
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: Text('ADD JOBS', style: TextStyle(fontWeight: FontWeight.bold))),
                        const SizedBox(height: 12),
                        _buildTextField(controller: _fullNameController, label: 'Full Name', hint: 'Jane Doe'),
                        const SizedBox(height: 10),
                        _buildTextField(controller: _addressController, label: 'Address', hint: 'Address'),
                        const SizedBox(height: 10),
                        _buildTextField(controller: _contactController, label: 'Contact No.', hint: 'Number', keyboardType: TextInputType.phone),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text('Describe your problem', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _descController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Enter Your Problem Here...',
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade100)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // for now just show a snackbar and clear
                              if (_fullNameController.text.isEmpty || _descController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint added')));
                              setState(() {
                                _showComplaintForm = false;
                                _fullNameController.clear();
                                _addressController.clear();
                                _contactController.clear();
                                _descController.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                            child: const Text('+ ADD'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Logout button at bottom
              CupertinoButton(
                child: const Text('Logout'),
                onPressed: () {
                  FirebaseAuth.instance.signOut().whenComplete(() {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => Logging()),
                      (route) => false,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.blue.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade100)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descController.dispose();
    _jobFullNameController.dispose();
    _jobAddressController.dispose();
    _jobContactController.dispose();
    _jobTypeController.dispose();
    _jobWeightController.dispose();
    super.dispose();
  }
}
