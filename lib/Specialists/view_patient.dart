import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:my_teleclinic/Patients/Telemedicine/viewPatient.php.dart';
import 'package:my_teleclinic/Patients/patient_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/request_controller.dart';
import '../../changePassword1.dart';
import '../../Patients/patient_home.dart';
import '../Model/patient.dart';
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: viewPatientScreen(),
  ));
}
// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);



List<Patient> patientFromJson(String str) => List<Patient>.from(json.decode(str).map((x) => Patient.fromJson(x)));
 String patientToJson(List<Patient> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Patient {
  String patientID;
  String patientName;

  Patient({
    required this.patientID,
    required this.patientName,

  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    patientID: json["patientID"],
    patientName: json["patientName"],

  );

  Map<String, dynamic> toJson() => {
   // "patientID": patientID,
    "patientName": patientName,
  };
}


class viewPatientScreen extends StatefulWidget {
  const viewPatientScreen({super.key});

  @override
  _viewPatientScreenState createState() => _viewPatientScreenState();


}

Future<List<Patient>> fetchPatient() async {
  String url = 'http://10.131.74.150/teleclinic/viewPatient.php';
  final response = await http.get(Uri.parse(url));
  return patientFromJson(response.body);
}

class _viewPatientScreenState extends State<viewPatientScreen> {
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
                  future: fetchPatient(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      List<Patient>? patients =
                      snapshot.data as List<Patient>?;
                      if (patients != null) {
                        return ListView.builder(
                          itemCount: patients.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, index) {
                            Patient patient = patients[index];
                            return Card(
                                child: Container(
                                  padding:
                                  EdgeInsets.only(left: 15, right: 15, top: 10),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 700,
                                        height: 70,
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
                                                '${patient.patientID}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '${patient.patientName}',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),


                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
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
