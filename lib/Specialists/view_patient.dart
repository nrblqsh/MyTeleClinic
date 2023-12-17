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
import '../Model/consultation.dart';
import '../Model/patient.dart';
import 'dart:convert';

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
    print (specialistID);
    var url = 'http://192.168.0.116/teleclinic/viewPatient.php?specialistID=$specialistID';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print (responseData);
      return responseData.map((data) => Consultation.fromJson(data)).toList();
    }
    else {
      throw Exception('Failed to fetch consultations');
    }
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
                      if ( consultations != null) {
                        return ListView.builder(
                          itemCount:  consultations.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, index) {
                            Consultation consult =  consultations[index];
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
