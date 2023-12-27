import 'dart:core';
import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/Profile/patient_home_page.dart';
import 'package:my_teleclinic/Main/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Patients/EMR/e_medical_record.dart';
import '../../Patients/Telemedicine/view_appointment.dart';
import '../../Patients/Telemedicine/view_specialist.dart';
import '../../Patients/Profile/editProfile.dart';
import '../../Patients/Profile/editProfile1.dart';
import '../../Main/changePassword1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Main/main.dart';


class SettingsSpecialistScreen extends StatefulWidget {
  final int specialistID;

  SettingsSpecialistScreen({required this.specialistID});
  @override
  State<SettingsSpecialistScreen> createState() => _SettingsSpecialistScreenState();
}

class _SettingsSpecialistScreenState extends State<SettingsSpecialistScreen> {

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
    _loadData();
  }

  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedSpecialistID = prefs.getInt("specialistID") ?? 0;
    String storedPhone = prefs.getString("phone") ?? "";

    setState(() {
      print(storedSpecialistID);
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
    return GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
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
                  IconButton(
                    icon: Icon(Icons.navigate_next_outlined),
                    color: Colors.grey,
                    onPressed: onTap,
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
      ),
    );
  }

  Widget general(String label, VoidCallback onTap, List<GeneralItem> generalItems) {
    return GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
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
                  IconButton(
                    icon: Icon(Icons.navigate_next_outlined),
                    color: Colors.grey,
                    onPressed: onTap,
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
      ),
    );
  }

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage("asset/logo.png"),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "test",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                MaterialPageRoute(builder: (context) => EditProfile1()),
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
