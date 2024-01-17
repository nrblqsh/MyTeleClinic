import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_teleclinic/Patients/Telemedicine/consultation_appointment.dart';
import 'package:my_teleclinic/Model/specialist.dart';
import 'package:my_teleclinic/Patients/Telemedicine/view_appointment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/request_controller.dart';
import '../../Model/consultation.dart';
import '../../Main/main.dart';
import '../EMR/e_medical_record.dart';
import '../Profile/patient_home_page.dart';
import '../Profile/settings.dart';

// void main() {
//   runApp(const MaterialApp(
//     home: viewSpecialistScreen(),
//   ));
// }

class viewSpecialistScreen extends StatefulWidget {
  final int patientID;

  viewSpecialistScreen({required this.patientID});

  //late int specialistID;
  // viewSpecialistScreen({
  //   required this.specialistID,
  //   // Other required properties
  // });
  // const viewSpecialistScreen({super.key});

  @override
  _viewSpecialistScreenState createState() => _viewSpecialistScreenState();
}

Future<List<Specialist>> fetchSpecialist() async {
  String url = 'http://${MyApp.ipAddress}/teleclinic/viewSpecialist.php';
  final response = await http.get(Uri.parse(url));
  return specialistFromJson(response.body);
}

class _viewSpecialistScreenState extends State<viewSpecialistScreen> {
  late int patientID=0;
  late int specialistID=0;
  late String phone;
  late String patientName;


  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool showConfirmation = false;

  @override
  void initState() {
    _loadData();
  }

  Future<void> _loadData() async {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   RequestController req = RequestController(
    //       path: "/api/timezone/Asia/Kuala_Lumpur",
    //       server:"http://worldtimeapi.org");
    //
    //   req.get().then((value) {
    //     dynamic res = req.result();
    //     selectedDate =
    //         DateTime.parse(res["datetime"].toString().substring(0,19).replaceAll('T',''));
    //   });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("specialistID", specialistID);
    patientID = prefs.getInt("patientID") ?? 0;
    // prefs.setInt("patientID", patientID);

    print ("specialistID ${specialistID}");
    print ("patientID ${patientID}");
  }

  // Future<void> _getData() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   specialistID = prefs.getInt("specialistID") ?? 0;
  //   patientID = prefs.getInt("patientID") ?? 0; // Correct variable name
  //   print("specialistID nak req $specialistID");
  //
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
  //     RequestController req = RequestController(
  //         path: "/api/timezone/Asia/Kuala_Lumpur",
  //         server: "http://worldtimeapi.org");
  //     req.get().then((value) {
  //       dynamic res = req.result();
  //       selectedDate = DateTime.parse(res["datetime"].toString().substring(0, 19).replaceAll('T', ''));
  //     });
  //   });
  // }

  static Future<String> getPathImg(int specialistID) async
  {
     String strUrl = "";
     RequestController req = RequestController(

       path: "/teleclinic/getSpecialistImagePatientSide.php",

     );
     return strUrl;
  }

  static Future<Uint8List?> getSpecialistImage1(int specialistID) async {

    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // int specialistID = prefs.getInt("specialistID") ?? 0;
    RequestController req = RequestController(

      path: "/teleclinic/getSpecialistImagePatientSide.php",

    );

    // Add specialistID as a query parameter
    req.path = "${req.path}?specialistID=$specialistID";

    try {
      // Make a GET request using RequestController
      await req.get();

      if (req.status() == 200) {
        // Image data is available in the response body


        return req.result();
      } else if (req.status() == 404) {
        // Image not found
        print('Image not found for specialistID: $specialistID');
        return null;
      } else {
        // Handle other status codes
        print('Failed to retrieve image. Status: ${req.status()}');
        return null;
      }
    } catch (error) {
      // Handle any exceptions that might occur during the request
      print('Error retrieving image: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 1;
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
      body: SingleChildScrollView(
          child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25, right: 100),
                  child: Text(
                    "Find your specialist ",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      textStyle: const TextStyle(fontSize: 28, color: Colors.black),
                    ),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
                  child: Text(
                    "Discover highly skilled healthcare experts for immediate "
                        "assistance with your health issues. Seek virtual consultations"
                        " with doctors through video calls or messaging ",
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 200, bottom: 10),
                  child: Text(
                    "Let's get started! ",
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),
                ),

                Container(
                  child: FutureBuilder(
                    future: fetchSpecialist(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        List<Specialist>? specialists =
                        snapshot.data as List<Specialist>?;
                        if (specialists != null) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                ListView.builder(
                                  itemCount: specialists.length,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, index) {
                                    Specialist specialist = specialists[index];

                                    specialistID =
                                        int.parse('${specialist.specialistID}');

                                    bool isSpecialistOnline =
                                        specialist.logStatus == 'ONLINE';
                                    return Card(
                                      child: GestureDetector(
                                        onTap: ()  {
                                          Specialist specialist = specialists[index];

                                          //  print('index-');
                                          // print(index);
                                          setState(()  {
                                            // final SharedPreferences prefs = await SharedPreferences.getInstance();
                                            //
                                            // print('Tapped on specialist: ${specialist.specialistID}');
                                            specialistID =
                                                int.parse('${specialist.specialistID}');
                                          });
                                          print(specialistID);

                                          _loadData();
                                          showDialog(
                                            context: context,
                                            // Make sure you have access to the context
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                //backgroundColor: Colors.greenAccent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(20))),

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
                                                  height: 400,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 20.0),
                                                        child: FutureBuilder(
                                                          future: getSpecialistImage1(specialistID),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                                              return CircularProgressIndicator();
                                                            } else if (snapshot.hasError) {
                                                              return Text('Error: ${snapshot.error}');
                                                            } else if (snapshot.hasData) {
                                                              Uint8List? specialistImage = snapshot.data as Uint8List?;
                                                              if (specialistImage != null && specialistImage.isNotEmpty) {
                                                                return Container(
                                                                  width: 90,
                                                                  height: 90,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors.grey.withOpacity(0.5),
                                                                        spreadRadius: 2,
                                                                        blurRadius: 5,
                                                                        offset: Offset(0, 3),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Image.network
                                                                    (
                                                                    "http://10.131.77.121/teleclinic/getSpecialistImagePatientSide.php?specialistID=${specialist.specialistID}}",
                                                                    width: 90,
                                                                    height: 90,
                                                                    fit: BoxFit.fill,
                                                                  ),
                                                                );
                                                              } else {
                                                                // Return an empty Container with an image asset as a placeholder
                                                                return Container(
                                                                  width: 90,
                                                                  height: 90,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                    image: DecorationImage(
                                                                      image: AssetImage('asset/default image.jpg'), // Replace with your actual image asset path
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            } else {
                                                              // Return an empty Container with an image asset as a placeholder
                                                              return Container(
                                                                width: 90,
                                                                height: 90,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  image: DecorationImage(
                                                                    image: AssetImage('asset/default image.jpg'), // Replace with your actual image asset path
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            bottom: 5.0),
                                                        child: Text(
                                                          '${specialist.specialistName}',
                                                          style: TextStyle(fontSize: 20),
                                                        ),
                                                        //
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            bottom: 15.0),
                                                        child: Text(
                                                          '${specialist.specialistTitle}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            right: 4, left: 4, bottom: 40.0),
                                                        child: Text(
                                                          'You will need to wait for atleast 15 minutes'
                                                              ' before specialist approve your request.'
                                                              ' \nAre you sure to proceed your consultation request?',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      if (_buildOnlineIndicator(
                                                          isSpecialistOnline) !=
                                                          null)
                                                        ElevatedButton(
                                                          onPressed: isSpecialistOnline
                                                              ? () async {
                                                            //_getData();
                                                            //print('SPECIALIST REQUEST >> ${specialistID}');
                                                            // Create a new Booking instance with the selected data
                                                            Consultation consult =
                                                            Consultation(
                                                              patientID: patientID,
                                                              specialistID:
                                                              int.parse(specialist.specialistID),
                                                              consultationDateTime:
                                                              selectedDate,
                                                              consultationStatus:
                                                              'Pending',
                                                              consultationTreatment: '',
                                                              consultationSymptom: '',
                                                            );
                                                            bool success =
                                                            await consult.save();

                                                            // Show the confirmation container only if the booking is successful
                                                            if (success) {
                                                              setState(() {
                                                                showConfirmation = true;
                                                              });
                                                            }

                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      SuccessRequestScreen(),
                                                                ));
                                                          }
                                                              : null,
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                            MaterialStateProperty.all<
                                                                Color>(
                                                              isSpecialistOnline
                                                                  ? Colors.red
                                                                  : Colors.grey,
                                                            ),
                                                          ),
                                                          child: Text(
                                                              "Request Consultation Now"),
                                                        ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    AppointmentScreen(
                                                                      patientID: 0,
                                                                      specialistID: specialistID,
                                                                    ),
                                                              ));
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                          MaterialStateProperty.all<
                                                              Color>(Colors.red),
                                                        ),
                                                        child: Text("Book For Later"),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },


                                        child: Card(
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
                                                      child:  Row(
                                                        children: [
                                                          Flexible(
                                                            child: FutureBuilder(
                                                              future: getSpecialistImage1(specialistID),
                                                              builder: (context, snapshot) {
                                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                                  return CircularProgressIndicator();
                                                                } else if (snapshot.hasError) {
                                                                  return Text('Error: ${snapshot.error}');
                                                                } else if (snapshot.hasData) {
                                                                  Uint8List? specialistImage = snapshot.data as Uint8List?;
                                                                  if (specialistImage != null && specialistImage.isNotEmpty) {
                                                                    return Column(
                                                                      children: [
                                                                        Container(
                                                                          width: 50,
                                                                          height: 50,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: Colors.grey.withOpacity(0.5),
                                                                                spreadRadius: 2,
                                                                                blurRadius: 5,
                                                                                offset: Offset(0, 3),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                          Image.network
                                                                            (
                                                                            "http://10.131.77.121/teleclinic/getSpecialistImagePatientSide.php?specialistID=${specialist.specialistID}}",
                                                                            width: 90,
                                                                            height: 90,
                                                                            fit: BoxFit.fill,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  } else {
                                                                    // Return an empty Container with an image asset as a placeholder
                                                                    return Container(
                                                                      width: 60,
                                                                      height: 50,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(10.0),
                                                                        image: DecorationImage(
                                                                          image: AssetImage('asset/default image.jpg'), // Replace with your actual image asset path
                                                                          fit: BoxFit.fill,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                } else {
                                                                  // Return an empty Container with an image asset as a placeholder
                                                                  return Container(
                                                                    width: 60,
                                                                    height: 50,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(10.0),
                                                                      image: DecorationImage(
                                                                        image: AssetImage('asset/default image.jpg'), // Replace with your actual image asset path
                                                                        fit: BoxFit.fill,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(width: 10,),
                                                          Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    '${specialist.specialistName}',
                                                                    style: TextStyle(
                                                                      fontSize: 20,
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 5),
                                                                  _buildOnlineIndicator(
                                                                      isSpecialistOnline),
                                                                ],
                                                              ),
                                                              Text(
                                                                '${specialist.specialistTitle}',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
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


              ])),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MedicalRecordScreen(patientID: patientID)));
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => viewSpecialistScreen(
                      patientID: patientID,
                    )));
          } else if (index == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                      patientID: patientID,
                      phone: '',
                      patientName: '',
                    )));
          } else if (index == 3) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewAppointmentScreen(
                      patientID: patientID,
                    )));
            // Add your navigation logic here
          } else if (index == 4) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      patientID: patientID,
                    )));
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'EMR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'TeleMedicine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'View Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        backgroundColor: Colors.grey[700],
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  buildListView(

      ) {

  }

// Future<void> _loadData() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   //Specialist specialist = specialists[index];
//   int storedID = prefs.getInt("patientID") ?? 0;
//
//   setState(() {
//     patientID = storedID;
//   });
// }
}

class SuccessRequestScreen extends StatefulWidget {
  const SuccessRequestScreen({super.key});

  @override
  State<SuccessRequestScreen> createState() => _SuccessRequestState();
}

Widget _buildOnlineIndicator(bool isOnline) {
  Color indicatorColor = isOnline ? Colors.green : Colors.red;
  return Container(
    width: 10,
    height: 10,
    margin: EdgeInsets.only(left: 5),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: indicatorColor,
    ),
  );
}

class _SuccessRequestState extends State<SuccessRequestScreen> {
  late String phone=''; // To store the retrieved phone number
  late String patientName='';
  late int patientID=0;
  late int specialistID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 9.0, top: 150),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'asset/done1.png',
                          width: 120,
                          height: 120,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 40,
                        ),
                        child: SizedBox(width: 10),
                      ),
                      Text(
                        "Request successfully sent!",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(
                                phone: phone,
                                patientName: patientName,
                                patientID: patientID),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Adjust the radius as needed
                      ),
                      backgroundColor: Color(hexColor(
                          '#024362')), // Set your preferred background color
                    ),
                    child: Text(
                      'Back to Homepage',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }
}