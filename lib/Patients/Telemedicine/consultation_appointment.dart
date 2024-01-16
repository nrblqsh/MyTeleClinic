// consultation_appointment.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_teleclinic/Model/consultation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
//import '/Model/booking.dart';
import '../../Main/main.dart';
import '../../Patients/Telemedicine/view_appointment.dart';


// void main() {
//   runApp( MaterialApp(
//     home: AppointmentScreen(patientID: 0, specialistID: specialistID),
//   ));
// }

class AppointmentScreen extends StatefulWidget {
  final int patientID;
  final int specialistID;

  AppointmentScreen({required this.patientID, required this.specialistID} );

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}


class _AppointmentScreenState extends State<AppointmentScreen> {
  late int patientID;
  late int specialistID;

  TextEditingController patientIDController = TextEditingController();
  TextEditingController specialistIDController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool showConfirmation = false; // Track if confirmation container should be shown

  Future<bool> checkAvailability(int specialistID, DateTime consultationDateTime) async {
    try {
      final response = await http.get(Uri.parse('http://${MyApp.ipAddress}/teleclinic/availabilityConsultation.php?specialistID=$specialistID&consultationDateTime=$consultationDateTime'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['available'];
      } else {
        print('Failed with status code: ${response.statusCode}');
        throw Exception('Failed to check availability');
      }
    } catch (e) {
      print('Error checking availability: $e');
      throw Exception('Failed to check availability');
    }
  }
  Future<void> _checkAndBookAppointment() async {
    print('Checking availability...');
    try {
      bool isAvailable = await checkAvailability(specialistID, DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ));

      if (!isAvailable) {
        print('Selected time slot is not available');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Time Slot Not Available'),
              content: Text('The selected time slot is not available. Please choose another time.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('Time slot is available. Proceeding to book appointment...');
        Consultation consult = Consultation(
          patientID: patientID,
          specialistID: specialistID,
          consultationDateTime: DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          ),
          consultationStatus: 'Pending',
          consultationTreatment: '',
          consultationSymptom: '',
        );

        bool success = await consult.save();

        if (success) {
          print('Appointment booked successfully!');
          setState(() {
            showConfirmation = true;
          });
        } else {
          print('Failed to book appointment. Please check the code or backend.');
        }
      }
    } catch (e) {
      print('Error occurred during appointment booking: $e');
      // Handle error scenario (show error message, log, etc.)
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData()  async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;
    int storedSpecialistID = prefs.getInt("specialistID") ?? 0;

    setState(() {
      patientID = storedID;
      specialistID = storedSpecialistID;
      patientIDController.text = patientID.toString();
      specialistIDController.text = specialistID.toString();
    });
    print('Data Parsed :');
    print(patientID );
    print(specialistID);
  }

// late int patientID;
//late int specialistID;

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
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              // ListTile(
              //   leading: Icon(Icons.person),
              //   title: Text('Dr. Muhammad Ali bin Bakar'),
              //   subtitle: Text('Emergency Medicine Specialist'),
              // ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Date and Time', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
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
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Select Date'),
                      subtitle: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                      onTap: () => _selectDate(context),
                      trailing: Icon(Icons.expand_more_outlined),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
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
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('Select Time'),
                      subtitle: Text(selectedTime.format(context)),
                      onTap: () => _selectTime(context),
                      trailing: Icon(Icons.expand_more_outlined),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 250, right: 20, bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _checkAndBookAppointment();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    child: Text('Book Consultation Appointment'),
                  ),
                ),
              )
            ],
          ),
          if (showConfirmation)
            Center(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selected Date: ${DateFormat('dd.MM.yyyy').format(selectedDate)}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Selected Time: ${selectedTime.format(context)}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Are you sure?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Logic to confirm appointment booking
                          // Navigate to success page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SuccessPage()),
                          );
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class SuccessPage extends StatelessWidget {
  late final int patientID=0;

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
                'Your appointment booking is successful!',
                style: TextStyle(fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.all(100.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>
                        ViewAppointmentScreen(patientID: patientID,)));
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