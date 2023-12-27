import 'package:flutter/material.dart';
import 'package:my_teleclinic/Specialists/Consultation/patient_consultation_history.dart';
import 'package:my_teleclinic/Specialists/Profile/settingSpecialist.dart';
import 'package:my_teleclinic/Specialists/Consultation/specialist_consultation_history.dart';
import 'package:my_teleclinic/Specialists/Consultation/viewUpcomingAppointment.dart';
import 'package:my_teleclinic/Specialists/PatientInfo/view_patient.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/consultation.dart';
import '../../Patients/Telemedicine/view_appointment.dart';
import '../../Patients/Profile/settings.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';


//import '../../VideoCall/videocall_page.dart';
import '../../Main/main.dart';
import '../../VideoConsultation/videocall_page.dart';

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

  Future<List<Consultation>> _fetchTodayConsultations() async {
    try {
      final List<Consultation> fetchedConsultations =
      await Consultation(
        specialistID: specialistID,
        consultationDateTime: consultationDateTime,
        consultationStatus: consultationStatus,
        consultationSymptom: consultationSymptom,
        consultationTreatment: consultationTreatment,
        patientID: patientID,
      ).fetchTodayConsultations(specialistID);

      return fetchedConsultations;
    } catch (e) {
      print('Error fetching today\'s consultations: $e');
      return []; // Return an empty list in case of an error
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
        viewPatientScreen(
          specialistID: specialistID,
        ),
        SpecialistConsultationHistory(
          specialistID: specialistID,
        ), // index 0

        createMenuScreen(
          todayConsultations: todayConsultations,
          fetchTodayConsultations: _fetchTodayConsultations,
          navigateToPage: _navigateToPage,
        ),
        ViewUpcomingAppointment(),
        SettingsSpecialistScreen(
          specialistID: specialistID,
        ) // Pass the consultations
      ];
    });
  }

  MenuScreen createMenuScreen({
    required List<Consultation> todayConsultations,
    required Future<List<Consultation>> Function() fetchTodayConsultations,
    required Function(int) navigateToPage,
  }) {
    return MenuScreen(
      specialistName: specialistName,
      logStatus: logStatus,
      specialistID: specialistID,
      todayConsultations: todayConsultations,
      fetchTodayConsultations: fetchTodayConsultations,
      navigateToPage: navigateToPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.length > _currentIndex ? _pages[_currentIndex] : Container(),
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
          label: 'Consultation History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Upcoming Appointment',
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
   List<Consultation> todayConsultations;
  final Future<List<Consultation>> Function() fetchTodayConsultations;
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
  late Future<List<Consultation>>? futureConsultations;


  @override
  void initState() {
    super.initState();
    futureConsultations =
    widget.fetchTodayConsultations() as Future<List<Consultation>>?;
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
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Text(
                    "Service",
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
                              Icons.people_alt, 30, Colors.white, 'Patient List'),
                          onTap: () {
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
                              Icons.assignment_outlined,
                              30,
                              Colors.white,
                              'Consultation\nHistory'),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpecialistConsultationHistory(
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
                                    ViewUpcomingAppointment(
                                     ),
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
              SizedBox(height: 10),
              SingleChildScrollView(
                child: Container(
                  height: 407,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.only(left: 15, right: 15, top: 2),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        SizedBox(
                          width: 550,
                          height: 500,
                          child: FutureBuilder<List<Consultation>>(
                            future: widget.fetchTodayConsultations(),
                            builder: (BuildContext context, AsyncSnapshot<List<Consultation>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(child: Text('No Data for Appointment Today'));
                              } else if (snapshot.hasData) {
                                List<Consultation>? consultations = snapshot.data;

                                return ListView.builder(
                                  itemCount: consultations?.length ?? 0,
                                  itemBuilder: (BuildContext context, index) {
                                    Consultation consult = consultations![index];
                                    return Card(
                                      elevation: 4,
                                      margin: EdgeInsets.all(8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        side: BorderSide(color: Colors.blueAccent),
                                      ),
                                      child: SizedBox(
                                        height: 123,
                                        child: Flexible(
                                          child: Container(
                                            padding: EdgeInsets.only(left: 12, right: 12, top: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
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
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '${consult.patientName}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      SizedBox(height: 3,),
                                                      Text(
                                                        'Date: ${DateFormat('dd/MM/yyyy').format(consult.consultationDateTime)}',
                                                      ),
                                                      SizedBox(height: 3,),
                                                      Text(
                                                        'Time: ${DateFormat('hh:mm a').format(consult.consultationDateTime)}',
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Container(
                                                        height: 23,
                                                        width: 75,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20),
                                                          color: Color(_getStatusColor(consult.consultationStatus)),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${consult.consultationStatus}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.normal,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 150,
                                                  height: 200,// Adjust the width as needed
                                                  child: Align(
                                                    alignment: Alignment.bottomRight,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        if (consult.consultationStatus != 'Accepted' &&
                                                            consult.consultationStatus != 'Decline')
                                                          Column(
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(Icons.cancel,
                                                                size: 30,
                                                                    color: Colors.red,),
                                                                onPressed: () async {
                                                                  bool confirmed = await showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(10.0),
                                                                        ),
                                                                        title: Text('Confirm Decline'),
                                                                        content: Text('Are you sure you want to decline this consultation?'),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop(false);
                                                                            },
                                                                            child: Text('Cancel'),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop(true);
                                                                            },
                                                                            child: Text('Confirm'),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );

                                                                  if (confirmed == true) {
                                                                    try {
                                                                      int consultationID = consult.consultationID ?? 0;
                                                                      String newStatus = 'Decline';

                                                                      final response = await http.get(Uri.parse(
                                                                        'http://${MyApp.ipAddress}/teleclinic/'
                                                                            'updateConsultationStatus.php?consultationID='
                                                                            '$consultationID&updateConsultationStatus=$newStatus',
                                                                      ));

                                                                      if (response.statusCode == 200) {
                                                                        print('Status updated successfully');
                                                                        // Fetch updated data and trigger a rebuild
                                                                        setState(() {});
                                                                      } else {
                                                                        print('Failed to update status. Status Code: ${response.statusCode}');
                                                                      }
                                                                    } catch (e) {
                                                                      print('Error updating status: $e');
                                                                    }
                                                                  }
                                                                },
                                                              ),
                                                              Text('Decline',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                FontWeight.w400,
                                                                fontSize: 15
                                                              ),),
                                                            ],
                                                          ),
                                                        Spacer(),
                                                        if (consult.consultationStatus == 'Accepted')
                                                          Expanded(
                                                            child: Column(
                                                              children: [
                                                                IconButton(
                                                                  icon: Icon(Icons.add_ic_call_sharp,
                                                                    size: 30,
                                                                    color: Color(hexColor("228B22"),)),
                                                                  onPressed: () async {
                                                                    bool confirmed = await showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return AlertDialog(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                          ),
                                                                          title: Text('Confirm Call Patient'),
                                                                          content: Text('Are you sure you want to call this patient?'),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop(false);
                                                                              },
                                                                              child: Text('Cancel'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) =>
                                                                                        CallPage(
                                                                                        ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                              child: Text('Confirm'),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );

                                                                    if (confirmed == true) {
                                                                      try {
                                                                        print("call");
                                                                      } catch (e) {
                                                                        print('Error updating status: $e');
                                                                      }
                                                                    }
                                                                  },
                                                                ),
                                                                Text('Call Now'),
                                                              ],
                                                            ),
                                                          ),

                                                        if (consult.consultationStatus != 'Accepted' &&
                                                            consult.consultationStatus != 'Decline')
                                                          Column(
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(Icons.done,
                                                                size: 35,
                                                                    color: Colors.green,),
                                                                onPressed: () async {
                                                                  try {
                                                                    int consultationID = consult.consultationID ?? 0;
                                                                    String newStatus = 'Accepted';

                                                                    final response = await http.get(Uri.parse(
                                                                      'http://${MyApp.ipAddress}/teleclinic/'
                                                                          'updateConsultationStatus.php?consultationID='
                                                                          '$consultationID&updateConsultationStatus=$newStatus',
                                                                    ));

                                                                    if (response.statusCode == 200) {
                                                                      print('Status updated successfully');
                                                                      // Fetch updated data and trigger a rebuild
                                                                      setState(() {});
                                                                    } else {
                                                                      print('Failed to update status. Status Code: ${response.statusCode}');
                                                                    }
                                                                  } catch (e) {
                                                                    print('Error updating status: $e');
                                                                  }
                                                                },
                                                              ),
                                                              Text('Accept',
                                                              style: TextStyle
                                                                (fontWeight:
                                                              FontWeight.w400,
                                                              fontSize: 15)
                                                                ,
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Center(child: Text('No data available'));
                              }
                            },
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

  int _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green.value;
      case 'Decline':
        return Colors.red.value;
      case 'Pending':
      // Use your hexColor function here for the desired color
        return hexColor('FFC000');
      case 'CustomColor': // Add a case for a custom color
        return hexColor('1A2B3C'); // Replace with your custom hexadecimal color
      default:
        return Colors.transparent.value; // Default color
    }
  }

  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }


}
