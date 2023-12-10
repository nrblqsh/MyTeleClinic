import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the HomePage

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('This is the Menu Page'),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Text('Go to Homepage'),
          ),
          SizedBox(height: 20),
          HomePage(), // Reuse the HomePage widget
        ],
      ),
    );
  }
}
