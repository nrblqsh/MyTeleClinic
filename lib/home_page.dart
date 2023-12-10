import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_teleclinic/Chatbox/chatbox.dart';
import 'Patients/EMR/e_medical_record.dart';


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
  int _currentIndex = 2; // Initial index for the Menu tab
  bool hasNewMessage = false; // Initial value when there are no new messages
  int newMessagesCount = 0; // Declare newMessagesCount as a class variable


  // Simulate checking for new messages
  void checkForNewMessages() {
    // Replace this with your actual logic to check for new messages
    // For example, you might have a counter that increments when a new message is received
    int newMessagesCount = /* Your logic to get the count of new messages */ 0; // Initialize to 0 or your actual count

    setState(() {
      hasNewMessage = newMessagesCount > 0;
    });
  }

  @override
  void initState() {
    // Call checkForNewMessages in the widget lifecycle, for example, in initState
    checkForNewMessages();
    super.initState();
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
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
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
                    onTap: (){
                      //Handle inbox icon tap
                      //Navigate to the chatbox
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatboxScreen()));
                    },
                    child: Stack (
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
                                  newMessagesCount.toString(), // Display the actual count
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                              ),
                            ),
                            )
                        ]
                    ),
                  ),

                ],
              ),

              SizedBox(height: 10.0),

              // Center the box decoration along with the images
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
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
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
                    SizedBox (width: 14.0),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(vertical: 16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
              )
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Handle navigation based on the selected tab
          if (index == 0) {
            // Navigate to EMR
            Navigator.push(context, MaterialPageRoute(builder: (context) => eMedicalRecordScreen()));

          } else if (index == 1) {
            // Navigate to Telemed
            // Add your navigation logic here

          } else if (index == 2) {
            // Navigate to Home (Menu)
            Navigator.pushReplacementNamed(context, '/menu');

          } else if (index == 3) {
            // Navigate to View Booking
            // Add your navigation logic here

          } else if (index == 4) {
            // Navigate to Settings
            // Add your navigation logic here
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
        backgroundColor: Colors.grey[700], // Set background color to gray
        selectedItemColor: Colors.blueGrey, // Set the color of the selected item's icon
        unselectedItemColor: Colors.grey, // Set the color of unselected items' icons
      ),
    );
  }
}
