import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

//import 'package:my_teleclinic/Patients/Telemedicine/viewPatient.php.dart';
import 'package:my_teleclinic/Patients/patient_home.dart';
import 'package:my_teleclinic/Specialists/patient_consultation_history.dart';
import 'package:my_teleclinic/Specialists/patient_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/request_controller.dart';
import '../../changePassword1.dart';
import '../../Patients/patient_home.dart';
import '../Model/consultation.dart';
import '../Model/patient.dart';
import 'dart:convert';

import '../Patients/EMR/e_medical_record.dart';
import '../login.dart';

// void main() {
//   runApp( MaterialApp(
//     home: viewPatientScreen(specialistID: specialistID,),
//   ));
// }
// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

class viewPatientScreen extends StatefulWidget {
  viewPatientScreen({required int specialistID});

  @override
  _viewPatientScreenState createState() => _viewPatientScreenState();
}

// Future<List<Patient>> fetchPatient() async {
//   String url = 'http://192.168.0.116/teleclinic/viewPatient.php';
//   final response = await http.get(Uri.parse(url));
//   return patientFromJson(response.body);
// }

class _viewPatientScreenState extends State<viewPatientScreen> {
  late Map<int, String> patientNames = {};
  late int specialistID;

  @override
  void initState() {
    super.initState();
    _loadSpecialistDetails();
  }

  Future<void> _loadSpecialistDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      specialistID = pref.getInt("specialistID") ?? 0;
      print(specialistID);
    });
  }

  Future<List<Consultation>> fetchBySpecialist() async {
    print(specialistID);
    var url =
        'http://192.168.0.116/teleclinic/viewPatient.php?specialistID=$specialistID';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print(responseData);
      return responseData.map((data) => Consultation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch consultations');
    }
  }

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(
        dateTimeString); // Parse the string into a DateTime object
    return DateFormat('MMMM dd, yyyy')
        .format(dateTime); // Format the DateTime object
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
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 25, right: 100),
            child: Text(
              "Patient List ",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                textStyle: const TextStyle(fontSize: 28, color: Colors.black),
              ),
            ),
          ),
          Container(
            child: FutureBuilder(
              future: fetchBySpecialist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<Consultation>? consultations =
                      snapshot.data as List<Consultation>?;
                  if (consultations != null) {
                    return ListView.builder(
                      itemCount: consultations.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, index) {
                        Consultation consult = consultations[index];
                        return Card(
                          child: Container(
                            padding:
                                EdgeInsets.only(left: 15, right: 15, top: 10),
                            child: Column(children: [
                              SizedBox(
                                  width: 700,
                                  height: 70,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 12, right: 12, top: 10),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.blueAccent),
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
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          int patientID =
                                              int.parse('${consult.patientID}');
                                        });
                                        print(
                                            'Tapped on patient: ${consult.patientName}');
                                        showDialog(
                                          context: context,
                                          // Make sure you have access to the context
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              //backgroundColor: Colors.greenAccent
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),

                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    left: 12,
                                                    right: 12,
                                                    top: 10),
                                                height: 500,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.blueAccent),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              12.0)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.blueGrey,
                                                      offset: const Offset(
                                                          5.0, 5.0),
                                                      blurRadius: 10.0,
                                                      spreadRadius: 2.0,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      offset: const Offset(
                                                          0.0, 0.0),
                                                      blurRadius: 0.0,
                                                      spreadRadius: 0.0,
                                                    ),
                                                  ],
                                                ),
                                                //height: 1,
                                                child: Column(
                                                  // mainAxisAlignment:
                                                  //     MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20.0),
                                                      child: Image.network(
                                                        'https://static.thenounproject.com/png/516749-200.png',
                                                        width: 90,
                                                        height: 90,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 15.0),
                                                      child: Text(
                                                        '${consult.patientName}',
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      //
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Column(
                                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'IC Number:',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight
                                                                  .bold, // Optionally make the label bold
                                                            ),
                                                          ),
                                                          Text(
                                                            '${consult.icNum}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Column(
                                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Gender:',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight
                                                                  .bold, // Optionally make the label bold
                                                            ),
                                                          ),
                                                          Text(
                                                            '${consult.gender}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      child: Column(
                                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Birthdate:',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight
                                                                  .bold, // Optionally make the label bold
                                                            ),
                                                          ),
                                                          Text(
                                                            '${_formatDateTime(consult.birthDate.toString())}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10.0),
                                                      child: Column(
                                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Phone:',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight
                                                                  .bold, // Optionally make the label bold
                                                            ),
                                                          ),
                                                          Text(
                                                            '${consult.phone}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PatientInfoScreen(patientID: consult.patientID,)));
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors.red),
                                                      ),
                                                      child: Text(
                                                          "View Patient Vital Info"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PatientConsultationHistory(patientID: consult.patientID, specialistID: consult.specialistID,)));
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors.red),
                                                      ),
                                                      child: Text(
                                                          "View Consultation History"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        LoginScreen()));
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors.red),
                                                      ),
                                                      child:
                                                          Text("Consult Now!"),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          // Text(
                                          //   '${consult.patientID}',
                                          //   style: TextStyle(
                                          //     fontSize: 14,
                                          //   ),
                                          // ),
                                          Text(
                                            '${consult.patientName}',
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ]),
                          ),
                        );
                      },
                    );
                  } else {
                    return Text('No data available');
                  }
                } else {
                  return Text('No data available');
                }
              },
            ),
          )
        ])));
  }
}
