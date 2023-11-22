import 'package:flutter/material.dart';

void main(){
  runApp(const MaterialApp(
    home: PatientHomePage(),
  ));
}
class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome Patient"),
      ),
    );
  }
}
