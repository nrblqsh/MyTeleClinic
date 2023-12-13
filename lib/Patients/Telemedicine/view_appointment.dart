import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:ui';
//import '/Model/booking.dart';


void main() {
  runApp(const MaterialApp(
    home: ViewAppointmentScreen(),
  ));
}

class ViewAppointmentScreen extends StatefulWidget {
  const ViewAppointmentScreen({super.key});

  @override
  _ViewAppointmentScreen createState() => _ViewAppointmentScreen();
}

class _ViewAppointmentScreen extends State<ViewAppointmentScreen> {

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

      //body:
      // screens[_index], //to make sure tekan button tu pergi dekat screen yang betul
      // bottomNavigationBar: NavigationBarTheme (
      //     data: NavigationBarThemeData(
      //       indicatorColor: Colors.blue.shade100, //kalau tekan jadi biru
      //       labelTextStyle: MaterialStateProperty.all(
      //         TextStyle(fontSize: 14, fontWeight: FontWeight.w500), //resize
      //       ),
      //     ),
      //     child: NavigationBar(
      //       height: 60, //resize kotak navigation
      //       backgroundColor: Color(0xFFf15b), //colour kotak navigation
      //       labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      //       selectedIndex: _index, // dynamic tekan icon satu per satu instead panggil [0,1,2]
      //       animationDuration: Duration(seconds: 2),
      //       onDestinationSelected: (index) =>
      //           setState(() => this._index = index),
      //       destinations:[
      //         NavigationDestination(
      //           icon: Icon(Icons.medical_services_outlined),
      //           selectedIcon: Icon(Icons.medical_services),
      //           label: 'EMR',
      //         ),
      //         NavigationDestination(
      //           icon: Icon(Icons.medication_liquid_sharp),
      //           selectedIcon: Icon(Icons.medication_liquid),
      //           label: 'TeleMed',
      //         ),
      //         NavigationDestination(
      //           icon: Icon(Icons.home_outlined),
      //           selectedIcon: Icon(Icons.home),
      //           label: 'Menu',
      //         ),
      //         NavigationDestination(
      //           icon: Icon(Icons.list_alt_outlined),
      //           selectedIcon: Icon(Icons.list_alt),
      //           label: 'View Booking',
      //         ),
      //         NavigationDestination(
      //           icon: Icon(Icons.settings_applications_outlined),
      //           selectedIcon: Icon(Icons.settings_applications),
      //           label: 'Settings',
      //         ),
      //       ],
      //     )
      // ),
    );
  }

}


