import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/consultation.dart';
import '../../Model/medication.dart';
import '../Map/view_clinic_specialist.dart';
import 'medication_details.dart';

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Consultation History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              child: FutureBuilder<List<Consultation>>(
                future: fetchPatientConsultation(patientID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<Consultation> consultations = snapshot.data!;

                    if (consultations.isNotEmpty) {
                      return ListView.builder(
                        itemCount: consultations.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, index) {
                          Consultation consult = consultations[index];
                          return Card(
                            child: GestureDetector(
                              onTap: () async {
                                Consultation consult = consultations[index];
                                final int selectedConsultationID = int.parse('${consult.consultationID}');
                                print('consult id tapped - $selectedConsultationID');

                                final SharedPreferences pref = await SharedPreferences.getInstance();
                                await pref.setInt("consultationID", selectedConsultationID);
                                print('consult id dalam shared pref - $selectedConsultationID');
                                // setState(() {
                                //   // If you have any synchronous state updates, you can put them here
                                //   // For example: someSynchronousVariable = newValue;
                                // });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedicationDetails(consultationID: selectedConsultationID),
                                  ),
                                );
                              },

                              child: InkWell(
                                child: Container(
                                  padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 700,
                                        height: 90,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 12, right: 12, top: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blueAccent),
                                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Date: ${DateFormat('dd/MM/yyyy').format(consult.consultationDateTime)}\n'
                                                    'Time: ${DateFormat('hh:mm a').format(consult.consultationDateTime)}\n'
                                                    'Specialist: ${consult.specialistName}\n',
                                                //'Consultation Treatment: ${consult.consultationTreatment}\n',
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