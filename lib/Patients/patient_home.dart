import 'package:flutter/material.dart';
import 'package:my_teleclinic/login.dart';

void main(){
  runApp(const MaterialApp(
    home: PatientHomePage(patientName: '',),
  ));
}
class PatientHomePage extends StatefulWidget {
  final String patientName;
  const PatientHomePage({Key? key, required this.patientName});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${widget.patientName}"),
      ),
    );
  }
}
