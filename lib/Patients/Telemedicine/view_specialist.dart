import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_teleclinic/Patients/Telemedicine/AppForLater.dart';
import 'package:my_teleclinic/Patients/Telemedicine/specialist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../changePassword1.dart';
import '../patient_home_page.dart';

// void main() {
//   runApp(const MaterialApp(
//     home: viewSpecialistScreen(),
//   ));
// }

class viewSpecialistScreen extends StatefulWidget {
  // final int specialistID;
  // viewSpecialistScreen({
  //   required this.specialistID,
  //   // Other required properties
  // });
 // const viewSpecialistScreen({super.key});

  @override
  _viewSpecialistScreenState createState() => _viewSpecialistScreenState();
}

Future<List<Specialist>> fetchSpecialist() async {
  String url = 'http://10.131.74.150/teleclinic/viewSpecialist.php';
  final response = await http.get(Uri.parse(url));
  return specialistFromJson(response.body);
}

class _viewSpecialistScreenState extends State<viewSpecialistScreen> {
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
        body: SingleChildScrollView(
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 25, right: 100),
            child: Text(
              "Find your specialist ",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                textStyle: const TextStyle(fontSize: 28, color: Colors.black),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
            child: Text(
              "Discover highly skilled healthcare experts for immediate "
              "assistance with your health issues. Seek virtual consultations"
              " with doctors through video calls or messaging ",
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 200, bottom: 10),
            child: Text(
              "Let's get started! ",
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),
          Container(
            child: FutureBuilder(
              future: fetchSpecialist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<Specialist>? specialists =
                      snapshot.data as List<Specialist>?;
                  if (specialists != null) {
                    return ListView.builder(
                      itemCount: specialists.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, index) {
                        Specialist specialist = specialists[index];
                        return Card(
                          child: GestureDetector(
                            onTap: () {
                              Specialist specialist = specialists[index];
                            //  print('index-');
                             // print(index);
                              specialistID = int.parse('${specialist.specialistID}');
                             // print(specialistID);
                            _loadData();
                              showDialog(
                                context: context,
                                // Make sure you have access to the context
                                builder: (BuildContext context) {
                                  return Dialog(
                                    //backgroundColor: Colors.greenAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),

                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 12, right: 12, top: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.blueAccent),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
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
                                      height: 400,
                                      child: Column(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 20.0),
                                            child: Image.network(
                                              'https://t4.ftcdn.net/jpg/02/29/53/11/360_F_229531197_jmFcViuzXaYOQdoOK1qyg7uIGdnuKhpt.jpg',
                                              width: 90,
                                              height: 90,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5.0),
                                            child: Text(
                                              '${specialist.specialistName}',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            //
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 15.0),
                                            child: Text(
                                              '${specialist.specialistTitle}',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 4,left: 4, bottom: 40.0),
                                            child: Text(
                                              'You will need to wait for atleast 15 minutes'
                                                  ' before specialist approve your request.'
                                                  ' \nAre you sure to proceed your consultation request?',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context, MaterialPageRoute(builder: (context) => SuccessRequestScreen(),));
                                              },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                            ),
                                              child: Text("Request Consultation Now"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context, MaterialPageRoute(builder: (context) => AppointmentScreen(patientID: 0, specialistID:specialistID,),));
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                            ),
                                            child: Text("Book For Later"),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding:
                                  EdgeInsets.only(left: 15, right: 15, top: 10),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 700,
                                    height: 70,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 12, right: 12, top: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.blueAccent),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '${specialist.specialistName}',
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            '${specialist.specialistTitle}',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Text('No data available');
                  }
                } else {
                  return Text('No data available');
                }
              },
            ),
          )
        ])));
  }

  Future<void> _loadData()  async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //Specialist specialist = specialists[index];
    int storedID = prefs.getInt("patientID") ?? 0;
    int storedSpecialistID = prefs.getInt("specialistID") ?? specialistID;


    setState(() {
      patientID = storedID;
      specialistID = storedSpecialistID;

    });
  }
  late int patientID;
  late int specialistID;
}

class SuccessRequestScreen extends StatefulWidget {
  const SuccessRequestScreen({super.key});

  @override
  State<SuccessRequestScreen> createState() => _SuccessRequestState();
}



class _SuccessRequestState extends State<SuccessRequestScreen> {
  @override
  void initState() {
    _loadData();
  }
  Future<void> _loadData()  async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;
    int storedSpecialistID = prefs.getInt("specialistID") ?? 0;
    String storedPhone = prefs.getString("phone") ?? "";
    String storedName = prefs.getString("patientName") ?? "" ;

    setState(() {
      patientID = storedID;
      phone = storedPhone;
      patientName = storedName;
      specialistID = storedSpecialistID;

    });
  }
  late String phone; // To store the retrieved phone number
  late String patientName;
  late int patientID;
  late int specialistID;

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
                        "Request successfully sent!",
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


