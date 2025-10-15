import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class HOwnerReg extends StatefulWidget {
  const HOwnerReg({super.key});

  @override
  State<HOwnerReg> createState() => _HOwnerRegState();
}

class _HOwnerRegState extends State<HOwnerReg> {
  int _selectedTown = 0;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nicController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController passwordReController = TextEditingController();

  late DatabaseReference branchReference;
  late DatabaseReference employeeReference;

  static const double _kItemExtent = 32.0;
  static const List<String> _townName = <String>[
    'Embilipitya',
    'Matara',
    'Colombo',
    'Ratnapura',
    'Galle',
    "Hambantota",
    "Tangalle",
    "Weligama",
    "Ahangama",
    "Kamburupitiya",
    "Akuressa",
    "Deniyaya",
    'Jaffna',
  ];

  @override
  void initState() {
    super.initState();

    employeeReference = FirebaseDatabase.instance.ref().child("employees");
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(top: false, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 250,
                    width: size.width - 30,

                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Icon(Iconsax.user_add, size: 50, color: Colors.blue),
                        Center(
                          child: Text(
                            "RM Registration",
                            style: TextStyle(
                              fontFamily: "sfproRoundSemiB",
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Text(
                            "Please complete your registration by providing accurate details. Submitted information will be reviewed by the administration, and once verified, your account will be approved. Thank you for your trust.",
                            style: TextStyle(
                              fontFamily: "sfproRoundRegular",
                              fontSize: 15,
                              color: Colors.blue[300],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                /// Enter Your Id Number
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 5),
                  child: Text(
                    "Enter Your Id Number",
                    style: TextStyle(
                      fontFamily: "sfproRoundSemiB",
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: idController,
                  style: TextStyle(
                    color: Colors.black, // text color
                    fontFamily: "sfproRoundRegular", // your custom font
                    fontSize: 16, // text size
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: "ID Number",
                    hintText: "Enter your ID Number",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // rounded corners
                      borderSide: BorderSide(
                        color: Colors.grey.shade400, // thin grey border
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black, // highlight color when focused
                        width: 2,
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "sfproRoundRegular",
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //Enter your name
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 5),
                  child: Text(
                    "Enter Your Name",
                    style: TextStyle(
                      fontFamily: "sfproRoundSemiB",
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: usernameController,
                  style: TextStyle(
                    color: Colors.black, // text color
                    fontFamily: "sfproRoundRegular", // your custom font
                    fontSize: 16, // text size
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "Enter your Name",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // rounded corners
                      borderSide: BorderSide(
                        color: Colors.grey.shade400, // thin grey border
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black, // highlight color when focused
                        width: 2,
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "sfproRoundRegular",
                    ),
                  ),
                ),

                SizedBox(height: 20),

                //Enter your nic number
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 5),
                  child: Text(
                    "Enter Your NIC Number",
                    style: TextStyle(
                      fontFamily: "sfproRoundSemiB",
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: nicController,
                  style: TextStyle(
                    color: Colors.black, // text color
                    fontFamily: "sfproRoundRegular", // your custom font
                    fontSize: 16, // text size
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: "NIC Number",
                    hintText: "Enter your NIC Number",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // rounded corners
                      borderSide: BorderSide(
                        color: Colors.grey.shade400, // thin grey border
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black, // highlight color when focused
                        width: 2,
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "sfproRoundRegular",
                    ),
                  ),
                ),

                SizedBox(height: 20),

                //Enter your mobile number
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 5),
                  child: Text(
                    "Enter Your Mobile Number",
                    style: TextStyle(
                      fontFamily: "sfproRoundSemiB",
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: mobileController,
                  style: TextStyle(
                    color: Colors.black, // text color
                    fontFamily: "sfproRoundRegular", // your custom font
                    fontSize: 16, // text size
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    hintText: "Enter your Mobile Number",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // rounded corners
                      borderSide: BorderSide(
                        color: Colors.grey.shade400, // thin grey border
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black, // highlight color when focused
                        width: 2,
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "sfproRoundRegular",
                    ),
                  ),
                ),

                SizedBox(height: 20),

                //Enter your office name
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 5),
                  child: Text(
                    "Enter Your Office location",
                    style: TextStyle(
                      fontFamily: "sfproRoundSemiB",
                      fontSize: 16,
                    ),
                  ),
                ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      height: 50,
                      width: size.width - 180,

                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: CupertinoColors.label.resolveFrom(context),
                          fontSize: 22.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  // Display a CupertinoPicker with list of Stands.
                                  onPressed: () => _showDialog(
                                    CupertinoPicker(
                                      magnification: 1.32,
                                      squeeze: 1.2,
                                      useMagnifier: true,
                                      itemExtent: _kItemExtent,

                                      // This sets the initial item.
                                      scrollController:
                                          FixedExtentScrollController(
                                            initialItem: _selectedTown,
                                          ),
                                      // This is called when selected item is changed.
                                      onSelectedItemChanged:
                                          (int selectedItem) {
                                            setState(() {
                                              _selectedTown = selectedItem;
                                            });
                                          },
                                      children: List<Widget>.generate(
                                        _townName.length,
                                        (int index) {
                                          return Center(
                                            child: Text(
                                              _townName[index],
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: "sfproRoundRegular",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 25.0,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // This displays the selected fruit name.
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      color: const Color.fromARGB(
                                        0,
                                        64,
                                        195,
                                        255,
                                      ),
                                      padding: EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 5.0,
                                        bottom: 5.0,
                                      ),
                                      child: Text(
                                        _townName[_selectedTown],
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.black,
                                          fontFamily: "sfproRoundSemiB",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //Enter your password
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 5),
                  child: Text(
                    "Enter Your Password",
                    style: TextStyle(
                      fontFamily: "sfproRoundSemiB",
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: passwordController,
                  style: TextStyle(
                    color: Colors.black, // text color
                    fontFamily: "sfproRoundRegular", // your custom font
                    fontSize: 16, // text size
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your Password",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // rounded corners
                      borderSide: BorderSide(
                        color: Colors.grey.shade400, // thin grey border
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black, // highlight color when focused
                        width: 2,
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "sfproRoundRegular",
                    ),
                  ),
                ),

                SizedBox(height: 20),

                //Re Enter your password
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 5),
                  child: Text(
                    "Re Enter Your Password",
                    style: TextStyle(
                      fontFamily: "sfproRoundSemiB",
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: passwordReController,
                  style: TextStyle(
                    color: Colors.black, // text color
                    fontFamily: "sfproRoundRegular", // your custom font
                    fontSize: 16, // text size
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your Password",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: "sfproRoundRegular",
                      fontWeight: FontWeight.bold,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // rounded corners
                      borderSide: BorderSide(
                        color: Colors.grey.shade400, // thin grey border
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.black, // highlight color when focused
                        width: 2,
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "sfproRoundRegular",
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: CupertinoButton(
                        color: Colors.blue.withOpacity(0.2),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            fontFamily: "sfproRoundSemiB",
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () async {
                          bool result =
                              await InternetConnection().hasInternetAccess;

                          if (result == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No internet connection',
                                  style: TextStyle(color: Colors.white),
                                ),
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.grey,
                              ),
                            );
                            return;
                          } else {
                            if (idController.text.isEmpty ||
                                usernameController.text.isEmpty ||
                                mobileController.text.isEmpty ||
                                nicController.text.isEmpty ||
                                passwordController.text.isEmpty ||
                                _townName[_selectedTown].toString().isEmpty ||
                                passwordReController.text.isEmpty ||
                                passwordController.text !=
                                    passwordReController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please fill all fields correctly',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  duration: Duration(seconds: 5),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            } else {
                              Map<String, String> employeeData = {
                                "employeeId": idController.text,
                                "employeeName": usernameController.text,
                                "employeeMobile": mobileController.text,
                                "employeePosition": "RM",
                                "employeeLocation": _townName[_selectedTown]
                                    .toString(),
                                "employeePassword": passwordController.text,
                              };
                              employeeReference
                                  .child(idController.text)
                                  .set(employeeData)
                                  .then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${usernameController.text} Registration Request Sent Successfully',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        duration: Duration(seconds: 5),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  })
                                  .catchError((error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Failed to save manager data: $error",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        duration: Duration(seconds: 5),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
