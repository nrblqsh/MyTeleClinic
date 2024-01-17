import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/Profile/patient_home_page.dart';
import 'package:my_teleclinic/Specialists/ZegoCloud/videocall_zegocloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../Main/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Model/specialist.dart';

class NotificationPage extends StatefulWidget {
  final String senderName;
  final int consultationID;
  final String callID;


  NotificationPage({required this.senderName,
  required this.consultationID,
  required this.callID});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _shouldPlaySound = true;
  bool hasVibrator = false; // Initialize with a default value
  String url = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3";
  final player = AudioPlayer();
  late AnimationController _acceptController;
  late AnimationController _rejectController;
  String patientName = '';
  int patientID = 0;


  final Specialist _specialist = Specialist(
    specialistID: 0,
    // You may need to set the correct specialist ID
    clinicID: 0,
    // You may need to set the correct clinic ID
    specialistName: '',
    // You may need to set the correct specialist name
    specialistTitle: '',
    // You may need to set the correct specialist title
    phone: '',
    // You may need to set the correct phone number
    password: '',
    // You may need to set the correct password
    logStatus: '',
    // You may need to set the correct log status
    clinicName: '',
    specialistImagePath: Uint8List(0), // Empty Uint8List for no image
  );

  @override
  void initState() {
    super.initState();

    loadData();
    _loadSpecialistImage();
    _audioPlayer = AudioPlayer(); // Initialize _audioPlayer
    _loadVibratorStatus();
    _startVibrationAndSound();
    _acceptController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )
      ..repeat(reverse: true);
    _rejectController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )
      ..repeat(reverse: true);
    //getCallInfo();
  }

  void _loadVibratorStatus() async {
    hasVibrator = await Vibration.hasVibrator() ?? false;
  }

  void _startVibrationAndSound() async {
    if (hasVibrator) {
      Vibration.vibrate(pattern: [500, 1000], intensities: [128, 255]);
    }

    _playSoundLoop();
  }

  void _loadData() {

  }

  void _playSoundLoop() async {
    while (_shouldPlaySound) {
      await player.play(UrlSource(url));

      // Adjust the duration based on your sound file
      await Future.delayed(Duration(seconds: 2));

      // Check _shouldPlaySound before playing the sound again
      if (!_shouldPlaySound) {
        break;
      }
    }
  }

  void _stopVibrationAndSound() {
    Vibration.cancel();
    _shouldPlaySound = false;
    player.stop();
    _audioPlayer.stop();
  // Use the same player instance
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _acceptController.dispose();
    _rejectController.dispose();
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
      Uri.parse('http://${MyApp
          .ipAddress}/teleclinic/getSenderInfo.php?consultationID=${widget
          .consultationID}'),
    );

    if (response.statusCode == 200) {
      // Parse the JSON response and return the dynamicCallID and specialistID
      Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'phone': data['phone'],
      };
    } else {
      // Handle error (e.g., server error, network error)
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
    if (_specialist.specialistImagePath != null &&
        _specialist.specialistImagePath!.isNotEmpty) {
      return MemoryImage(
          _specialist.specialistImagePath!); // Display the existing image
    } else {
      return AssetImage('asset/profile image default.jpg');
    }
  }


  Widget _buildAnimatedButton(IconData icon,
      Color color,
      AnimationController controller,
      Color containerColor,
      VoidCallback onPressed,) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            controller.value * 20,
            0,
          ), // Adjust the movement
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: containerColor, // Set the background color of the button
            ),
            child: IconButton(
              icon: Icon(icon, size: 40, color: Colors.white),
              onPressed: onPressed,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.blueGrey, // Set the background color of the page
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
              key: UniqueKey(), // Add this line
              radius: 50,
              backgroundImage: _getImageProvider(),
            ),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedButton(
                  Icons.call,
                  Colors.green,
                  _acceptController,
                  Colors.green, // Container color for accept button
                      () {

                        if (!mounted) {
                          return;
                        }
                    // Add the action for the accept button here
                    _stopVibrationAndSound();
                    Navigator.pop(context);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyCall(callID: widget.callID,
                                    consultationID: widget.consultationID,
                                    id: patientID.toString(),
                                name: patientName,
                                roleId: 0,)
                          //****
                        ));
                    // if (mounted) {
                    //   Navigator.pop(context);
                    // }
                    // Add more actions if needed
                  },
                ),

                SizedBox(width: 70),
                _buildAnimatedButton(
                  Icons.call_end,
                  Colors.red,
                  _rejectController,
                  Colors.red, // Container color for decline button
                      () {
                    // Add the action for the decline button here
                    _stopVibrationAndSound();
                    _stopVibrationAndSound();
                    _stopVibrationAndSound();
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomePage(phone: "phone",
                                patientID: patientID,
                                patientName: patientName,)
                          //****
                        ));

                        // Add more actions if needed
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

