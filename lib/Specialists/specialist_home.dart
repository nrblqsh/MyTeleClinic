import 'package:flutter/material.dart';
import 'package:my_teleclinic/Specialists/view_patient.dart';

void main(){
  runApp(const MaterialApp(
    home: Specialist_Home_Screen(),
  ));
}
class Specialist_Home_Screen extends StatefulWidget {
  const Specialist_Home_Screen({super.key});

  @override
  State<Specialist_Home_Screen> createState() => _Specialist_Home_ScreenState();
}

class _Specialist_Home_ScreenState extends State<Specialist_Home_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome Doctor"),
      ),
      body :
      ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => viewPatientScreen()));
        },
        child: Text("View Patient List"),
      ),
    );
  }
}
