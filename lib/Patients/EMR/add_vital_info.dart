import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/request_controller.dart';
import '../../Model/vital_info.dart';
import '../../changePassword1.dart';
import '../patient_home_page.dart';
import '../patient_home.dart';
//import 'package:connectivity/connectivity.dart';


void main() {
  runApp(MaterialApp(
    home: AddVitalInfoScreen( patientID: 0 ),
  ));
}

// class VitalInfo {
//   final double weight;
//   final double height;
//   final double waistCircumference;
//   final double bloodPressure;
//   final double bloodGlucose;
//   final double heartRate;
//   final String latestDate;
//   final int patientID;
//
//
//   VitalInfo(
//       this.weight,
//       this.height,
//       this.bloodPressure,
//       this.bloodGlucose,
//       this.heartRate,
//       this.waistCircumference,
//       this.latestDate, this.patientID,
//       );
//
//   VitalInfo.fromJson(Map<String, dynamic> json)
//       : patientID = int.parse(json['patientID'].toString()),
//         weight = json['weight'],
//         height = json['height'],
//         waistCircumference = json['waistCircumference'],
//         bloodGlucose = json['bloodGlucose'],
//         bloodPressure = json['bloodPressure'],
//         heartRate = json['heartRate'],
//         latestDate = json['latestDate'];
//
//   // toJson will be automatically called by jsonEncode when necessary
//   Map<String, dynamic> toJson() => {'patientID': patientID,'weight': weight, 'height': height,
//     'waistCircumference': waistCircumference,  'bloodPressure': bloodPressure,
//     'bloodGlucose': bloodGlucose,  'heartRate': heartRate, 'latestDate': latestDate};
//
//
//   Future<bool> save() async {
//     RequestController req = RequestController(path: "/teleclinic/vitalInfo.php?");
//     req.setBody(toJson());
//     await req.post();
//     return req.status() == 200;
//   }
//
//   static Future<List<VitalInfo>> loadAll() async {
//     List<VitalInfo> result = [];
//     RequestController req = RequestController(path: "/teleclinic/vitalInfo.php");
//     await req.get();
//     if (req.status() == 200 && req.result() != null) {
//       for (var item in req.result()) {
//         result.add(VitalInfo.fromJson(item));
//       }
//     }
//     return result;
//   }
// }

class AddVitalInfoScreen extends StatefulWidget {
  final int patientID;

  AddVitalInfoScreen({required this.patientID});

  @override
  _AddVitalInfoScreenState createState() => _AddVitalInfoScreenState();
}

class _AddVitalInfoScreenState extends State<AddVitalInfoScreen> {
  late int patientID;
  final List<VitalInfo> weights = [];
  final List<VitalInfo> heights = [];
  final List<VitalInfo> waistCircumferences = [];
  final List<VitalInfo> bloodGlucoses = [];
  final List<VitalInfo> bloodPressures = [];
  final List<VitalInfo> heartRates = [];
  TextEditingController patientIDController = TextEditingController();
  TextEditingController waistCircumferenceController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController bloodGlucoseController = TextEditingController();
  TextEditingController bloodPressureController = TextEditingController();
  TextEditingController heartRateController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      RequestController req = RequestController(
        path: "/api/timezone/Asia/Kuala_Lumpur",
        server: "http://worldtimeapi.org",
      );
      req.get().then((value) {
        dynamic res = req.result();
        dateController.text =
            res["date"].toString().substring(0, 19).replaceAll('T', '');
      });
      //super.initState();
      _loadData();
      //patientID.addAll(await VitalInfo.loadAll());
      weights.addAll(await VitalInfo.loadAll());
      heights.addAll(await VitalInfo.loadAll());
      waistCircumferences.addAll(await VitalInfo.loadAll());
      bloodPressures.addAll(await VitalInfo.loadAll());
      bloodGlucoses.addAll(await VitalInfo.loadAll());
      heartRates.addAll(await VitalInfo.loadAll());
    });
  }

  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        // Format the picked date to display only the date part
        dateController.text =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }


  Future<void> _loadData()  async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;

    setState(() {
      patientID = storedID;
      patientIDController.text = patientID.toString();
    });
  }

  Future<void> _addVitalInfo() async {
    String weight = weightController.text.trim();
    String height = heightController.text.trim();
    String bloodGlucose = bloodGlucoseController.text.trim();
    String bloodPressure = bloodPressureController.text.trim();
    String waistCircumference = waistCircumferenceController.text.trim();
    String heartRate = heartRateController.text.trim();

    if (weight.isNotEmpty &&
        height.isNotEmpty &&
        bloodPressure.isNotEmpty &&
        bloodGlucose.isNotEmpty &&
        heartRate.isNotEmpty &&
        waistCircumference.isNotEmpty) {
      VitalInfo vitalInfo = VitalInfo(
          double.parse(weight),
          double.parse(height),
          double.parse(waistCircumference),
          double.parse(bloodPressure),
          double.parse(bloodGlucose),
          double.parse(heartRate),
          dateController.text, int.parse(patientIDController.text));

      if (await vitalInfo.save()) {
        setState(() {
          weights.add(vitalInfo);
          heights.add(vitalInfo);
          waistCircumferences.add(vitalInfo);
          bloodPressures.add(vitalInfo);
          bloodGlucoses.add(vitalInfo);
          heartRates.add(vitalInfo);
          // weightController.clear();
          // heightController.clear();
          // waistCircumferenceController.clear();
          // bloodPressureController.clear();
          // bloodGlucoseController.clear();
          // heartRateController.clear();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuccessAddScreen()),);
        });
      } else {
        _showMessage("Failed to save Vital Info data");
      }
    }
  }

  void _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
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
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, right: 154),
              child: Text(
                "Add Vital Info ",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  textStyle: const TextStyle(fontSize: 28, color: Colors.black),
                ),
              ),
            ),
            ListTile(
              title: Padding(
                padding: EdgeInsets.only(top: 30),
                child: Image.asset(
                  "asset/news.png",
                  width: 294,
                  height: 88,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 20, left: 130),
                child: Text(
                  'Vital Info',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle:
                    const TextStyle(fontSize: 22, color: Colors.black54),
                  ),
                ),
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 5, right: 300.0),
                child: Text(
                  'Date',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Column(
                children: [
                  SizedBox(
                    width: 700,
                    height: 70,
                    child: Container(
                      padding: EdgeInsets.only(left: 12, right: 12,),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
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
                      child: TextField(
                        keyboardType: TextInputType.datetime,
                        readOnly: true,
                        onTap: _selectDate,
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Select Date',
                          prefixIcon: Icon(Icons.date_range),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 240.0),
                child: Text(
                  'Weight (kg)',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Column(
                children: [
                  SizedBox(
                    width: 700,
                    height: 70,
                    child: Container(
                      padding: EdgeInsets.only(left: 12, right: 12,),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
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
                      child: TextField(
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: 'Enter your weight',
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 240.0),
                child: Text(
                  'Height (cm)',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Column(
                children: [
                  SizedBox(
                    width: 700,
                    height: 70,
                    child: Container(
                      padding: EdgeInsets.only(left: 12, right: 12,),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
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
                      child: TextField(
                        controller: heightController,
                        decoration: InputDecoration(
                          labelText: 'Enter your height',
                          prefixIcon: Icon(Icons.height),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 120.0),
                child: Text(
                  'Waist Circumference (cm)',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Column(
                children: [
                  SizedBox(
                    width: 700,
                    height: 70,
                    child: Container(
                      padding: EdgeInsets.only(left: 12, right: 12,),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
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
                      child: TextField(
                        controller: waistCircumferenceController,
                        decoration: InputDecoration(
                          labelText: 'Enter your waist circumference',
                          prefixIcon: Icon(Icons.attribution_rounded),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 140.0),
                child: Text(
                  'Blood Glucose (mg/dL) ',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Column(
                children: [
                  SizedBox(
                    width: 700,
                    height: 70,
                    child: Container(
                      padding: EdgeInsets.only(left: 12, right: 12,),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
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
                      child: TextField(
                        controller: bloodGlucoseController,
                        decoration: InputDecoration(
                          labelText: 'Enter your blood glucose',
                          prefixIcon: Icon(Icons.bloodtype),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 130.0),
                child: Text(
                  'Blood Pressure (mmHg) ',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Column(
                children: [
                  SizedBox(
                    width: 700,
                    height: 70,
                    child: Container(
                      padding: EdgeInsets.only(left: 12, right: 12,),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
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
                      child: TextField(
                        controller: bloodPressureController,
                        decoration: InputDecoration(
                          labelText: 'Enter your blood pressure',
                          prefixIcon: Icon(Icons.bloodtype_outlined),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 180.0),
                child: Text(
                  'Heart Rate (bpm) ',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Column(
                children: [
                  SizedBox(
                    width: 700,
                    height: 70,
                    child: Container(
                      padding: EdgeInsets.only(left: 12, right: 12,),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
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
                      child: TextField(
                        controller: heartRateController,
                        decoration: InputDecoration(
                          labelText: 'Enter your heart rate',
                          prefixIcon: Icon(Icons.monitor_heart_rounded),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton(
                onPressed: _addVitalInfo,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}

class SuccessAddScreen extends StatefulWidget {
  const SuccessAddScreen({super.key});

  @override
  State<SuccessAddScreen> createState() => _SuccessAddState();
}



class _SuccessAddState extends State<SuccessAddScreen> {
  @override
  void initState() {
    _loadData();
  }
  Future<void> _loadData()  async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;
    String storedPhone = prefs.getString("phone") ?? "";
    String storedName = prefs.getString("patientName") ?? "" ;

    setState(() {
      patientID = storedID;
      phone = storedPhone;
      patientName = storedName;

    });
  }
  late String phone; // To store the retrieved phone number
  late String patientName;
  late int patientID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 9.0, top: 150),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'asset/done1.png',
                          width: 120,
                          height: 120,
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 40,),
                        child: SizedBox(width: 10),
                      ),
                      Text(
                        "Successfully Added Vital Info !",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => HomePage (phone: phone, patientName: patientName, patientID: patientID),));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                      ),
                      backgroundColor: Color(hexColor('#024362')), // Set your preferred background color
                    ),
                    child: Text('Back to Homepage',
                      style:TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,                  ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }
}