
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

  // OneSignal.Notifications.addClickListener((event) {
  //   print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
  //
  //     _debugLabelString =
  //     "Clicked notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
  //
  // });
  //
  // OneSignal.Notifications.addForegroundWillDisplayListener((event) {
  //   print(
  //       'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
  //
  //   /// Display Notification, preventDefault to not display
  //   event.preventDefault();
  //
  //   /// Do async work
  //
  //   /// notification.display() to display after preventing default
  //   event.notification.display();
  //
  //
  //     _debugLabelString =
  //     "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
  //
  //   // navigatorKey.currentState?.push(MaterialPageRoute(
  //   //   builder: (context) => SpecialistHomeScreen(),
  //   // ));
  // });
  // OneSignal.InAppMessages.addClickListener((event) {
  //   print("In App Message Clicked: \n${event.result.jsonRepresentation().replaceAll("\\n", "\n")}");
  // });
  //
  // OneSignal.InAppMessages.addWillDisplayListener((event) {
  //   print("ON WILL DISPLAY IN APP MESSAGE ${event.message.messageId}");
  // });
  // OneSignal.InAppMessages.addDidDisplayListener((event) {
  //   print("ON DID DISPLAY IN APP MESSAGE ${event.message.messageId}");
  // });
  // OneSignal.InAppMessages.addWillDismissListener((event) {
  //   print("ON WILL DISMISS IN APP MESSAGE ${event.message.messageId}");
  // });
  // OneSignal.InAppMessages.addDidDismissListener((event) {
  //   print("ON DID DISMISS IN APP MESSAGE ${event.message.messageId}");
  // });


   // _enableConsentButton = _requireConsent;


  // OneSignal.InAppMessages.addClickListener((actionResult) {
  //   // Check if the action result has buttons
  //   if (actionResult.message?.buttons?.isNotEmpty ?? false) {
  //     // Handle button clicks
  //     for (var button in actionResult.message!.buttons!) {
  //       if (button.id == 'accept') {
  //         // Handle the 'Accept' button click
  //         handleAcceptAction();
  //       } else if (button.id == 'reject') {
  //         // Handle the 'Reject' button click
  //         handleRejectAction();
  //       }
  //     }
  //   }
  // });


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
