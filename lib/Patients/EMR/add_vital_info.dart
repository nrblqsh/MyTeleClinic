import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_teleclinic/Patients/EMR/blood_glucose.dart';
import '../../Controller/request_controller.dart';
//import 'package:connectivity/connectivity.dart';


void main() {
  runApp(MaterialApp(
    home: AddVitalInfoScreen(),
  ));
}

class VitalInfo {
  final double weight;
  final double height;
  final double waistCircumference;
  final double bloodPressure;
  final double bloodGlucose;
  final double heartRate;
  final String date;



  VitalInfo(
      this.weight,
      this.height,
      this.bloodPressure,
      this.bloodGlucose,
      this.heartRate,
      this.waistCircumference,
      this.date,
      );

  VitalInfo.fromJson(Map<String, dynamic> json)
      : weight = json['weight'],
        height = json['height'],
        waistCircumference = json['waistCircumference'],
        bloodGlucose = json['bloodGlucose'],
        bloodPressure = json['bloodPressure'],
        heartRate = json['heartRate'],
        date = json['latestDate'];

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() => {'weight': weight, 'height': height,
    'waistCircumference': waistCircumference,  'bloodPressure': bloodPressure,
    'bloodGlucose': bloodGlucose,  'heartRate': heartRate, 'latestDate': date};


  Future<bool> save() async {
    RequestController req = RequestController(path: "/teleclinic/vitalInfo.php");
    req.setBody(toJson());
    await req.post();
    return req.status() == 200;


  }

  static Future<List<VitalInfo>> loadAll() async {
    List<VitalInfo> result = [];
    RequestController req = RequestController(path: "/teleclinic/vitalInfo.php");
    await req.get();
    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(VitalInfo.fromJson(item));
      }
    }
    return result;
  }
}

class AddVitalInfoScreen extends StatefulWidget {
  @override
  _AddVitalInfoScreenState createState() => _AddVitalInfoScreenState();
}

class _AddVitalInfoScreenState extends State<AddVitalInfoScreen> {
  final List<VitalInfo> weights = [];
  final List<VitalInfo> heights = [];
  final List<VitalInfo> waistCircumferences = [];
  final List<VitalInfo> bloodGlucoses = [];
  final List<VitalInfo> bloodPressures = [];
  final List<VitalInfo> heartRates = [];
  TextEditingController waistCircumferenceController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController bloodGlucoseController = TextEditingController();
  TextEditingController bloodPressureController = TextEditingController();
  TextEditingController heartRateController = TextEditingController();
  TextEditingController dateController = TextEditingController();

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
        dateController.text);

      if (await vitalInfo.save()) {
        setState(() {
          weights.add(vitalInfo);
          heights.add(vitalInfo);
          waistCircumferences.add(vitalInfo);
          bloodPressures.add(vitalInfo);
          bloodGlucoses.add(vitalInfo);
          heartRates.add(vitalInfo);
          weightController.clear();
          heightController.clear();
          waistCircumferenceController.clear();
          bloodPressureController.clear();
          bloodGlucoseController.clear();
          heartRateController.clear();
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

  @override
  void initState() {
    super.initState();
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
}
