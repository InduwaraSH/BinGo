// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// class DriReg extends StatefulWidget {
//   const DriReg({super.key});

//   @override
//   State<DriReg> createState() => _DriRegState();
// }

// class _DriRegState extends State<DriReg> {
//   int _selectedTown = 0;
//   TextEditingController usernameController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController nicController = TextEditingController();
//   TextEditingController mobileController = TextEditingController();
//   TextEditingController idController = TextEditingController();
//   TextEditingController passwordReController = TextEditingController();

//   late DatabaseReference employeeReference;

//   static const List<String> _townName = <String>[
//     'Embilipitiya',
//     'Matara',
//     'Colombo',
//     'Ratnapura',
//     'Galle',
//     "Hambantota",
//     "Tangalle",
//     "Weligama",
//     "Ahangama",
//     "Kamburupitiya",
//     "Akuressa",
//     "Deniyaya",
//     'Jaffna',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     employeeReference = FirebaseDatabase.instance.ref().child("employees");
//   }

//   void _showTownPicker() {
//     showCupertinoModalPopup<void>(
//       context: context,
//       builder: (BuildContext context) => Container(
//         height: 250,
//         color: Colors.white,
//         child: CupertinoPicker(
//           backgroundColor: Colors.white,
//           itemExtent: 40,
//           scrollController: FixedExtentScrollController(
//             initialItem: _selectedTown,
//           ),
//           onSelectedItemChanged: (int index) {
//             setState(() {
//               _selectedTown = index;
//             });
//           },
//           children: _townName
//               .map(
//                 (town) => Center(
//                   child: Text(
//                     town,
//                     style: const TextStyle(
//                       fontFamily: "sfproRoundRegular",
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//               )
//               .toList(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       extendBody: true,
//       backgroundColor: const Color(0xFF0D1117),
//       body: Stack(
//         children: [
//           // Gradient Background
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF111827), Color(0xFF1F2937)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),

//           // Top Accent Circle
//           Positioned(
//             top: -60,
//             right: -60,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [Colors.blue.shade400, Colors.cyanAccent.shade100],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//           ),

//           // Main Content
//           SafeArea(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24.0,
//                 vertical: 20.0,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Back button
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white.withOpacity(0.1),
//                           border: Border.all(color: Colors.white24),
//                         ),
//                         child: const Icon(
//                           Iconsax.arrow_left,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Title
//                   const Text(
//                     "RM Registration",
//                     style: TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       fontFamily: "sfProRoundSemiB",
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     "Provide accurate details for verification",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white60,
//                       fontSize: 16,
//                       fontFamily: "sfproRoundRegular",
//                     ),
//                   ),

//                   const SizedBox(height: 35),

//                   // Form Fields
//                   _buildTextField(
//                     idController,
//                     "Enter Your ID Number",
//                     Iconsax.card,
//                   ),
//                   const SizedBox(height: 20),

//                   _buildTextField(
//                     usernameController,
//                     "Enter Your Name",
//                     Iconsax.user,
//                   ),
//                   const SizedBox(height: 20),

//                   _buildTextField(
//                     nicController,
//                     "Enter Your NIC Number",
//                     Iconsax.user,
//                   ),
//                   const SizedBox(height: 20),

//                   _buildTextField(
//                     mobileController,
//                     "Enter Your Mobile Number",
//                     Iconsax.call,
//                     inputType: TextInputType.phone,
//                   ),
//                   const SizedBox(height: 20),

//                   // Town Picker
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(18),
//                       border: Border.all(color: Colors.white.withOpacity(0.2)),
//                     ),
//                     child: ListTile(
//                       onTap: _showTownPicker,
//                       leading: const Icon(
//                         Iconsax.location,
//                         color: Colors.white70,
//                       ),
//                       title: Text(
//                         _townName[_selectedTown],
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontFamily: "sfproRoundRegular",
//                         ),
//                       ),
//                       trailing: const Icon(
//                         Iconsax.arrow_down_1,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   _buildTextField(
//                     passwordController,
//                     "Enter Your Password",
//                     Iconsax.lock,
//                     obscure: true,
//                   ),
//                   const SizedBox(height: 20),

//                   _buildTextField(
//                     passwordReController,
//                     "Re-enter Password",
//                     Iconsax.lock_1,
//                     obscure: true,
//                   ),

//                   const SizedBox(height: 40),

//                   // Submit Button
//                   GestureDetector(
//                     onTap: _submitForm,
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(vertical: 18),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.blueAccent.withOpacity(0.4),
//                             blurRadius: 20,
//                             offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: const Center(
//                         child: Text(
//                           "Submit Registration",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 0.5,
//                             fontFamily: "sfProRoundSemiB",
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 50),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 🔹 Custom reusable TextField builder
//   Widget _buildTextField(
//     TextEditingController controller,
//     String hint,
//     IconData icon, {
//     bool obscure = false,
//     TextInputType? inputType,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: TextField(
//         controller: controller,
//         obscureText: obscure,
//         keyboardType: inputType ?? TextInputType.text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontFamily: "sfproRoundRegular",
//         ),
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Colors.white70),
//           border: InputBorder.none,
//           hintText: hint,
//           hintStyle: const TextStyle(color: Colors.white54),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 18,
//           ),
//         ),
//       ),
//     );
//   }

//   // 🔹 Submit logic (same functionality)
//   Future<void> _submitForm() async {
//     bool result = await InternetConnection().hasInternetAccess;

//     if (!result) {
//       _showSnack('No internet connection', Colors.grey);
//       return;
//     }

//     if (idController.text.isEmpty ||
//         usernameController.text.isEmpty ||
//         mobileController.text.isEmpty ||
//         nicController.text.isEmpty ||
//         passwordController.text.isEmpty ||
//         passwordReController.text.isEmpty ||
//         passwordController.text != passwordReController.text) {
//       _showSnack('Please fill all fields correctly', Colors.red);
//       return;
//     }

//     Map<String, String> employeeData = {
//       "employeeId": idController.text,
//       "employeeName": usernameController.text,
//       "employeeMobile": mobileController.text,
//       "employeePosition": "RM",
//       "employeeLocation": _townName[_selectedTown],
//       "employeePassword": passwordController.text,
//     };

//     employeeReference
//         .child(idController.text)
//         .set(employeeData)
//         .then((_) {
//           _showSnack(
//             '${usernameController.text} Registration Request Sent Successfully',
//             Colors.green,
//           );
//         })
//         .catchError((error) {
//           _showSnack("Failed to save data: $error", Colors.redAccent);
//         });
//   }

//   void _showSnack(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(color: Colors.white)),
//         duration: const Duration(seconds: 4),
//         backgroundColor: color,
//       ),
//     );
//   }
// }
