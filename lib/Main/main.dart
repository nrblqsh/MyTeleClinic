import 'package:flutter/material.dart';
import '../Patients/Profile/patient_home_page.dart';
import 'login.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final String ipAddress = "10.131.76.105";
  static final String clinicPath = "/teleclinic/clinic.php";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      // initialRoute: '/menu', // Set the initial route to MenuPage
      // routes: {
      //   '/loginscreen': (context) => const LoginScreen(),
      //   '/menu': (context) => MenuPage(), // Define the route for MenuPage
      //   '/home': (context) => HomePage(phone: '', patientName: '', patientID: 0,),

    );
  }
}



