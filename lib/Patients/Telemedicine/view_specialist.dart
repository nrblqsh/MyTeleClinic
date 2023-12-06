import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_teleclinic/Patients/Telemedicine/specialist.dart';
import '../../Controller/request_controller.dart';

void main() {
  runApp(const MaterialApp(
    home: viewSpecialistScreen(),
  ));
}

class viewSpecialistScreen extends StatefulWidget {
  const viewSpecialistScreen({super.key});

  @override
  _viewSpecialistScreenState createState() => _viewSpecialistScreenState();
}

Future<List<Specialist>> fetchSpecialist() async {
  String url = 'http://192.168.0.116/teleclinic/viewSpecialist.php';
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
                            child: Container(
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                child: Column(children: [
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
                                ])));
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
}
