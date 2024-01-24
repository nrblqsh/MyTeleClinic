import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/Profile/patient_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Main/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Model/specialist.dart';
import '../ZegoCloud/videocall_zegocloud.dart';

class NotificationPage extends StatefulWidget {
  final String senderName;
  final int consultationID;
  final String callID;

  NotificationPage({
    required this.senderName,
    required this.consultationID,
    required this.callID,
  });

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String patientName = '';
  int patientID = 0;

  final Specialist _specialist = Specialist(
    specialistID: 0,
    clinicID: 0,
    specialistName: '',
    specialistTitle: '',
    phone: '',
    password: '',
    logStatus: '',
    clinicName: '',
    specialistImagePath: Uint8List(0),
  );

  @override
  void initState() {
    super.initState();

    loadData();
    _loadSpecialistImage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedPatientID = prefs.getInt("patientID") ?? 0;
    String storedName = prefs.getString("patientName") ?? "";

    setState(() {
      patientID = storedPatientID;
      patientName = storedName;
    });
  }

  Future<Map<String, String>?> getCallInfo() async {
    final response = await http.get(
      Uri.parse('http://${MyApp.ipAddress}/teleclinic/getSenderInfo.php?consultationID=${widget.consultationID}'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'phone': data['phone'],
      };
    } else {
      throw Exception('Failed to get call info from backend');
    }
  }

  Future<void> _loadSpecialistImage() async {
    try {
      Uint8List? imageBytes = await Specialist.getSpecialistImageforCall(widget.consultationID);

      if (imageBytes != null && imageBytes.isNotEmpty) {
        setState(() {
          _specialist.specialistImagePath = imageBytes;
        });
      } else {
        print('Invalid or empty image data');
      }
    } catch (e) {
      print('Error loading specialist image: $e');
    }
  }

  ImageProvider<Object>? _getImageProvider() {
    if (_specialist.specialistImagePath != null && _specialist.specialistImagePath!.isNotEmpty) {
      return MemoryImage(_specialist.specialistImagePath!);
    } else {
      return AssetImage('asset/profile image default.jpg');
    }
  }

  Widget _buildCircularIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, size: 40, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Video Call',
              style: TextStyle(fontSize: 35, color: Colors.white),
            ),
            Text(
              ' ${widget.senderName} is calling you..',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            CircleAvatar(
              key: UniqueKey(),
              radius: 50,
              backgroundImage: _getImageProvider(),
            ),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircularIconButton(Icons.call, Colors.green, () {
                  print("masul dua");
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyCall(
                        callID: widget.callID,
                        consultationID: widget.consultationID,
                        id: patientID.toString(),
                        name: patientName,
                        roleId: 0,
                      ),
                    ),
                  );
                }),
                SizedBox(width: 70),
                _buildCircularIconButton(Icons.call_end, Colors.red, () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        phone: "phone",
                        patientID: patientID,
                        patientName: patientName,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
