import 'package:flutter/material.dart';
import 'package:my_teleclinic/Specialists/viewUpcomingAppointment.dart';
import 'package:my_teleclinic/Specialists/view_patient.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/consultation.dart';
import '../Patients/Telemedicine/view_appointment.dart';
import '../Patients/settings.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

void main() {
  runApp(const MaterialApp(
    home: SpecialistHomeScreen(),
  ));
}

class SpecialistHomeScreen extends StatefulWidget {
  const SpecialistHomeScreen({Key? key}) : super(key: key);

  @override
  _SpecialistHomeScreenState createState() => _SpecialistHomeScreenState();
}

class _SpecialistHomeScreenState extends State<SpecialistHomeScreen> {
  int _currentIndex = 2;
  late int specialistID;
  late String specialistName;
  late String logStatus;
  DateTime consultationDateTime = DateTime.now();
  int patientID = 0;
  String consultationStatus = '';
  String consultationSymptom = '';
  String consultationTreatment = '';
  late List<Widget> _pages = [];
  late List<Consultation> todayConsultations = [];

  @override
  void initState() {
    super.initState();
    _loadSpecialistDetails();
  }

  Future<void> _loadSpecialistDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      specialistID = pref.getInt("specialistID") ?? 0;
      specialistName = pref.getString("specialistName") ?? '';
      logStatus = pref.getString("logStatus") ?? 'OFFLINE';

    });
    await _fetchTodayConsultations();
    _createPages();
  }

  Future<void> _fetchTodayConsultations() async {
    try {
      final List<Consultation> fetchedConsultations = await Consultation(
        specialistID: specialistID,
        consultationDateTime: consultationDateTime,
        consultationStatus: consultationStatus,
        consultationSymptom: consultationSymptom,
        consultationTreatment: consultationTreatment,
        patientID: patientID,
      ).fetchTodayConsultations(specialistID);

      setState(() {
        todayConsultations = fetchedConsultations;
      });

      print('Today\'s Consultations:');
      if (todayConsultations.isNotEmpty) {
        for (Consultation consultation in todayConsultations) {
          print(consultation.patientName);
          print('Consultation ID: ${consultation.consultationID}');
          print('Patient ID: ${consultation.patientID}');
          print('Consultation Date and Time: ${consultation.consultationDateTime}');
          print('Consultation Status: ${consultation.consultationStatus}');
          print('Consultation Symptom: ${consultation.consultationSymptom}');
          print('Consultation Treatment: ${consultation.consultationTreatment}');
          print('Specialist ID: ${consultation.specialistID}');
          print('------------------------');
        }
      } else {
        print('No consultations for today.');
      }
    } catch (e) {
      print('Error fetching today\'s consultations: $e');
    }
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _createPages() {
    setState(() {
      _pages = [
        viewPatientScreen(specialistID: specialistID), // index 0
        SettingsScreen(patientID: 0), // should be in last
        createMenuScreen(
          todayConsultations: todayConsultations,
          navigateToPage: _navigateToPage,
        ),
        ViewUpcomingAppointment(), // Pass the consultations
      ];
    });
  }

  MenuScreen createMenuScreen({
    required List<Consultation> todayConsultations,
    required Function(int) navigateToPage,
  }) {
    return MenuScreen(
      specialistName: specialistName,
      logStatus: logStatus,
      specialistID: specialistID,
      todayConsultations: todayConsultations,
      fetchTodayConsultations: _fetchTodayConsultations,
      navigateToPage: navigateToPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          _navigateToPage(index);
        },
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt),
          label: 'Patient List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Schedule List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
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
    );
  }
}

class MenuScreen extends StatefulWidget {
  final int specialistID;
  final String specialistName;
  final String logStatus;
  int? patientID;
  final List<Consultation> todayConsultations;
  final Future<void> Function() fetchTodayConsultations;
  final Function(int) navigateToPage;

  MenuScreen({
    required this.specialistName,
    required this.logStatus,
    required this.specialistID,
    required this.todayConsultations,
    required this.fetchTodayConsultations,
    required this.navigateToPage,
    this.patientID,
  });

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    "${widget.specialistName},",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      textStyle: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.star,
                    size: 24,
                    color: Colors.red,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 180,
                width: 380,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 25, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: customIconWithLabel(
                              Icons.people_alt, 30, Colors.white, 'View Patient'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    viewPatientScreen(specialistID: widget.specialistID),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: customIconWithLabel(
                              Icons.assignment_outlined, 30, Colors.white, 'Consultation\nHistory'),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => viewPatientScreen(
                                  specialistID: widget.specialistID,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: customIconWithLabel(
                              Icons.calendar_month, 30, Colors.white, 'Upcoming\nAppointment'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewUpcomingAppointment(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Today's Appointment",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
              Container(
                height: 400,
                color: Colors.grey[200],
                padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    SizedBox(
                      width: 700,
                      height: 350,
                      child: Container(
                        padding: EdgeInsets.only(left: 12, right: 12, top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                        child: FutureBuilder<void>(
                          future: widget.fetchTodayConsultations(),
                          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Display a loading indicator while fetching data
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              // Data has been successfully fetched, build the ListView
                              return ListView.builder(
                                itemCount: widget.todayConsultations.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, index) {
                                  Consultation consult = widget.todayConsultations[index];
                                  return Card(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${consult.patientName}\n'

                                                    'Date: ${DateFormat('dd/MM/yyyy').format(consult.consultationDateTime)}\n'
                                                    'Time: ${DateFormat(' hh:mm a').format(consult.consultationDateTime)}\n'

                                                    'Status: ${consult.consultationStatus}\n',
                                              ),
                                            ],
                                          ),
                                          if (consult.consultationStatus != 'ACCEPTED')  // Show icon only if status is not 'ACCEPTED'
                                            Container(
                                              child: IconButton(
                                                icon: Icon(Icons.done),
                                                onPressed: () async {
                                                  try {
                                                    int consultationID = consult.consultationID ?? 0;
                                                    String newStatus = 'ACCEPTED';

                                                    final response = await http.get(Uri.parse(
                                                      'http://${MyApp.ipAddress}/teleclinic/updateConsultationStatus.php?consultationID=$consultationID&updateConsultationStatus=$newStatus',
                                                    ));

                                                    if (response.statusCode == 200) {
                                                      print('Status updated successfully');
                                                      await Future.delayed(Duration(seconds: 1)); // Add a delay of 1 second (adjust as needed)
                                                      await widget.fetchTodayConsultations();
                                                      widget.navigateToPage(3);
                                                      setState(() {});
                                                    } else {
                                                      print('Failed to update status. Status Code: ${response.statusCode}');
                                                    }
                                                  } catch (e) {
                                                    print('Error updating status: $e');
                                                  }
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );

                            }
                          },
                        )

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customIconWithLabel(
      IconData icon, double size, Color iconColor, String label) {
    int bgColor = hexColor('A34040');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(bgColor),
            ),
            child: Icon(
              icon,
              size: size,
              color: iconColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            maxLines: null,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
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
