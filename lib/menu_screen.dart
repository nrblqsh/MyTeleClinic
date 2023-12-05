import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: MenuScreen(),
  ));
}
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}


class _MenuScreenState extends State<MenuScreen>{
  int index = 0;
  final screens = [
    //eMedicalRecordScreen(),
    //Center(child: Text('TeleMed', style: TextStyle(fontSize: 72))),
    MenuScreen(),
    //Center(child: Text('Menu', style: TextStyle(fontSize: 72))),
    //Center(child: Text('View Booking', style: TextStyle(fontSize: 72))),
    //SettingsScreen(),

    //nanti tukar screen jadi page masing2x kalau siap
    //contoh EMR(), TeleMed()
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: screens[index], //to make sure tekan button tu pergi dekat screen yang betul
      bottomNavigationBar: NavigationBarTheme (
          data: NavigationBarThemeData(
            indicatorColor: Colors.blue.shade100, //kalau tekan jadi biru
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(fontSize: 14, fontWeight: FontWeight.w500), //resize
            ),
          ),
          child: NavigationBar(
            height: 60, //resize kotak navigation
            backgroundColor: Color(0xFFf15b), //colour kotak navigation
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            selectedIndex: index, // dynamic tekan icon satu per satu instead panggil [0,1,2]
            animationDuration: Duration(seconds: 2),
            onDestinationSelected: (index) =>
                setState(() => this.index = index),
            destinations:[
              NavigationDestination(
                icon: Icon(Icons.medical_services_outlined),
                selectedIcon: Icon(Icons.medical_services),
                label: 'EMR',
              ),
              NavigationDestination(
                icon: Icon(Icons.medication_liquid_sharp),
                selectedIcon: Icon(Icons.medication_liquid),
                label: 'TeleMed',
              ),
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Menu',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt),
                label: 'View Booking',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_applications_outlined),
                selectedIcon: Icon(Icons.settings_applications),
                label: 'Settings',
              ),
            ],
          )
      ),
    );
  }
}
