import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../widgets/payment_background.dart';

class PaymentSuccessPage extends StatefulWidget {
  final double amount;
  const PaymentSuccessPage({super.key, required this.amount});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isSaving = true;
  String _monthsStr = '';

  @override
  void initState() {
    super.initState();
    _savePayment();
  }

  Future<void> _savePayment() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      String safeEmail = user.email!.replaceAll('.', '_');
      
      DateTime now = DateTime.now();
      _monthsStr = DateFormat('MMMM yyyy').format(now);
      
      if (widget.amount > 1000) {
        int months = (widget.amount / 1000).toInt();
        _monthsStr = '$months Months up to ${DateFormat('MMMM yyyy').format(now)}';
      }

      try {
        // Fetch House ID
        DatabaseEvent profileEvent = await FirebaseDatabase.instance
            .ref()
            .child("House_Owner_Profiles/House_Profile/$safeEmail/Profile_Info")
            .once();
            
        String houseId = safeEmail;
        if (profileEvent.snapshot.value != null) {
          Map profileData = profileEvent.snapshot.value as Map;
          if (profileData['Registered_House_ID'] != null && profileData['Registered_House_ID'].toString().isNotEmpty) {
            houseId = profileData['Registered_House_ID'].toString();
          }
        }

        await FirebaseDatabase.instance.ref().child("payment_detail/$houseId").push().set({
          'date': now.toIso8601String(),
          'time': DateFormat('hh:mm a').format(now),
          'amount': widget.amount,
          'payment_for_what_months': _monthsStr,
        });
      } catch (e) {
        print("Error saving payment details: $e");
      }
    }
    
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      body: PaymentBackground(
        child: SafeArea(
          child: _isSaving 
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00B4FF)),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00B4FF).withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.check, size: 64, color: Colors.white),
                          ),
                          const SizedBox(height: 40),
                          const Text('Congratulations!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text('Payment is Successful', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
                          
                          const SizedBox(height: 40),
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Column(
                                children: [
                                  const Text('You have successfully paid the Pradeshiya Sabha fee', style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5), textAlign: TextAlign.center),
                                  const SizedBox(height: 20),
                                  const Divider(color: Colors.white10),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.calendar_today, color: Color(0xFF00B4FF), size: 20),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(_monthsStr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'LKR ${widget.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFF00B4FF), fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF00B4FF).withOpacity(0.5)),
                          ),
                          child: const Center(
                            child: Text(
                              'Back to Home',
                              style: TextStyle(
                                color: Color(0xFF00B4FF),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
