import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login.dart';
import 'menu_page.dart'; // Import your login screen widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      initialRoute: '/menu', // Set the initial route to MenuPage
      routes: {
        '/loginscreen': (context) => const LoginScreen(),
        '/menu': (context) => MenuPage(), // Define the route for MenuPage
        '/home': (context) => HomePage(),
      },
    );
  }
}
