// AppForLater.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '/Model/booking.dart';
import '../../Patients/Telemedicine/ViewBooking.dart';


void main() {
  runApp( MaterialApp(
    home: AppointmentScreen(patientID: 0, specialistID: 0),
  ));
}

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
// late int specialistID;

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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duration: ', style: TextStyle(fontSize: 16)),
                        Text('30 minutes', style: TextStyle(fontSize: 16)),
                      ],
                    ),
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
                      // Create a new Booking instance with the selected data
                      Booking newBooking = Booking(
                        patientID: patientID, // Replace with the actual patient ID
                        specialistID: specialistID,
                        appointmentDateTime: DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        ),
                      );

                      // Save the booking to the database
                      bool success = await newBooking.save();

                      // Show the confirmation container only if the booking is successful
                      if (success) {
                        setState(() {
                          showConfirmation = true;
                        });
                      }
                    },

                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    child: Text('Book Appointment'),
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
                'Your booking is successful!',
                style: TextStyle(fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.all(100.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen()));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text("View Booking"),
                ),
              )
            ]
        ),
      ),
    );
  }
}