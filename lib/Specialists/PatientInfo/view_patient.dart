import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_teleclinic/Specialists/Consultation/patient_consultation_history.dart';
import 'package:my_teleclinic/Specialists/PatientInfo/patient_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/consultation.dart';
import '../../Main/main.dart';

class viewPatientScreen extends StatefulWidget {
  viewPatientScreen({required int specialistID});

  @override
  _viewPatientScreenState createState() => _viewPatientScreenState();
}

class _viewPatientScreenState extends State<viewPatientScreen> {
  Consultation? selectedPatient;
  int selectedPatientID = 0;
  List<String> suggestions = [];
  final TextEditingController _searchController = TextEditingController();
  late int patientID =0;
  late int specialistID;
  String query = '';

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

  void loadPatient()async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      patientID = pref.getInt("patientID") ?? 0;
      print("ni patientID$patientID");
    });
  }



  Future<List<Consultation>> fetchBySpecialist() async {
    print(specialistID);
    var url =
        'http://${MyApp.ipAddress}/teleclinic/viewPatient.php?specialistID=$specialistID';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print(responseData);
      return responseData.map((data) => Consultation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch consultations');
    }
  }

  Future<void> searchPatients(String query) async {
    print(specialistID);

    final response = await http.get(
      Uri.parse('http://${MyApp.ipAddress}/teleclinic/searchPatient.php/suggestions?q=$query&specialistID=$specialistID'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('ni data $data');

      final int patientIDFromSuggestion = data[0]['patientID'];
      final Map<String, dynamic> patientData = data[0];

      setState(() {
       // consult = data ;
        //selectedPatientID = patientIDFromSuggestion;
       // selectedPatient = selectedPatient;
        selectedPatient = Consultation.fromJson(patientData);
        print ('dia pilih patient ni ${selectedPatient!.patientName}');

      });

    } else {
      print('Failed to fetch search results');
    }
  }


  Future<void> updateSuggestions(String query) async {
    final response = await http.get(
      Uri.parse('http://${MyApp.ipAddress}/teleclinic/searchPatient.php/suggestions?q=$query&specialistID=$specialistID'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<String> patientNames = data.map<String>((dynamic item) {
        return item['patientName'] as String;
      }).toList();

      setState(() {
        suggestions = patientNames;
        print('suggest $suggestions');
      });

      print('nama patient kauu $patientNames');
      print('suggest $suggestions');
    } else {
      print('Failed to fetch search suggestions');
    }
  }

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25, right: 100),
            child: Row(
              children: [
                Text(
                  "Patient List ",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 28, color: Colors.black),
                  ),
                ),

              ],
            ),
          ),
          Container(
            height: 50,
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                updateSuggestions(query);
              },
              decoration: InputDecoration(
                hintText: 'Search Patient..',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                fillColor: Colors.white70,
                filled: true,
                hintStyle: TextStyle(
                  color: Colors.black54,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    suggestions.clear();
                    // Optionally, you can also clear suggestions or perform any other action.
                  },
                ),
              ),
            ),
          ),


          if (suggestions.isNotEmpty)
            Expanded(
              child: Card(
                elevation: 5,
                child: ListView(
                  children: [
                    for (String suggestion in suggestions)
                      ListTile(
                        title: Text(suggestion),
                        onTap: () async {
                          // You can add logic to handle suggestion selection
                          _searchController.text = suggestion;
                          await searchPatients(suggestion);
                          setState(() {
                             patientID = int.parse('${selectedPatient!.patientID}');
                             print('sekarang dia pilih ${patientID}');

                          });
                          final SharedPreferences pref = await SharedPreferences.getInstance();
                          await pref.setInt("patientID", patientID);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(left: 12, right: 12, top: 10),
                                  height: 500,
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
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 20.0),
                                        child: Image.network(
                                          'https://static.thenounproject.com/png/516749-200.png',
                                          width: 90,
                                          height: 90,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 15.0),
                                        child: Text(
                                          '${selectedPatient!.patientName}',
                                          style: TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'IC Number:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${selectedPatient!.icNum}',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Gender:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${selectedPatient!.gender}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Birthdate:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_formatDateTime(selectedPatient!.birthDate.toString())}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Phone:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${selectedPatient!.phone}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                      // Add other details...

                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PatientInfoScreen(
                                                patientID: selectedPatient!.patientID,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                        ),
                                        child: Text("View Patient Vital Info"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PatientConsultationHistory(
                                                patientID: selectedPatient!.patientID,
                                                specialistID: selectedPatient!.specialistID,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                        ),
                                        child: Text("View Consultation History"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: FutureBuilder(
                future: selectedPatientID == 0
                    ? fetchBySpecialist()
                    : fetchPatientDetails(selectedPatientID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    List<Consultation>? consultations = snapshot.data as List<Consultation>?;
                    if (consultations != null) {
                      return ListView.builder(
                        itemCount: consultations.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, index) {
                          Consultation consult = consultations[index];
                          return Card(
                            child: Container(
                              padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 700,
                                    height: 70,
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
                                      child: GestureDetector(
                                        onTap: ()  async {
                                          setState(()  {
                                            int patientID = int.parse('${consult.patientID}');
                                          });
                                          final SharedPreferences pref = await SharedPreferences.getInstance();
                                          await pref.setInt("patientID", consult.patientID);
                                          print('Tapped on patient: ${consult.patientName}');

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.only(left: 12, right: 12, top: 10),
                                                  height: 500,
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
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 20.0),
                                                        child: Image.network(
                                                          'https://static.thenounproject.com/png/516749-200.png',
                                                          width: 90,
                                                          height: 90,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 15.0),
                                                        child: Text(
                                                          '${consult.patientName}',
                                                          style: TextStyle(fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 10.0),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              'IC Number:',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
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
                                                        padding: const EdgeInsets.only(bottom: 10.0),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              'Gender:',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
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
                                                        padding: const EdgeInsets.only(bottom: 10.0),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              'Birthdate:',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
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
                                                        padding: const EdgeInsets.only(bottom: 10.0),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              'Phone:',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
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
                                                              builder: (context) => PatientInfoScreen(
                                                                patientID: consult.patientID,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                        ),
                                                        child: Text("View Patient Vital Info"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => PatientConsultationHistory(
                                                                patientID: consult.patientID,
                                                                specialistID: consult.specialistID,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                        ),
                                                        child: Text("View Consultation History"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              '${consult.patientName}',
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Consultation>> fetchPatientDetails(int patientID) async {

    var url = 'http://${MyApp.ipAddress}/teleclinic/viewPatient.php?specialistID=$specialistID&patientID=$patientID';
    print ('url ${url}');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => Consultation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch patient details');
    }
  }
}
