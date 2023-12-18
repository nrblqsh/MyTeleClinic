import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/consultation.dart';

class PatientConsultationHistory extends StatefulWidget {
  final int patientID;
  final int specialistID;

  PatientConsultationHistory({required this.patientID, required this.specialistID});
  @override
  _PatientConsultationHistoryState createState() => _PatientConsultationHistoryState();
}

class _PatientConsultationHistoryState extends State<PatientConsultationHistory> {
  late int patientID = 0;
  late int specialistID = 0;
  late String specialistName;
  late String logStatus;
  DateTime consultationDateTime = DateTime.now();
  String consultationStatus = '';
  String consultationSymptom = '';
  String consultationTreatment = '';
  late List<Consultation> todayConsultations = [];


  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<List<Consultation>> fetchConsultationByPatient(
      int specialistID, int patientID) async {
    Consultation consultation = Consultation(patientID: patientID,
        consultationTreatment: consultationTreatment,
        consultationSymptom: consultationSymptom,
        consultationStatus: consultationStatus,
        consultationDateTime: consultationDateTime,
        specialistID: specialistID,
        specialistName: specialistName);
    print(consultation.fetchConsultationByPatient(specialistID, patientID));
    return await consultation.fetchConsultationByPatient(specialistID, patientID);
  }


  Future<void> _loadDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      patientID = pref.getInt("patientID") ?? 0;
      specialistID = pref.getInt("specialistID") ?? 0;
      specialistName = pref.getString("specialistName") ?? '';
      logStatus = pref.getString("logStatus") ?? 'OFFLINE';
      print("testttt$specialistName");
      print(specialistID);
      print(patientID);
      print(logStatus);

      // Add createMenuScreen() after loading specialist details

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Consultation History',  // Add your test text here
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              child: FutureBuilder(
                future: fetchConsultationByPatient(specialistID, patientID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<Consultation>? consultations = snapshot.data as List<
                        Consultation>?;

                    if (consultations != null && consultations.isNotEmpty) {
                      return ListView.builder(
                        itemCount: consultations.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, index) {
                          Consultation consult = consultations[index];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                _showConsultationDetailsDialog(context, consult);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 700,
                                      height: 100,
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
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Text(
                                              'Date: ${DateFormat('dd/MM/yyyy')
                                                  .format(
                                                  consult.consultationDateTime)}\n'
                                                  'Time: ${DateFormat('hh:mm a')
                                                  .format(
                                                  consult.consultationDateTime)}\n'
                                                  'Status: ${consult
                                                  .consultationStatus}\n',
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
                      return Center(
                          child: Text('No history available'));
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

  void _showConsultationDetailsDialog(BuildContext context, Consultation consultation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Consultation Details'),
          contentPadding: EdgeInsets.all(10),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Date: ${DateFormat('dd/MM/yyyy').format(consultation.consultationDateTime)}'),
              Text('Time: ${DateFormat('hh:mm a').format(consultation.consultationDateTime)}'),
              Text('Symptom: ${consultation.consultationSymptom}'),
              Text('Treatment: ${consultation.consultationTreatment}'),
              // Add more details as needed
              SizedBox(height: 16), // Add some space between the details and buttons

            ],
          ),
        );
      },
    );
  }

}

