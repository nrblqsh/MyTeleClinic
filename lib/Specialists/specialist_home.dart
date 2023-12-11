import 'package:flutter/material.dart';
import 'package:my_teleclinic/Specialists/view_patient.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Patients/settings.dart';

void main() {
  runApp(const MaterialApp(
    home: SpecialistHomeScreen(),
  ));
}
class SpecialistHomeScreen extends StatefulWidget {
  const SpecialistHomeScreen({Key? key}) : super(key: key);

  @override
  _SpecialistHomeScreenState createState() => _SpecialistHomeScreenState();
}

class _SpecialistHomeScreenState extends State<SpecialistHomeScreen> {
  int _currentIndex = 2;
  late int specialistID;
  late String specialistName;

  final List<Widget> _pages = [
    viewPatientScreen(),  //index 0
    //TeleMedicineScreen(),
    //SpecialistHomeScreen(),
    //viewBookingScreen(),
    SettingsScreen(), //should be in last

    MenuScreen(),
  ];


  @override
  void initState() {
    super.initState();
    _loadSpecialistDetails();
  }


  Future<void> _loadSpecialistDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      specialistID = pref.getInt("specialistID") ?? 0;
      specialistName = pref.getString("specialistName") ?? '';
      print(specialistName);
      print(specialistID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt),
          label: 'Patient List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Schedule List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
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
    );
  }
}

class MenuScreen extends StatelessWidget {
  @override
  Widget customIconWithLabel(IconData icon, double size, Color iconColor, String label) {
    int bgColor = hexColor('A34040');

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(bgColor),
              ),
              child: Icon(
                icon,
                size: size,
                color: iconColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              maxLines: null,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                Icon(
                  Icons.star,
                  size: 24,
                  color: Color(hexColor('#C73B3B')),
                ),
              ],
            ),
            SizedBox(height: 10), // Adjust the spacing based on your preference
            Container(
              height: 180,
              width: 380,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 35, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customIconWithLabel(Icons.people_alt, 30, Colors.white, 'View Patient'),
                    SizedBox(width: 30),
                    customIconWithLabel(Icons.assignment_outlined, 30, Colors.white, 'ni untuk apa eh'),
                    SizedBox(width: 30),
                    customIconWithLabel(Icons.calendar_month, 30, Colors.white, 'Appointment List eh '),
                    // Add more icons with labels as needed
                  ],
                ),
              ),
            ),
            SizedBox(height: 30), // Adjust the spacing based on your preference
            Container(
              height: 180,
              width: 380,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nanti kita fikir nak letak apa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Add more text or widgets as needed
                ],
              ),
            ),
          ],
        ),
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
