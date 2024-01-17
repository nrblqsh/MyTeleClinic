import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Main/main.dart';
import '../../Model/consultation.dart';
import '../../Model/medication.dart';
import '../Map/view_clinic_specialist.dart';

class MedicationDetails extends StatefulWidget {
  final int consultationID;

  MedicationDetails({required this.consultationID});

  @override
  _MedicationDetailsState createState() => _MedicationDetailsState();
}

class _MedicationDetailsState extends State<MedicationDetails> {
  Consultation? consultation;
  late int storedConsultID;
  late int consultationID;
  late int patientID = 0;
  late int specialistID = 0;
  late String specialistName;
  late String logStatus;
  DateTime consultationDateTime = DateTime.now();
  int medID = 0;
  int medicationID = 0;
  String consultationStatus = '';
  String consultationSymptom = '';
  String consultationTreatment = '';
  String medGeneral = '';
  String medForm = '';
  String dosage = '';
  String medInstruction = '';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    storedConsultID = pref.getInt("consultationID") ?? 0;
    setState(() {
      consultationID = storedConsultID;

      //print(logStatus);
      print(" ni consult id dia ${consultationID}");
      // Add createMenuScreen() after loading specialist details
    });
    print(" ni consultationID ${consultationID}");
  }

  Future<List<Medication>> fetchPatientMedication(int consultationID) async {
    Medication med = Medication(
        consultationID: consultationID,
        medicationID: medicationID,
        medID: medID,
        medGeneral: medGeneral,
        medForm: medForm,
        consultationDateTime: consultationDateTime,
        dosage: dosage,
        medInstruction: medInstruction);
    print("consultation id ${consultationID}");
    print(med.fetchPatientMedication(consultationID));
    return await med.fetchPatientMedication(consultationID);
  }

  Future<Consultation?> generateConsultation(int consultationID) async {
    try {
      var url =
          'http://${MyApp.ipAddress}/teleclinic/selectedConsultation.php?consultationID=$consultationID';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var list = json.decode(response.body);
        print('Received Data: $list');

        List<Consultation> _consults = list
            .map<Consultation>((json) => Consultation.fromJson(json))
            .toList();

        if (_consults.isNotEmpty) {
          consultation = _consults.first;
          print('Parsed Data: $consultation');
          return consultation;
        } else {
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
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
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 25, right: 20),
                child: Text(
                  " Consultation Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.black,
                  ),
                ),
              ),
              FutureBuilder<Consultation?>(
                future: generateConsultation(consultationID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: 0.8,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.data == null) {
                    return Center(
                      child: Text('No data available'),
                    );
                  } else {
                    return Container(
                        width: double.infinity, // Make it full width
                        margin: EdgeInsets.all(5),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 70.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Symptom : ',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text:
                                            '${snapshot.data!.consultationSymptom} ',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Treatment :',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text:
                                            '${snapshot.data!.consultationTreatment}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ])));
                  }
                },
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'Medication Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: FutureBuilder<List<Medication>>(
                        future: fetchPatientMedication(consultationID),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<Medication> meds = snapshot.data!;

                            if (meds.isNotEmpty) {
                              return ListView.builder(
                                itemCount: meds.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, index) {
                                  Medication med = meds[index];
                                  return Card(
                                    child: InkWell(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15, top: 5),
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
                                                      offset:
                                                      const Offset(5.0, 5.0),
                                                      blurRadius: 10.0,
                                                      spreadRadius: 2.0,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      offset:
                                                      const Offset(0.0, 0.0),
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
                                                      'Medicine Name: ${med.medGeneral}\n'
                                                          'Medicine Type: ${med.medForm}\n'
                                                          'Medicine Dosage: ${med.dosage}\n'
                                                          'Medicine Instruction: ${med.medInstruction}\n',
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
            ])));
  }
}