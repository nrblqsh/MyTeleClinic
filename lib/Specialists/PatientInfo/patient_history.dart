import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/EMR/vital_info_report.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Consultation/patient_consultation_history.dart';
import '../Consultation/patient_medication_history.dart';


// void main() {
//   runApp(MedicalRecordScreen(patientID: 0 ));
// }

class PatientHistoryScreen extends StatefulWidget {
  final int patientID;
  final int specialistID;

  PatientHistoryScreen({required this.patientID, required this.specialistID});

  @override
  _PatientHistoryScreenState createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  late int patientID=0;
  late int specialistID=0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      patientID = pref.getInt("patientID") ?? 0;
      specialistID = pref.getInt("specialistID") ?? 0;
      // Add createMenuScreen() after loading specialist details
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
                  text: 'Consultation History',
                ),
                CustomTab(
                  text: 'Medication History',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              PatientConsultationHistory(
                patientID: 0,
                specialistID: 0,
              ),
              PatientMedicationHistory(
                patientID: 0,
                specialistID: 0,
              ),
            ],
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
