import 'package:flutter/material.dart';
import 'Patients/patient_home_page.dart'; // Import the HomePage

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('This is the Menu Page'),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(phone: '', patientName: '', patientID: 0,)),
              );
            },
            child: Text('Go to Homepage'),
          ),
          SizedBox(height: 20),
          HomePage(phone: '', patientName: '', patientID: 0,), // Reuse the HomePage widget
        ],
      ),
    );
  }
}
