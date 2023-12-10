import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: ChatboxScreen(),
  ));
}
class ChatboxScreen extends StatelessWidget {
  const ChatboxScreen({super.key});

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
      body: Center(
        child: Text('This is the chatbox screen.'),
      ),
    );
  }
}

