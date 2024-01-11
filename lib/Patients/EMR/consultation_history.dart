import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/consultation.dart';
import '../../Model/medication.dart';

class ConsultationHistory extends StatefulWidget {
  final int patientID;


  ConsultationHistory(
      {required this.patientID});

  @override
  _ConsultationHistoryState createState() =>
      _ConsultationHistoryState();
}

class _ConsultationHistoryState
    extends State<ConsultationHistory> {
  late int patientID = 0;
  String specialistName = '';
  //late String logStatus;
  DateTime consultationDateTime = DateTime.now();
  int specialistID=0;
  int consultationID=0;
  int medID = 0;
  int medicationID = 0;
  String consultationStatus = '';
  String consultationSymptom = '';
  String consultationTreatment = '';
  // String medGeneral = '';
  // String medForm = '';
 // late List<Consultation> todayConsultations = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }


  Future<void> _loadDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    print(" ni patient dia ${patientID}");
    setState(() {
      patientID = pref.getInt("patientID") ?? 0;
      //specialistID = pref.getInt("specialistID") ?? 0;
      //specialistName = pref.getString("specialistName") ?? '';
      //logStatus = pref.getString("logStatus") ?? 'OFFLINE';
      //print("testttt$specialistName");
      //print(specialistID);

      //print(logStatus);
      print(" ni patient dia ${patientID}");
      // Add createMenuScreen() after loading specialist details
    });
    print(" ni patient dia ${patientID}");
    print(" ni patient dia ${patientID}");
  }
  Future<List<Consultation>> fetchPatientConsultation(
       int patientID) async {
    Consultation consultation = Consultation(
      consultationID: consultationID  ,
      patientID: patientID,
      consultationTreatment: consultationTreatment,
      consultationSymptom: consultationSymptom,
      consultationStatus: consultationStatus,
      consultationDateTime: consultationDateTime,
      specialistID: specialistID,
      specialistName: specialistName,
    );
    print("patient id ${patientID}");
    print(consultation.fetchPatientConsultation(patientID));
    return await consultation.fetchPatientConsultation(patientID);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 68,
      //   backgroundColor: Colors.white,
      //   title: Center(
      //     child: Image.asset(
      //       "asset/MYTeleClinic.png",
      //       width: 594,
      //       height: 258,
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Align content to the left
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Consultation History', // Add your test text here
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              child: FutureBuilder(
                future: fetchPatientConsultation(patientID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<Consultation>? consultations =
                    snapshot.data as List<Consultation>?;
                    print ("data ${snapshot.data}");
                    if (consultations != null && consultations.isNotEmpty) {
                      return ListView.builder(
                        itemCount: consultations.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, index) {
                          Consultation consult = consultations[index];
                          return Card(
                            child: InkWell(
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 700,
                                      height: 130,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 12, right: 12, top: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueAccent),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12.0)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blueGrey,
                                              offset: const Offset(5.0, 5.0),
                                              blurRadius: 10.0,
                                              spreadRadius: 2.0,
                                            ),
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: const Offset(0.0, 0.0),
                                              blurRadius: 0.0,
                                              spreadRadius: 0.0,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Date: ${DateFormat('dd/MM/yyyy').format(consult.consultationDateTime)}\n'
                                                  'Time: ${DateFormat('hh:mm a').format(consult.consultationDateTime)}\n'
                                                 // 'Status: ${consult.consultationStatus}\n'
                                                  'Consultation Symptom: ${consult.consultationSymptom}\n'
                                                  'Consultation Treatment: ${consult.consultationTreatment}\n',
                                              style: TextStyle(
                                                fontSize: 14,
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
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('No history available'));
                    }
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// void _showConsultationMedicationDialog(BuildContext context, Medication medication) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Consultation Medication'),
//         contentPadding: EdgeInsets.all(10),
//         content: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Text('Date: ${DateFormat('dd/MM/yyyy').format(consultation.consultationDateTime)}'),
//             Text('Time: ${DateFormat('hh:mm a').format(consultation.consultationDateTime)}'),
//             Text('Symptom: ${consultation.consultationSymptom}'),
//             Text('Treatment: ${consultation.consultationTreatment}'),
//             // Add more details as needed
//             SizedBox(height: 16), // Add some space between the details and buttons
//
//           ],
//         ),
//       );
//     },
//   );
// }
}
