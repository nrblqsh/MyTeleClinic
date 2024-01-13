import 'package:flutter/material.dart';
import 'package:my_teleclinic/Specialists/ZegoCloud/constants.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';


class MyCall extends StatefulWidget {
  const MyCall({
    Key? key,
    required this.callID,
    required this.id,
    required this.name,
  }) : super(key: key);

  final String callID;
  final String id;
  final String name;

  @override
  State<MyCall> createState() => _MyCallState(
    callID: callID,
    id: id,
    name: name,
  );
}

class _MyCallState extends State<MyCall> {
  late String callID;
  late String id;
  late String name;
  late TextEditingController textEditingController;
  bool isVideoCallVisible = true;

  // Specialist details
  late int patientID;
  late int specialistID;
  late String specialistName;

  _MyCallState({
    required this.callID,
    required this.id,
    required this.name,
  }) : textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      patientID = pref.getInt("patientID") ?? 0;
      specialistID = pref.getInt("specialistID") ?? 0;
      specialistName = pref.getString("specialistName") ?? '';
      print("testttt$specialistName");
      print(specialistID);
      print(patientID);
    });
  }

  ZegoBottomMenuBarConfig bottomMenuBarConfig = ZegoBottomMenuBarConfig(
    hideAutomatically: true,
    // Other configuration properties can be set here as needed.
  );

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
      body: GestureDetector(
        onTap: () {
          // Unfocus the current focus (dismiss keyboard)
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // Your existing ZegoUIKitPrebuiltCall widget
                Positioned(
                  top: 0,
                  bottom: isVideoCallVisible ? 0 : -1, // Adjust this value to set the height
                  left: 0,
                  right: 0,
                  child: ZegoUIKitPrebuiltCall(
                    appID: MyConstant.appId,
                    appSign: MyConstant.appSign,
                    callID: callID,
                    userID: id,
                    userName: name,
                    config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(

                    ),
                  ),
                ),


                if (id == specialistID.toString())
                  Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: TextField(
                      onTap: () {
                        // You can add specific behavior when the TextField is tapped
                      },
                      controller: textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                // Add a GestureDetector to toggle video call visibility
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isVideoCallVisible = !isVideoCallVisible;
                      });
                    },
                    child: Icon(
                      isVideoCallVisible ? Icons.minimize : Icons.maximize,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
