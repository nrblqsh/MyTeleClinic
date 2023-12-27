import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_teleclinic/Specialists/specialist_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../Model/consultation.dart';

class ViewUpcomingAppointment extends StatefulWidget {
  final int? patientID;
// Add this line
// Add this line



  ViewUpcomingAppointment({Key? key, this.patientID,


  })
      : super(key: key);
  @override
  _ViewUpcomingAppointmentState createState() => _ViewUpcomingAppointmentState();
}

class _ViewUpcomingAppointmentState extends State<ViewUpcomingAppointment> {
  late int specialistID = 0;
  late String specialistName;
  late String logStatus;
  DateTime consultationDateTime = DateTime.now();
  int patientID = 0;
  String consultationStatus = '';
  String consultationSymptom = '';
  String consultationTreatment = '';
  late List<Consultation> todayConsultations = [];


  @override
  void initState() {
    super.initState();
    _loadSpecialistDetails();
  }

  Future<List<Consultation>> fetchUpcomingConsultations(
      int specialistID) async {
    Consultation consultation = Consultation(patientID: patientID,
        consultationTreatment: consultationTreatment,
        consultationSymptom: consultationSymptom,
        consultationStatus: consultationStatus,
        consultationDateTime: consultationDateTime,
        specialistID: specialistID,
        specialistName: specialistName);
    return await consultation.fetchUpcomingConsultations(specialistID);
  }


  Future<void> _loadSpecialistDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      specialistID = pref.getInt("specialistID") ?? 0;
      specialistName = pref.getString("specialistName") ?? '';
      logStatus = pref.getString("logStatus") ?? 'OFFLINE';
      print("testttt$specialistName");
      print(specialistID);
      print(logStatus);



    });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Align content to the left
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top:30.0, left:10),
                child: Text(
                  'Upcoming Appointment', // Add your test text here
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ),
            ),
            Container(
              child: FutureBuilder(
                future: fetchUpcomingConsultations(specialistID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<Consultation>? consultations = snapshot.data as List<
                        Consultation>?;

                    if (consultations != null && consultations.isNotEmpty) {
                      return ListView.builder(
                        itemCount: consultations.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, index) {
                          Consultation consult = consultations[index];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                _showConsultationDetailsDialog(
                                    context, consult);
                              },

                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, top: 10),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 700,
                                        height: 130,
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${consult.patientName}',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5), // Adjust the height if needed
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Date: ${DateFormat('dd/MM/yyyy').format(consult.consultationDateTime)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Time: ${DateFormat('hh:mm a').format(consult.consultationDateTime)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:5.0),
                                                    child: Container(
                                                      height: 23,
                                                      width: 75,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        color: _getStatusColor(consult.consultationStatus),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '${consult.consultationStatus}',
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
                                            ],
                                          ),


                                        ),
                                      )
                                    ],
                                  ),
                                ),

                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                          child: Text('No upcoming appointments available'));
                    }
                  } else {
                    return Center(child: Text('No data available'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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

  void _showConsultationDetailsDialog(BuildContext context,
      Consultation consultation) {

    bool isApproved = consultation.consultationStatus == 'Accepted';
    bool isDecline = false;



    Future<void> _handleApproval() async {
      // Check if the consultation status is 'PENDING'
      if (consultation.consultationStatus == 'Pending') {
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to call now?'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    isApproved = true;

                    Navigator.pop(context);
                  },
                  child: Text('Confirm Call'),
                ),
                ElevatedButton(
                  onPressed: () {

                    setState(() {
                      isApproved = false;
                    });
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        );
        final consultationID = consultation.consultationID;
        final newStatus = 'Accepted';

        final response = await http.get(Uri.parse(
          'http://${MyApp.ipAddress}/teleclinic/'
              'updateConsultationStatus.php?consultationID='
              '$consultationID&updateConsultationStatus=$newStatus',
        ));

        if (response.statusCode == 200) {
          print('Status updated successfully');

          // Update the UI with the new status
          consultation.consultationStatus = newStatus;
          // Close the existing dialog and show the updated one
          Navigator.pop(context);
          _showConsultationDetailsDialog(context, consultation);
        }
      }
    }

    Future<void> _handleDecline() async {
      // Implement the logic for declining here
      final consultationID = consultation.consultationID;
      final newStatus = 'Decline';

      final response = await http.get(Uri.parse(
        'http://${MyApp.ipAddress}/'
            'teleclinic/'
            'updateConsultationStatus.php?'
            'consultationID=$consultationID&'
            'updateConsultationStatus=$newStatus',
      ));

      if (response.statusCode == 200) {
        print('Status updated to Decline successfully');


        consultation.consultationStatus = newStatus;

        setState(() {

        });

        Navigator.pop(context);
        _showConsultationDetailsDialog(context, consultation);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Determine the text color based on the consultation status
            Color statusTextColor;
            switch (consultation.consultationStatus) {
              case 'Decline':
                statusTextColor = Colors.red;
                break;
              case 'Accepted':
                statusTextColor = hexColor("00A36C");
                break;
              case 'Pending':
                statusTextColor = hexColor("FFC000");
                break;
              default:
                statusTextColor = Colors.black;
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Appointment Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.black,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height:30,
                          child: Text(
                            ' ${consultation.patientName}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        SizedBox(height: 20,
                          child: Text(
                            'Date: ${DateFormat('dd/MM/yyyy').
                            format(consultation.consultationDateTime)}',
                          ),
                        ),
                        SizedBox(height: 20,
                          child: Text(
                            'Time: ${DateFormat('hh:mm a').
                            format(consultation.consultationDateTime)}',
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Status: ${consultation.consultationStatus}',
                            style: TextStyle(
                              color: statusTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),



    SizedBox(height: 16),

                        if (consultation.consultationStatus != 'Decline')
                          Container(
                            margin: EdgeInsets.only(bottom: 8),
                            child: SizedBox(
                              width: 280,
                              height:40,// Set the width to your desired value
                              child: ElevatedButton(
                                onPressed: isApproved ? null : _handleApproval,
                                style: ButtonStyle(
                                  backgroundColor: isApproved
                                      ? MaterialStateProperty.all(Colors.grey)
                                      : MaterialStateProperty.all(Colors.green),
                                  shape: MaterialStateProperty.all
                                  <RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0), // Set border radius here
                                    ),
                                  ),
                                ),
                                child: Text('Approve'),
                              ),
                            ),
                          ),





                        if (consultation.consultationStatus != 'Decline')
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: 280,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isDecline = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: hexColor("C73B3B") ,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),

                            child: Text('Decline'),
                          ),
                        ),
                      ),
                    ),

                  if (isApproved && consultation.consultationStatus
                      == 'Pending'&&
                      consultation.consultationStatus != 'Accepted' )
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Are you sure you want to call now?'),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                isApproved = true;

                                Navigator.pop(context);
                              },
                              child: Text('Confirm Call'),
                            ),
                            ElevatedButton(
                              onPressed: () {

                                setState(() {
                                  isApproved = false;
                                });
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),

                        if (isDecline)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Are you sure you want to decline '
                                      'this appointment?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _handleDecline();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(0.0),
                                        ),
                                      ),
                                      child: Text('Confirm Decline'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isDecline = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(0.0),
                                        ),
                                      ),
                                      child: Text('Cancel'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                      ],
              ),
            )
                ],
                )
            );
          },
        );
      },

    );
  }



}