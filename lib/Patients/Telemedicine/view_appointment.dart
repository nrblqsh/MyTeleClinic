import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_teleclinic/Patients/Telemedicine/view_specialist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../Main/main.dart';
import '../../Model/consultation.dart';
import '../EMR/e_medical_record.dart';
import '../Profile/patient_home_page.dart';
import '../Profile/settings.dart';
import '/Model/specialist.dart';
import 'package:intl/intl.dart';


// void main() {
//   runApp(const MaterialApp(
//     home: ViewAppointmentScreen(),
//   ));
// }

class ViewAppointmentScreen extends StatefulWidget {
  final int patientID;

  //const ViewAppointmentScreen({Key? key}) : super(key: key);
  ViewAppointmentScreen({required this.patientID});
  @override
  _ViewAppointmentScreenState createState() => _ViewAppointmentScreenState();
}

class _ViewAppointmentScreenState extends State<ViewAppointmentScreen> {
  late int patientID;
  late Future<List<Consultation>> futureConsultations;


  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;

    setState(() {
      patientID = storedID;

    });
  }


  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString); // Parse the string into a DateTime object
    return DateFormat('dd MMMM yyyy - hh:mm a').format(dateTime); // Format the DateTime object
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    futureConsultations = fetchConsultations();
  }

  Future<List<Consultation>> fetchConsultations() async {
    final String url = 'http://${MyApp.ipAddress}/teleclinic/consultation.php'; // Modify the path accordingly
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

      // Convert response data to a list of Consultation objects
      List<Consultation> allConsultations = responseData
          .map((data) => Consultation.fromJson(data))
          .toList();

      // Filter consultations based on patientID
      List<Consultation> patientConsultations = allConsultations
          .where((consultation) => consultation.patientID == patientID)
          .toList();

      // Sort patientConsultations based on appointment date in descending order
     // patientConsultations.sort((a, b) => b.consultationDateTime.compareTo(a.consultationDateTime));

      return patientConsultations;
    } else {
      throw Exception('Failed to fetch consultations');
    }
  }


  Future<Specialist?> fetchSpecialistByID(String specialistID) async {
    final String url = 'http://${MyApp.ipAddress}/teleclinic/viewSpecialist.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print ('response data ${response.body}');
      return Specialist.fromJson(responseData);
    } else {
      throw Exception('Failed to fetch specialist details');
    }
  }

  Future<void> cancelAppointment(int consultationID, int patientID) async {
    final String url = 'http://${MyApp.ipAddress}/teleclinic/cancelAppointment.php?consultationID=$consultationID&patientID=$patientID';

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Appointment deleted successfully');
      // Reload the data after successful deletion
      setState(() {
        futureConsultations = fetchConsultations(); // Re-fetch the updated appointments
      });
    } else {
      print('Failed to delete appointment: ${response.statusCode}');
      // Handle error as needed
    }
  }


  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Decline':
        return Colors.red;
      case 'Pending':
      // Use your hexColor function here for the desired color
        return hexColor('FFC000');
      default:
        return Colors.transparent; // Default color
    }
  }

  Color hexColor(String color) {
    String newColor = '0xff' + color.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return Color(finalColor);
  }


  @override
  Widget build(BuildContext context) {
    int _currentIndex =3;
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
      body:
      FutureBuilder<List<Consultation>>(
        future: futureConsultations,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : snapshot.hasData
              ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'LIST APPOINTMENT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: (snapshot.data as List<Consultation>)
                        .map((consultation) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Appointment Details',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '${consultation.specialistName}',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  content: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Center(
                                        child: Text(
                                          '${_formatDateTime(consultation.consultationDateTime.toString())}',
                                          style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(25.0),
                                        child: Text(
                                          'Are you sure to cancel your appointment? You can set up another appointment later.',
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Center(
                                        child: Text(
                                          'Status: ${consultation.consultationStatus}',
                                        ),
                                      ),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: consultation.consultationDateTime.isAfter(DateTime.now()) &&
                                              consultation.consultationStatus != 'Declined'
                                              ? () async {
                                            if (consultation
                                                .consultationID !=
                                                null) {
                                              await cancelAppointment(
                                                consultation
                                                    .consultationID!,
                                                consultation
                                                    .patientID!,
                                              );
                                              Navigator.pop(
                                                  context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SuccessPage(patientID: patientID)),
                                              );
                                            } else {
                                              print(
                                                  'Consultation ID is null');
                                            }
                                          }
                                          : null, // Disable button if overdue
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            Colors.red,
                                          ),
                                          child: Text(
                                              'Cancel Appointment'),
                                        ),
                                      ),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ViewAppointmentScreen(patientID: patientID,)),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red, // Change the background color here
                                          ),
                                          child: Text('Back to view Appointment'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  '${_formatDateTime(consultation.consultationDateTime.toString())}',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Specialist Name: ${consultation.specialistName}',
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top:5.0),
                                      child: Container(
                                        height: 23,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: _getStatusColor(consultation.consultationStatus),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${consultation.consultationStatus}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          )
              : Center(
            child: Text('No appointments found'),
          );
        },
      ),
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ViewAppointmentScreen(patientID: patientID)));
          } else if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingsScreen(patientID: patientID,)));
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
}class SuccessPage extends StatelessWidget {

  final int patientID;

  SuccessPage({required this.patientID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success'),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "asset/success.png", // Replace with your image asset path
                width: 150, // Set the width of the image
                height: 150, // Set the height of the image
              ),
              SizedBox(height: 20),
              Text(
                'Successfully Cancel Appointment',
                style: TextStyle(fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.all(100.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen(patientID: patientID,)));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text("View Appoinment"),
                ),
              )
            ]
        ),
      ),
    );
  }
}