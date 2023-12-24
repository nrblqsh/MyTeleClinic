import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:my_teleclinic/Model/vital_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Telemedicine/view_appointment.dart';
import '../Telemedicine/view_specialist.dart';
import '../patient_home_page.dart';
import '../settings.dart';
import 'add_vital_info.dart';
import 'e_medical_record.dart';

class CurrentVitalInfoScreen extends StatefulWidget {
  final int patientID;
  CurrentVitalInfoScreen({required this.patientID});

  @override
  _CurrentVitalInfoScreenState createState() => _CurrentVitalInfoScreenState();
}

class _CurrentVitalInfoScreenState extends State<CurrentVitalInfoScreen> {
  late int patientID;
  late String patientName;
  late VitalInfo vitalInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;
    String storedName = prefs.getString("patientName") ??"" ;

    setState(() {
      patientID = storedID;
      patientName = storedName;
      print(patientID);
      print(patientName);
      //patientIDController.text = patientID.toString();
    });
  }

  Future<VitalInfo?> generateVitalInfo() async {
    try {
      var url =
          'http://192.168.0.116/teleclinic/currentVitalInfo.php?patientID=$patientID';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var list = json.decode(response.body);
        print('Received Data: $list');

        List<VitalInfo> _vitalInfos = list
            .map<VitalInfo>((json) => VitalInfo.fromJson(json))
            .toList();

        if (_vitalInfos.isNotEmpty) {
          vitalInfo = _vitalInfos.first;
          print('Parsed Data: $vitalInfo');
          return vitalInfo;
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
    int _currentIndex = 0;
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 98,
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
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, right: 20),
              child: Text(
                " Current Vital Info Record ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
            ),

            ListTile(
              title: Padding(
                padding: EdgeInsets.only(top: 40, bottom: 30),
                child: Image.asset(
                  "asset/news.png",
                  width: 294,
                  height: 88,
                ),
              ),
            ),
            FutureBuilder<VitalInfo?>(
              future: generateVitalInfo(),
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
                                text: 'Weight: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.weight} kg',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Height: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.height} cm',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Waist Circumference: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.waistCircumference} cm',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Blood Pressure: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.bloodPressure} mmHg',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Blood Glucose: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.bloodGlucose} mg/dl',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Heart Rate: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.heartRate} bpm',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// class VitalInfo {
//   int infoID;
//   double weight;
//   double height;
//   double waistCircumference;
//   double bloodPressure;
//   double bloodGlucose;
//   double heartRate;
//   String latestDate;
//   int patientID;
//
//   VitalInfo({
//     required this.weight,
//     required this.height,
//     required this.bloodPressure,
//     required this.bloodGlucose,
//     required this.heartRate,
//     required this.waistCircumference,
//     required this.latestDate,
//     required this.patientID,
//     required this.infoID,
//   });
//
//   factory VitalInfo.fromJson(Map<String, dynamic> json) {
//     return VitalInfo(
//       infoID: int.parse(json['infoID'].toString()),
//       weight: double.parse(json['weight'].toString()),
//       height: double.parse(json['height'].toString()),
//       bloodPressure: double.parse(json['bloodPressure'].toString()),
//       bloodGlucose: double.parse(json['bloodGlucose'].toString()),
//       heartRate: double.parse(json['heartRate'].toString()),
//       waistCircumference:
//       double.parse(json['waistCircumference'].toString()),
//       latestDate: json['latestDate'],
//       patientID: int.parse(json['patientID'].toString()),
//     );
//   }
// }
