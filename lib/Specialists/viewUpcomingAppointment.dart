import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../Model/consultation.dart';

class ViewUpcomingAppointment extends StatefulWidget {
  final int? patientID;

  ViewUpcomingAppointment({Key? key, this.patientID}) : super(key: key);
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
                padding: const EdgeInsets.all(8.0),
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
                                      height: 100,
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
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Text(
                                              '${consult.patientName}',
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),

                                            Text(
                                              'Date: ${DateFormat('dd/MM/yyyy')
                                                  .format(
                                                  consult
                                                      .consultationDateTime)}\n'
                                                  'Time: ${DateFormat('hh:mm a')
                                                  .format(
                                                  consult
                                                      .consultationDateTime)}\n'
                                                  'Status: ${consult
                                                  .consultationStatus}\n',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
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

  void _showConsultationDetailsDialog(BuildContext context,
      Consultation consultation) {

    bool isCallNowPressed = false;
    bool isApproved = consultation.consultationStatus == 'ACCEPTED';
    bool isDecline = false;

    Future<void> _handleApproval() async {
      // Check if the consultation status is 'PENDING'
      if (consultation.consultationStatus == 'PENDING') {
        // Implement the logic for approval here
        final consultationID = consultation.consultationID;
        final newStatus = 'ACCEPTED';

        final response = await http.get(Uri.parse(
          'http://${MyApp.ipAddress}/teleclinic/'
              'updateConsultationStatus.php?consultationID='
              '$consultationID&updateConsultationStatus=$newStatus',
        ));

        if (response.statusCode == 200) {
          print('Status updated successfully');

          // Update the UI with the new status
          consultation.consultationStatus = newStatus;
          isApproved = true; // Update the approval status

          // Close the existing dialog and show the updated one
          Navigator.pop(context);
          _showConsultationDetailsDialog(context, consultation);
        }
      }
    }

    Future<void> _handleDecline() async {
      // Implement the logic for declining here
      final consultationID = consultation.consultationID;
      final newStatus = 'DECLINE';

      final response = await http.get(Uri.parse(
        'http://${MyApp.ipAddress}/'
            'teleclinic/'
            'updateConsultationStatus.php?'
            'consultationID=$consultationID&'
            'updateConsultationStatus=$newStatus',
      ));

      if (response.statusCode == 200) {
        print('Status updated to DECLINE successfully');


        consultation.consultationStatus = newStatus;


        Navigator.pop(context);
        _showConsultationDetailsDialog(context, consultation);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Appointment Details'),
              contentPadding: EdgeInsets.all(10),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Patient Name: ${consultation.patientName}'),

                  Text('Date: ${DateFormat('dd/MM/yyyy').
                  format(consultation.consultationDateTime)}'),

                  Text('Time: ${DateFormat('hh:mm a').
                  format(consultation.consultationDateTime)}'),

                  Text('Status: ${consultation.consultationStatus}'),

                  SizedBox(height: 16),

                  if (consultation.consultationStatus != 'DECLINE')
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: _handleApproval,
                        style: ButtonStyle(
                          backgroundColor: isApproved ?
                          MaterialStateProperty.all(Colors.grey) : null,
                        ),
                        child: Text('Approve'),
                      ),
                    ),

                  if (!isCallNowPressed &&
                      consultation.consultationStatus != 'DECLINE')

                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle the "Call Now" action
                          setState(() {
                            isCallNowPressed = true;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                          (consultation.consultationStatus == 'PENDING'
                              && !isApproved)

                              ? MaterialStateProperty.all(Colors.grey)
                              : null,
                        ),
                        child: Text('Call Now'),
                      ),
                    ),

                  if (consultation.consultationStatus != 'DECLINE')
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isDecline = true;
                          });
                        },
                        child: Text('Decline'),
                      ),
                    ),

                  if (isCallNowPressed)
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

                                Navigator.pop(context);
                              },
                              child: Text('Confirm Call'),
                            ),
                            ElevatedButton(
                              onPressed: () {

                                setState(() {
                                  isCallNowPressed = false;
                                });
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),

                  if (isDecline)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Are you sure you want to decline?'),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _handleDecline();
                              },
                              child: Text('Confirm Decline'),
                            ),
                            ElevatedButton(
                              onPressed: () {

                                setState(() {
                                  isDecline = false;
                                });
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }


}