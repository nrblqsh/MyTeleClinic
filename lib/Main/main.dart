import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ZegoUIKit().initLog().then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final String ipAddress = "192.168.56.1";
  static final String clinicPath = "/teleclinic/clinic.php";

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();

    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([ZegoUIKitSignalingPlugin()]);

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: LoginScreen(),
      routes: {
      //  '/patientHomePage': (context) => PatientHomePage(),
        // Add other routes as needed
      },
    );
  }
}
