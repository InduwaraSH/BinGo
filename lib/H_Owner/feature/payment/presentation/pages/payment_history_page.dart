import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../widgets/payment_background.dart';
import 'payment_page.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _paymentHistory = [];
  double _outstandingAmount = 1000.0; // Default to 1000 LKR
  Map<String, dynamic>? _lastPayment;

  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() => _isLoading = false);
      return;
    }

    String safeEmail = user.email!.replaceAll('.', '_');

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

      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child("payment_detail/$houseId")
          .once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> tempHistory = [];

        data.forEach((key, value) {
          tempHistory.add({
            'id': key,
            ...Map<String, dynamic>.from(value),
          });
        });

        // Sort by date descending
        tempHistory.sort((a, b) {
          DateTime dateA = DateTime.parse(a['date'] ?? DateTime.now().toIso8601String());
          DateTime dateB = DateTime.parse(b['date'] ?? DateTime.now().toIso8601String());
          return dateB.compareTo(dateA);
        });

        setState(() {
          _paymentHistory = tempHistory;
          if (_paymentHistory.isNotEmpty) {
            _lastPayment = _paymentHistory.first;
            
            DateTime lastPaidDate = DateTime.parse(_lastPayment!['date']);
            DateTime now = DateTime.now();
            int monthDiff = (now.year - lastPaidDate.year) * 12 + now.month - lastPaidDate.month;
            
            if (monthDiff <= 0) {
              _outstandingAmount = 0;
            } else {
              _outstandingAmount = monthDiff * 1000.0;
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching history: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Payment History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      extendBodyBehindAppBar: true,
      body: PaymentBackground(
        child: SafeArea(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4FF)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: GestureDetector(
                        onTap: () {
                          if (_outstandingAmount > 0) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PaymentPage(
                                      outstandingAmount: _outstandingAmount,
                                      lastPayment: _lastPayment,
                                    ) as Widget,
                              ),
                            ).then((value) {
                              setState(() {
                                _isLoading = true;
                              });
                              _fetchPaymentHistory();
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B4FF), Color(0xFF6DD3FF)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00B4FF).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'LKR ${_outstandingAmount.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _outstandingAmount > 0 ? 'Tap to Pay Outstanding Balance' : 'No Outstanding Balance',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Past Payments', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _paymentHistory.isEmpty
                          ? const Center(
                              child: Text('No past payments found', style: TextStyle(color: Colors.white54)),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _paymentHistory.length,
                              itemBuilder: (context, index) {
                                final payment = _paymentHistory[index];
                                DateTime pDate = DateTime.parse(payment['date'] ?? DateTime.now().toIso8601String());
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payment['payment_for_what_months'] ?? DateFormat('MMMM yyyy').format(pDate),
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('MMM dd, yyyy - hh:mm a').format(pDate),
                                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'LKR ${payment['amount']?.toString() ?? '0.00'}',
                                        style: const TextStyle(color: Color(0xFF00B4FF), fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
        ),
      ),
    );
  }
}
