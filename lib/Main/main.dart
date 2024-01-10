import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../firebase_options.dart';
import 'login.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  // Extract data from the FCM message
  final Map<String, dynamic>? data = message.data;
  final String? title = data?['title'];
  final String? body = data?['body'];

  // // You can also extract other data from the message if needed
  //
  // // Use Awesome Notifications or another notification package to show a notification
  // AwesomeNotifications().createNotification(
  //   content: NotificationContent(
  //     id: 1,
  //     channelKey: "call channel",
  //     title: title,
  //     body: body,
  //     category: NotificationCategory.Call,
  //     wakeUpScreen: true,
  //     fullScreenIntent: true,
  //     autoDismissible: false,
  //     backgroundColor: Colors.orangeAccent,
  //   ),
  //   actionButtons: [
  //     NotificationActionButton(
  //       key: "Accept",
  //       label: "Accept Call",
  //       color: Colors.green,
  //       autoDismissible: true,
  //     ),
  //     NotificationActionButton(
  //       key: "Decline",
  //       label: "Decline Call",
  //       color: Colors.red,
  //       autoDismissible: true,
  //     ),
  //   ],
  // );

  // Perform any other background tasks or actions based on the message

  // Note: This function should be lightweight, as the system may terminate it after a short time.
}


void main() async {
  // // Initialize Awesome Notifications
  // await AwesomeNotifications().initialize(
  //   null,
  //   [
  //     NotificationChannel(
  //       channelKey: "call channel",
  //       channelName: "Call",
  //       channelDescription: "Channel for calls",
  //       importance: NotificationImportance.Max,
  //       channelShowBadge: true,
  //       locked: true,
  //       defaultRingtoneType: DefaultRingtoneType.Ringtone,
  //     ),
  //   ],
  // );

  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up Firebase Cloud Messaging
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  // Initialize ZegoUIKit
  ZegoUIKit().initLog().then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final String ipAddress = "172.20.10.7";
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
