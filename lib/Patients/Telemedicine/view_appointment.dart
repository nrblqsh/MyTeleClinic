import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Model/consultation.dart';
import '/Patients/Telemedicine/specialist.dart';
import 'package:intl/intl.dart';


void main() {
  runApp(const MaterialApp(
    home: ViewAppointmentScreen(),
  ));
}

class ViewAppointmentScreen extends StatefulWidget {
  const ViewAppointmentScreen({Key? key}) : super(key: key);

  @override
  _ViewAppointmentScreenState createState() => _ViewAppointmentScreenState();
}

class _ViewAppointmentScreenState extends State<ViewAppointmentScreen> {
  late Future<List<Consultation>> futureConsultations;

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString); // Parse the string into a DateTime object
    return DateFormat('MMMM dd, yyyy - hh:mm a').format(dateTime); // Format the DateTime object
  }

  @override
  void initState() {
    super.initState();
    futureConsultations = fetchConsultations();
  }

  Future<List<Consultation>> fetchConsultations() async {
    final String url = 'http://192.168.188.129/teleclinic/consultation.php';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => Consultation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch consultations');
    }
  }

  Future<void> cancelAppointment(int consultationID, int patientID) async {
    final String url = 'http://192.168.188.129/teleclinic/cancelAppointment.php?consultationID=$consultationID&patientID=$patientID';

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
      body:
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      Padding(
      padding: const EdgeInsets.all(8.0),
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
        child:
        FutureBuilder<List<Consultation>>(
          future: futureConsultations,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Consultation> consultations = snapshot.data!;
              return Column(
                children: consultations.map((consultation) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(child: Text('Appointment Details')),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: Text(
                                      '${_formatDateTime(consultation.consultationDateTime.toString())}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        // Add other styling properties as needed
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(25.0),
                                    child: Text('Are you sure to cancel your appointment? You can set up another appointment later.'),
                                  ),
                                  //Text('Patient ID: ${consultation.patientID}'),
                                  //Text('Specialist ID: ${consultation.specialistID}'),
                                  // Add more fields as needed
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () async {

                                        if (consultation.consultationID != null) {
                                          await cancelAppointment(
                                            consultation.consultationID!, // Assuming consultationID is non-nullable
                                            consultation.patientID, // Assuming patientID is non-nullable
                                          );
                                          Navigator.pop(context); // Close the dialog
                                          // No need to navigate here as we're updating the data, but you can add navigation if needed.
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => SuccessPage()),
                                          );
                                        } else {
                                          // Handle the case where consultationID is null
                                          print('Consultation ID is null');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red, // Change the background color here
                                      ),
                                      child: Text('Cancel Appointment'),
                                    ),
                                  ),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ViewAppointmentScreen()),
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
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Card(
                          child: ListTile(
                            title: Text('${_formatDateTime(consultation.consultationDateTime.toString())}'),
                      subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Text('Patient ID: ${consultation.patientID}'),
                                Text('Specialist ID: ${consultation.specialistID}'),
                                // Add more fields as needed
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator(); // Display a loading spinner while fetching data
          },
        ),
        ),
       ]
     ),
    );
  }
  //
}class SuccessPage extends StatelessWidget {
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
                        context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen()));
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
