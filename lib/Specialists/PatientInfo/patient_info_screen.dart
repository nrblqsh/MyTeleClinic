import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/EMR/vital_info_report.dart';
import 'package:my_teleclinic/Specialists/PatientInfo/patient_vital_report.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Patients/EMR/current_vital.dart';


// void main() {
//   runApp(MedicalRecordScreen(patientID: 0 ));
// }

class PatientInfoScreen extends StatefulWidget {
  int patientID;

  PatientInfoScreen({required this.patientID});

  @override
  _PatientInfoScreenState createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState  extends State<PatientInfoScreen> {
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
      print('patient id dekat screen vital ${patientID}');
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
                patientID: patientID,
              ),
              PatientVitalReportScreen(
                //patientID: patientID,
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
