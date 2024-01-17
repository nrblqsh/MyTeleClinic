import 'dart:convert';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:my_teleclinic/Model/specialist.dart';
import 'package:my_teleclinic/Specialists/Consultation/patient_consultation_history.dart';
import 'package:my_teleclinic/Specialists/Profile/settingSpecialist.dart';
import 'package:my_teleclinic/Specialists/Consultation/specialist_consultation_history.dart';
import 'package:my_teleclinic/Specialists/Consultation/viewUpcomingAppointment.dart';
import 'package:my_teleclinic/Specialists/PatientInfo/view_patient.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_teleclinic/Specialists/ZegoCloud/videocall_zegocloud.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../Model/consultation.dart';
import '../../Patients/Telemedicine/view_appointment.dart';
import '../../Patients/Profile/settings.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;


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
  String patientName='';


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

  var uuid = Uuid();
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
  late int patientID;

  late int specialistID;
  late String specialistName;
  String dynamicCallID = ''; // Declare dynamicCallID here as a class variable

var uuid = Uuid();



  Future<void> _loadDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      patientID = pref.getInt("patientID") ?? 0;
      specialistID = pref.getInt("specialistID") ?? 0;
      specialistName = pref.getString("specialistName") ?? '';
      print("testttt$specialistName");
      print(specialistID);
      print(patientID);


      // Add createMenuScreen() after loading specialist details
    });
  }

  @override
  void initState() {
    super.initState();
    // FirebaseMessaging.onMessage.listen((RemoteMessage message){
    //   String? title = message.notification!.title;
    //   String? body = message.notification!.body;
    //   AwesomeNotifications().createNotification(content: NotificationContent(id: 1,
    //       channelKey: "call_channel",
    //       title: title,
    //       body: body,
    //       category:NotificationCategory.Call,
    //       wakeUpScreen: true,
    //       fullScreenIntent: true,
    //       autoDismissible: false,
    //       backgroundColor: Colors.orangeAccent
    //   ),
    //
    //       actionButtons:[ NotificationActionButton(key: "Accept", label: "Accept Call",
    //           color:Colors.green,
    //           autoDismissible: true),
    //
    //         NotificationActionButton(key: "Decline", label: "Decline Call",
    //             color:Colors.green,
    //             autoDismissible: true)
    //
    //       ]
    //   );
        // AwesomeNotifications().actionStream.listen((event){
        //   if(event.buttonKeyPressed=="REJECT"){
        //     print("call reject");
        //   }
        //   else if(event.buttonKeyPressed=="Accept"){
        //     print("accept");
        //   }
    //     // });
    // });


    _loadDetails();
    futureConsultations =
    widget.fetchTodayConsultations() as Future<List<Consultation>>?;




  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async{
      return  false;
    },
      child: Scaffold(
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
              mainAxisSize: MainAxisSize.min,
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
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25, right: 20),
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: customIconWithLabel(
                                Icons.people_alt,
                                30,
                                Colors.white,
                                'Patient List',
                              ),
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
                                'Consultation\nHistory',
                              ),
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
                                Icons.calendar_month,
                                30,
                                Colors.white,
                                'Upcoming\nAppointment',

                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewUpcomingAppointment(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
                  child: Column(
                    children: [
                      Container(
                        height: 700,
                        width: double.infinity, // Set width to take available space
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.only(left: 15, right: 15, top: 2),
                        child: SingleChildScrollView(
                          child: Expanded(
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                SizedBox(
                                  width: 550,
                                  height: 600,
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
                                            print("patienname ${consult.patientName}");
                                            String? patientName = consult.patientName;
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
                                                                    consult.consultationStatus != 'Decline'&&
                                                                    consult.consultationStatus != 'Done')
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
                                                                                      onPressed: () async {

                                                                                        int? consultationID = consult.consultationID;
                                                                                        print("consullttt$consultationID");
                                                                                        // Check and request camera and microphone permissions
                                                                                        var statusCamera = await Permission.camera.request();
                                                                                        var statusMicrophone = await Permission.microphone.request();

                                                                                        if (statusCamera.isGranted && statusMicrophone.isGranted) {
                                                                                          print("dapat");
                                                                                          // Both camera and microphone permissions are granted
                                                                                          Navigator.of(context).pop(true); // Close the dialog and return true
                                                                                        } else {
                                                                                          // Permissions are not granted
                                                                                          // Show a message to inform the user using a Dialog
                                                                                          showDialog(
                                                                                            context: context,
                                                                                            builder: (BuildContext context) {
                                                                                              return AlertDialog(
                                                                                                title: Text('Permission Required'),
                                                                                                content: Text('Camera and microphone permissions are required to make a call.'),
                                                                                                actions: [
                                                                                                  TextButton(
                                                                                                    onPressed: () {
                                                                                                      Navigator.of(context).pop(false);
                                                                                                    },
                                                                                                    child: Text('OK'),
                                                                                                  ),
                                                                                                ],
                                                                                              );
                                                                                            },
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                      child: Text('Confirm'),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );

                                                                            if (confirmed!= null && confirmed) {
                                                                              try {
                                                                                actionButtion(true);
                                                                                print("masuk");
                                                                                String specialistIDtoString = specialistID.toString();
                                                                                  dynamicCallID = generateRandomString(15);
                                                                                print("calllidddd$dynamicCallID");
                                                                                print("specialistID here $specialistID");
                                                                                int consultationID = consult.consultationID ?? 0;
                                                                                int pd = consult.patientID!;
                                                                                print("Patient ID for sending notification: $pd");


                                                                                await saveCallIDtoDatabase(consultationID, dynamicCallID);


                                                                           //     sendInAppMessage(pd.toString(), dynamicCallID, consultationID);


                                                                                // ZegoSendCallInvitationButton actionButton(bool isVideo)=>
                                                                                //     ZegoSendCallInvitationButton(
                                                                                //       isVideoCall:isVideo,
                                                                                //       resourceID:"zegouikit_call",
                                                                                //       invitees: [
                                                                                //         ZegoUIKitUser(id: "1",
                                                                                //             name: "test")
                                                                                //       ],
                                                                                //     );
                                                                                //
                                                                                //
                                                                                // actionButton(true);

                                                                                // updateStatustoGetReadytoCall(consultationID);
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => MyCall(
                                                                                      callID: dynamicCallID,
                                                                                      id: specialistIDtoString,
                                                                                      name: specialistName,
                                                                                      roleId: 1,
                                                                                      consultationID: consultationID,
                                                                                    ),
                                                                                  ),

                                                                                );
                                                                               // _sendNotification( pd);





                                                                                //await sendCallNotificationWithInAppActions(patientIDforSendingNotification, dynamicCallID);

                                                                                // Navigator.push(
                                                                                //   context,
                                                                                //   MaterialPageRoute(
                                                                                //     builder: (context) => MyCall(
                                                                                //       callID: dynamicCallID,
                                                                                //       id: specialistIDtoString,
                                                                                //       name: specialistName,
                                                                                //       roleId: 1,
                                                                                //     ),
                                                                                //   ),
                                                                                // );
                                                                                // //save callid dulu dlm db
                                                                                String? fcmToken = await getFCMTokenfromPatient(consultationID);
                                                                                print("fcm token dalam specialist $fcmToken");


                                                                                if (fcmToken != null) {


                                                                                //  await sendFCMNotification(fcmToken, dynamicCallID, specialistID, specialistName);
                                                                                } else {
                                                                                  print('FCM token is null. Cannot send notification.');
                                                                                }


                                                                              } catch (e) {
                                                                                print('Error during sen: $e');
                                                                              }
                                                                            }
                                                                          },
                                              ),
                                              Text('Call Now'),
                                              ],
                                            ),
                                            ),


                                                                if (consult.consultationStatus != 'Accepted' &&
                                                                    consult.consultationStatus != 'Decline' &&
                                                                    consult.consultationStatus != 'Done' &&
                                                                    consult.consultationStatus != 'Ready to Call'
                                                                )
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  ZegoSendCallInvitationButton actionButtion(bool isVideo)=>
      ZegoSendCallInvitationButton(
        isVideoCall:isVideo,
        resourceID:"zegouikit_call",
        invitees: [
          ZegoUIKitUser(id: "1",
              name: "test")
        ],

      );
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

  Future<void> sendFCMNotification(String fcmToken,
      String callID,
      int specialistID,
      String specialistName) async {
    // Replace with your FCM server key
    String serverKey = 'AAAAE_xNQHA:APA91bG_NAiAbTSOMipmmFtjf4csexaWwCK35F9b6717eDzdvChCYfnsNeK85ruFDnAtF5P1CGOsuNAFm_35-8jzjhggd0cVhMIEvN2bNRdkxfPWGEdlWWakwP-65_c34CaIl3xKgz75';
    print("masuk sini1");
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Replace with your notification payload
    final Map<String, dynamic> payload = {
      'to': fcmToken,
      'notification': {
        'title': 'Incoming Call',
        'body': 'You have an incoming call from the caller.',
        'sound': 'default', // Add sound if needed
      },
      'data': {
        'call_id': callID,
        // Include any other data needed to handle the call
      }};


    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(payload),
    ).timeout(Duration(seconds: 30));


    print('FCM Token: $fcmToken'); // Print the FCM token
    print('FCM Response: ${response.body}'); // Print the response body


    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody['failure'] != 0) {
        // Handle errors in the response
        final Map<String, dynamic> result = responseBody['results'][0];
        if (result.containsKey('error')) {
          if (result['error'] == 'InvalidRegistration') {
            // Handle invalid registration token
            print('InvalidRegistration: Removing or updating the invalid token.');
            // Your logic to handle or update the token on the server
          } else {
            print('Failed to send notification. Error: ${result['error']}');
          }
        }
      } else {
        print('Notification sent successfully');
        // ... (remaining code)
      }
    } else {
      print('Failed to send notification. Status Code: ${response.statusCode}');
    }

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
      case 'Done':
      // Use your hexColor function here for the desired color
        return hexColor('024362');
      case 'Ready to Call': // Add a case for a custom color
        return Colors.blueAccent.value; // Replace with your custom hexadecimal color
      default:
        return Colors.transparent.value; // Default color
    }
  }


  // void   testNotificationHandler(int consultationID) async {
  //   String _debugLabelString = '';
  //   OneSignal.Notifications.addPermissionObserver((state) {
  //     print("Has permission " + state.toString());
  //   });
  //
  //   OneSignal.Notifications.addClickListener((event) async {
  //     print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
  //
  //     _debugLabelString =
  //     "Clicked notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
  //
  //     getCallID(consultationID).then((String? callId) {
  //       print("callll $callId");
  //       print(consultationID);
  //
  //       if (callId != null) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => MyCall(
  //               callID: callId.toString(),
  //               id: patientID.toString(),
  //               name: "TEST",
  //               roleId: 0,
  //               consultationID: consultationID,
  //             ),
  //           ),
  //         );
  //       } else {
  //         // Handle the case when callId is null
  //         print('Failed to get call ID');
  //       }
  //     });
  //   });
  //
  //   OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
  //     getCallID(consultationID).then((String? callId) {
  //       print("callll $callId");
  //       print(consultationID);
  //
  //       if (callId != null) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => MyCall(
  //               callID: callId.toString(),
  //               id: patientID.toString(),
  //               name: patientName,
  //               roleId: 0,
  //               consultationID: consultationID,
  //             ),
  //           ),
  //         );
  //       } else {
  //         // Handle the case when callId is null
  //         print('Failed to get call ID');
  //       }
  //     });
  //
  //     print(
  //         'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
  //
  //     /// Display Notification, preventDefault to not display
  //     event.preventDefault();
  //
  //     /// Do async work
  //
  //     /// notification.display() to display after preventing default
  //     event.notification.display();
  //
  //     _debugLabelString =
  //     "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
  //   });
  // }
  // //in

  String generateRandomString(int length) {
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    print(random);
    return List.generate(length, (index) => charset[random.nextInt(charset.length)]).join();
  }

  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }


  Future<String?> getFCMTokenfromPatient(int consultID) async {
    String fcmToken = '';
    print("consultID$consultID");
    final response = await http.get(
      Uri.parse('http://${MyApp.ipAddress}/teleclinic/getFCMToken.php?consultationID'
          '=$consultID'),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response and return the channel name
      Map<String, dynamic> data = jsonDecode(response.body);
      print("fmcm$fcmToken");
      return data['fcmToken'];
    } else {
      // Handle error (e.g., server error, network error)
      throw Exception('Failed to get channel from backend');
    }
  }

  // Future<void> sendCallNotificationWithInAppActions(String patientIDforSendingNotification, String dynamicCallID) async {
  //   final String apiKey = "Y2E0YjA1YjEtOTVmYy00ZGRmLWI3YmQtNWNmYTExY2ZjNTlj";
  //   final String appId = "59bae8a4-4acb-4435-9edf-c5e794ac1f37";
  //
  //   print("ha tatau la$patientIDforSendingNotification");
  //   try {
  //     final response = await http.post(
  //       Uri.parse('https://onesignal.com/api/v1/notifications'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Basic $apiKey',
  //       },
  //       body: jsonEncode({
  //         'app_id': appId,
  //         'include_player_ids': [patientIDforSendingNotification],
  //         'contents': {'en': 'You have a call'},
  //         'data': {
  //           'type': 'call',
  //           'callId': dynamicCallID,
  //         },
  //         'buttons': [
  //           {'id': 'accept', 'text': 'Accept'},
  //           {'id': 'reject', 'text': 'Reject'},
  //         ],
  //         //'in_app_url': 'YOUR_IN_APP_MESSAGE_URL', // Provide the URL to your in-app message
  //       }),
  //     );
  //
  //     print("sicces");
  //     print(response.body);
  //   } catch(e){
  //     print('Error sending notification: $e');
  //
  //   }
  // }



  // // Future<void> _sendNotification(int patientID) async {
  // //   final response = await http.post(
  // //     Uri.parse('https://onesignal.com/api/v1/notifications'),
  // //     headers: {
  // //       'Content-Type': 'application/json',
  // //       'Authorization': 'Basic NzVmMDZkOTktNmYzZS00NzgyLWIxOWItYTM1MTlkMDBiZjA0',
  // //     },
  // //     body: jsonEncode({
  // //       "app_id": "59bae8a4-4acb-4435-9edf-c5e794ac1f37",
  // //       "include_external_user_ids": [patientID.toString()],
  // //       "contents": {"en": "Test notification"},
  // //       'data': {
  // //                 'type': 'call',
  // //                 'callId': dynamicCallID,
  // //               },
  // //       'buttons': [
  // //                 {'id': 'accept', 'text': 'Accept'},
  // //                 {'id': 'reject', 'text': 'Reject'},
  // //               ],
  // //
  // //
  // //     }),
  // //   );
  //
  //
  //
  //   if (response.statusCode == 200) {
  //     print('Notification sent successfully');
  //   } else {
  //     print('Failed to send notification. Status Code: ${response.statusCode}');
  //     print('Response Body: ${response.body}');
  //   }
  // }




  Future<void> sendInAppMessage(String playerId, String dynamicCallID, int consultationID) async {
    final String oneSignalApiUrl = 'https://onesignal.com/api/v1/notifications';

    final Map<String, dynamic> inAppMessage = {
      'app_id': "59bae8a4-4acb-4435-9edf-c5e794ac1f37",
      "include_external_user_ids": [playerId],
      'contents': {'en': 'Specialist is calling you...'},
      'data': {
        'type': 'call',
        'callId': dynamicCallID,
        'consultationID': consultationID,

      },
      'priority': 'urgent',

      //'android_background_layout': {'headings_color': 'FFFF0000', 'contents_color': 'FF00FF00'},
      'buttons': [
        {'id': 'accept', 'text': 'Accept'},
        {'id': 'reject', 'text': 'Reject'},
      ],
    };

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic NzVmMDZkOTktNmYzZS00NzgyLWIxOWItYTM1MTlkMDBiZjA0',
    };

    final http.Response response = await http.post(
      Uri.parse(oneSignalApiUrl),
      headers: headers,
      body: json.encode(inAppMessage),
    );

    if (response.statusCode == 200) {
      print('In-app message sent successfully');
    } else {
      print('Failed to send in-app message. Error: ${response.body}');
    }
  }


  Future<void> updateStatustoGetReadytoCall(int consultationID) async{
    try {

      String newStatus = 'Ready to Call';

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



  Future<String?> saveCallIDtoDatabase(int consultationID,String callID) async {
    final response = await http.post(
      Uri.parse('http://${MyApp.ipAddress}/teleclinic/dynamicCallID.php'),
      body: {
        'consultationID': consultationID.toString(),
        'dynamicCallID': dynamicCallID,
      },
    );
    if (response.statusCode == 200) {
      print('saveCallID successfully');
      setState(() {});
    } else {
      print('Failed to update status. Status Code: ${response.statusCode}');
    }
  }





}
