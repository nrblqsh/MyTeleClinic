import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/EMR/vital_info_report.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Telemedicine/view_specialist.dart';
import '../Profile/patient_home_page.dart';
import '../Profile/settings.dart';
import 'add_vital_info.dart';
import 'current_vital.dart';

// void main() {
//   runApp(MedicalRecordScreen(patientID: 0 ));
// }

class MedicalRecordScreen extends StatefulWidget {
  final int patientID;

  MedicalRecordScreen({required this.patientID});

  @override
  _MedicalRecordScreenState createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  late int patientID;
  late String patientName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;
   // String storedName = prefs.getString("patientID") ?? "";

    setState(() {
      patientID = storedID;
     //patientName = widget.patientName;
      //print(patientID);
      //patientIDController.text = patientID.toString();
    });
  }

  //const MedicalRecordScreen({Key? key, required int patientID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 78,
            backgroundColor: Colors.white,
            title: Center(
              child: Image.asset(
                "asset/MYTeleClinic.png",
                width: 594,
                height: 258,
              ),
            ),
            bottom: TabBar(
              unselectedLabelColor: Colors.orangeAccent,
              labelColor: Colors.blueGrey,
              //
              indicatorColor: Colors.blueGrey,
              // Set the color for the selected label
              tabs: [
                CustomTab(
                  text: 'Current Vital Info',
                ),
                CustomTab(
                  text: 'Vital Info History',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              CurrentVitalInfoScreen(
                patientID: 0,
              ),
              VitalInfoReportScreen(
                patientID: 0,
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            //currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                //_currentIndex = index;
              });

              if (index == 0) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MedicalRecordScreen(patientID: patientID)));
              } else if (index == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => viewSpecialistScreen(patientID: patientID,)));
              } else if (index == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              patientID: patientID,
                              phone: '',
                              patientName: '',
                            )));
              } else if (index == 3) {
                // Add your navigation logic here
              } else if (index == 4) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsScreen(patientID: patientID,)));
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services),
                label: 'EMR',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety),
                label: 'TeleMedicine',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'View Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            backgroundColor: Colors.grey[700],
            selectedItemColor: Colors.blueGrey,
            unselectedItemColor: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class CustomTab extends StatelessWidget {
  //final Icon icon;

  final String text;

  CustomTab({required this.text});

  @override
  Widget build(BuildContext context) {
    return Tab(
      icon: Column(
        children: [
          const SizedBox(height: 20),
          Text(text),
        ],
      ),
    );
  }
}
