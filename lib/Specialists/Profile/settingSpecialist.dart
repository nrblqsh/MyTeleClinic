import 'dart:core';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/Profile/patient_home_page.dart';
import 'package:my_teleclinic/Main/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../Main/changePassword1.dart';
import '../../Model/specialist.dart';
import '../../Patients/EMR/e_medical_record.dart';
import '../../Patients/Telemedicine/view_appointment.dart';
import '../../Patients/Telemedicine/view_specialist.dart';
import '../../Patients/Profile/editProfile.dart';
import '../../Patients/Profile/editProfile1.dart';
//import '../../Patients/Main/changePassword1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Main/main.dart';
import '../editProfileSpecialist.dart';


class SettingsSpecialistScreen extends StatefulWidget {
  late int specialistID;

  SettingsSpecialistScreen({required this.specialistID});
  @override
  State<SettingsSpecialistScreen> createState() => _SettingsSpecialistScreenState();
}

class _SettingsSpecialistScreenState extends State<SettingsSpecialistScreen> {
late int specialistID;
  String? specialistName;
  String? phoneNumber;
  String phone = '';
  String name = '';
  Uint8List? specialistImage;


  final Specialist _specialist = Specialist(
    specialistID: 0, // You may need to set the correct specialist ID
    clinicID: 0, // You may need to set the correct clinic ID
    specialistName: '', // You may need to set the correct specialist name
    specialistTitle: '', // You may need to set the correct specialist title
    phone: '', // You may need to set the correct phone number
    password: '', // You may need to set the correct password
    logStatus: '', // You may need to set the correct log status
    clinicName: '',
    specialistImagePath: Uint8List(0), // Empty Uint8List for no image
  );

  ImageProvider<Object>? _getImageProvider() {
    if (_specialist.specialistImagePath != null && _specialist.specialistImagePath!.isNotEmpty) {
      return MemoryImage(_specialist.specialistImagePath!); // Display the existing image
    } else {
      return AssetImage('asset/profile image default.jpg');
    }
  }


  Future<void> _loadID() async {
    try {
      List<Specialist> specialists = await Specialist.loadAll();

      if (specialists.isNotEmpty) {
        Specialist firstSpecialist = specialists.first;

        print("Raw JSON Data: ${firstSpecialist.toJson()}");

        setState(() {
          specialistName = firstSpecialist.specialistName ?? 'N/A';
          phoneNumber = firstSpecialist.phone ?? 'N/A';

        });

        print("Patient Information:");
        print("Name: $specialistName");
       ;

        print("\n");
      } else {
        print('No patient data available');
      }
    } catch (e) {
      print('Error loading specialists: $e');
    }
  }


  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  @override
  void initState() {
    _loadID();
    _loadSpecialistImage();
    _loadData();
  }


Future<void> _loadSpecialistImage() async {
  try {
    Uint8List? imageBytes = await Specialist.getSpecialistImage();

    if (imageBytes != null && imageBytes.isNotEmpty) {
      setState(() {
        _specialist.specialistImagePath = imageBytes;
      });
    } else {
      print('Invalid or empty image data');
    }
  } catch (e) {
    print('Error loading specialist image: $e');
  }
}


  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedSpecialistID = prefs.getInt("specialistID") ?? 0;
    String storedPhone = prefs.getString("phone") ?? "";
    String storedName = prefs.getString("specialistName") ?? "";

    setState(() {
      specialistID = storedSpecialistID;
      name = storedName;
      phone = storedPhone;
    });
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int specialistID = prefs.getInt("specialistID") ?? 0;
    print("sp${specialistID}");

    try {
      final String url = 'http://${MyApp.ipAddress}/teleclinic/logoutSpecialist.php?specialistID=$specialistID';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          showSnackBar(data['message']);
          /// on User logout
          void onUserLogout() {
            ZegoUIKitPrebuiltCallInvitationService().uninit();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          showSnackBar('Error logging out');
        }
      } else {
        showSnackBar('Error logging out');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }

  Widget settings(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 65,
        padding: EdgeInsets.only(left: 15, right: 20, top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // You can add your own custom icon here if needed
                Icon(
                  Icons.navigate_next_outlined,
                  color: Colors.grey,
                ),
              ],
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }


  Widget general(String label, VoidCallback onTap, List<GeneralItem> generalItems) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 65,
        padding: EdgeInsets.only(left: 15, right: 20, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // You can add your own custom icon here if needed
                Icon(
                  Icons.navigate_next_outlined,
                  color: Colors.grey,
                ),
              ],
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.blue,
        ),
        title: Center(
          child: Image.asset(
            "asset/MYTeleClinic.png",
            width: 594,
            height: 258,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      key: UniqueKey(), // Add this line
                      radius: 45,
                      backgroundImage: _getImageProvider(),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(top:25.0, left: 20),
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              child: Text(
                                specialistName?.isEmpty ?? true ? name
                                    : specialistName!,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(right:10.0),
                              child: Container(


                                child: Text(
                                  phoneNumber?.isEmpty ?? true ? "+6$phone" :
                                  "+6$phoneNumber"!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )

                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 40.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'My account',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 30.0,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),

            settings('Edit Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileSpecialist()),
              );
            }),
            settings('Change Password', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
            }),

            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 10.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'General',
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 30.0,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),

            general('Help Centre', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneralPage(
                    title: 'Help Center',
                    generalItems: [
                      GeneralItem(
                        question: 'How do I create an account?',
                        answer: 'To create an account, go to the Settings screen -> select "Create Account."',
                      ),
                      // Add more GeneralItem as needed
                      GeneralItem(
                        question: 'I forgot my password. What should I do?',
                        answer: 'If you forgot your password, you can use the'
                            ' "Forgot Password" feature on the login screen. '
                            'Follow the prompts to reset your password.',
                      ),
                      GeneralItem(
                        question: 'How can I contact support?',
                        answer: 'For support, please email us at '
                            'MyTeleClinic@UTeM.com.'
                            ' We will get back to you as soon as possible.',
                      ),
                    ],
                  ),
                ),
              );
            }, [
              GeneralItem(
                question: 'How do I create an account?',
                answer: 'To create an account, go to the Settings screen -> select "Create Account."',
              ),
            ]),


            general('About Us', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneralPage(
                    title: 'About Us',
                    generalItems: [
                      GeneralItem(
                        question: 'Our Story',
                        // You can include an Image widget along with text
                        answer: 'we are from Faculty of Information Technology'

                            '![Our Story Image](asset/MYTeleClinic.png)', // Replace with your image path
                      ),
                      // Add more GeneralItem as needed
                    ],
                  ),
                ),
              );
            }, [
              GeneralItem(
                question: 'How do I create an account?',
                answer: 'To create an account, go to the Settings screen -> select "Create Account."',
              ),
            ]),

            general('Terms and Condition', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneralPage(
                    title: 'Terms and condition',
                    generalItems: [
                      GeneralItem(
                        question: 'Our Story',
                        // You can include an Image widget along with text
                        answer: 'we are from Faculty of Information Technology'

                            '![Our Story Image](asset/MYTeleClinic.png)', // Replace with your image path
                      ),
                      // Add more GeneralItem as needed
                    ],
                  ),
                ),
              );
            }, [
              GeneralItem(
                question: 'How do I create an account?',
                answer: 'To create an account, go to the Settings screen -> select "Create Account."',
              ),
            ]),

            SizedBox(
              width: 260,
              height: 65,
              child: Padding(
                padding: const EdgeInsets.only(top: 17.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Log Out"),
                          content: Text("Are you sure you want to log out?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();


                                _logout();
                              },
                              child: Text("Log Out"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Color(hexColor('C73B3B')),
                  ),
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GeneralPage extends StatelessWidget {
  final String title;
  final List<GeneralItem> generalItems;

  const GeneralPage({
    required this.title,
    required this.generalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.blue,
        ),
        title: Center(
          child: Image.asset(
            "asset/MYTeleClinic.png",
            width: 594,
            height: 258,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 16.0),
              children: generalItems.map((item) => GeneralItemTile(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneralItemTile extends StatelessWidget {
  final GeneralItem generalItem;

  const GeneralItemTile(this.generalItem);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        generalItem.question,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            generalItem.answer,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class GeneralItem {
  final String question;
  final String answer;

  const GeneralItem({
    required this.question,
    required this.answer,
  });
}

class HelpCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.blue,
        ),
        title: Center(
          child: Image.asset(
            "asset/MYTeleClinic.png",
            width: 594,
            height: 258,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 10),
            child: Text(
              'Help Center',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 16.0),
              children: [
                FaqItem(
                  question: 'How do I create an account?',
                  answer: 'To create an account, go to the Settings screen ->'
                      ' select "Create Account.',
                ),
                FaqItem(
                  question: 'I forgot my password. What should I do?',
                  answer: 'If you forgot your password, you can use the'
                      ' "Forgot Password" feature on the login screen. '
                      'Follow the prompts to reset your password.',
                ),
                FaqItem(
                  question: 'How can I contact support?',
                  answer: 'For support, please email us at '
                      'MyTeleClinic@UTeM.com.'
                      ' We will get back to you as soon as possible.',
                ),
                // Add more FAQ items as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');

  int finalColor = int.parse(newColor);
  return finalColor;
}
