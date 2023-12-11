import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_teleclinic/Chatbox/chatbox.dart';
import 'Map/mapLocation.dart';
import 'Patients/EMR/add_vital_info.dart';
import 'Patients/Telemedicine/view_specialist.dart';
import 'Patients/settings.dart';

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;
  bool hasNewMessage = false;
  int newMessagesCount = 0;
  Position? userLocation;

  void checkForNewMessages() {
    int newMessagesCount = /* Your logic to get the count of new messages */ 0;

    setState(() {
      hasNewMessage = newMessagesCount > 0;
    });
  }

  @override
  void initState() {
    checkForNewMessages();
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    await Geolocator.requestPermission().then((value) {
      if (value == LocationPermission.denied) {
        print('Location permission denied');
      }
    }).onError((error, stackTrace) {
      print('error $error');
    });

    userLocation = await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 98,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Services",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        textStyle: const TextStyle(fontSize: 22, color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Icons.people_alt_sharp,
                      size: 24,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8.0),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ChatboxScreen()));
                      },
                      child: Stack(
                        children: [
                          Icon(
                            Icons.mail,
                            size: 24,
                            color: hasNewMessage ? Colors.grey : Colors.grey,
                          ),
                          if (hasNewMessage)
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Text(
                                  newMessagesCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Image.network(
                              "https://cdn-icons-png.flaticon.com/512/1076/1076325.png",
                              height: 64,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "E-Medical Record",
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                textStyle: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.network(
                              "https://cdn-icons-png.flaticon.com/512/5980/5980109.png",
                              width: 64,
                              height: 64,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "TeleMedicine",
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                textStyle: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.network(
                              "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678116-calendar-512.png",
                              width: 64,
                              height: 64,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "View Booking",
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                textStyle: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 16.0),
                  child: Row(
                    children: [
                      Text(
                        "Nearby Clinic",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          textStyle: const TextStyle(fontSize: 22, color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Icon(
                        Icons.location_pin,
                        size: 24,
                        color: Colors.red,
                      ),
                      SizedBox(height: 25.0),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapLocation()),
                    );
                  },
                  child: Container(
                    height: 380,
                    width: 380,
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: userLocation != null
                                ? LatLng(userLocation!.latitude, userLocation!.longitude)
                                : const LatLng(2.3232303497978815, 102.29396072202006),
                            zoom: 14,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MapLocation()),
                                );
                                print("Button tapped!");
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Color(hexColor('C73B3B'))),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                  ),
                                ),
                              ),
                              child: Text("Navigate to Map Screen"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => AddVitalInfoScreen(patientID: 0,)));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => viewSpecialistScreen()));

          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/menu');
          } else if (index == 3) {
            // Add your navigation logic here
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => SettingsScreen()));

          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'EMR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_front_rounded),
            label: 'TeleMedicine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'View Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        backgroundColor: Colors.grey[700],
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}
