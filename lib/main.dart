import 'package:flutter/material.dart';
import 'package:my_teleclinic/menu_screen.dart';
import 'login.dart'; // Import your login screen widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      routes: {
        '/loginscreen': (context) => const LoginScreen(),
        '/menupage': (context) => const MenuScreen(),
      },
    );
  }
}
