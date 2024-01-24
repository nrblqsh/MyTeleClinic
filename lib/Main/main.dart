
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/Profile/CountDown.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../Specialists/Profile/specialist_home.dart';
import '../firebase_options.dart';
import 'login.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  // Extract data from the FCM message
  final Map<String, dynamic>? data = message.data;
  final String? title = data?['title'];
  final String? body = data?['body'];


  // Note: This function should be lightweight, as the system may terminate it after a short time.
}




void main() async {


  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  String _debugLabelString = "";
  bool _requireConsent = false;
  bool _enableConsentButton = false;


  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.initialize("59bae8a4-4acb-4435-9edf-c5e794ac1f37");
  OneSignal.Notifications.requestPermission(true);
  OneSignal.Notifications.addPermissionObserver((state) {
    print("has permission" + state.toString());
  });
  // Set up Firebase Cloud Messaging



  OneSignal.Notifications.addPermissionObserver((state) {
    print("Has permission " + state.toString());
  });



  OneSignal.InAppMessages.addWillDisplayListener((event) {
    // Handle the in-app message will display event
  });

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);


  // Initialize ZegoUIKit
  ZegoUIKit().initLog().then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  static final String ipAddress = "192.168.8.186";
  static final String clinicPath = "/teleclinic/clinic.php";

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();
    //
    // ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    // ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([ZegoUIKitSignalingPlugin()]);

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: LoginScreen(),
      routes: {
        // Add other routes as needed
        // '/patientHomePage': (context) => PatientHomePage(),
      },
    );
  }
}
