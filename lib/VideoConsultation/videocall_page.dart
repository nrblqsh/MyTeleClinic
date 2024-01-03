import 'dart:math';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';
import 'package:my_teleclinic/Specialists/Profile/specialist_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallPage extends StatefulWidget {
  @override
  State<CallPage> createState() => _CallPageState();
  Function() get onInviteRemoteUser => _CallPageState().onInviteRemoteUser;

}

class _CallPageState extends State<CallPage> {
  late RtcEngine _engine;
  bool loading = false;
  String appId = "89bda870d0d34c01b3714365be3b9144";
  List<int> _remoteUids = [];
  double xPosition = 0;
  double yPosition = 0;
  bool muted = false;
  bool isMaximized = false;
  late String dynamicChannelName; // New dynamic channel name variable
  void Function() onInviteRemoteUser = () {};

  @override
  void initState() {
    super.initState();
    dynamicChannelName = generateRandomString(8); // Generate a dynamic channel name
    initializeAgora();
  }

  // Function to generate a random string
  String generateRandomString(int length) {
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => charset[index % charset.length]).join();
  }

  @override
  void dispose() {
    _engine.destroy();
    super.dispose();
  }


  Future<void> initializeAgora() async {
    setState(() {
      loading = true;
    });

    var statusCamera = await Permission.camera.request();
    var statusMicrophone = await Permission.microphone.request();

    if (statusCamera.isGranted && statusMicrophone.isGranted) {
      // Initialize the Agora RTC Engine
      _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));

      await _engine.enableVideo();
      print("Video Enabled");
      await _engine.startPreview();
      print("Preview Started");

      // Set channel profile and join the channel
      await _engine.setChannelProfile(ChannelProfile.Communication);
      _engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          print("Channel joined: $channel");
        },
        userJoined: (uid, elapsed) {
          print("User joined: $uid");
          setState(() {
            _remoteUids.add(uid);
          });
        },
        userOffline: (uid, elapsed) {
          print("User offline: $uid");
          setState(() {
            _remoteUids.remove(uid);
          });
        },
      ));

      await _engine.joinChannel(null, dynamicChannelName, null, 0);

      setState(() {
        loading = false;
      });
    } else {
      // Handle permission not granted
      setState(() {
        loading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permission Required'),
            content: Text('Camera and microphone permissions are required to make a call.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.white,
        title: Center(
          child: Image.asset(
            "asset/MYTeleClinic.png",
            width: 594,
            height: 258,
          ),
        ),
      ),
      body: Stack(
        children: [


          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isMaximized = !isMaximized;
                });
              },
              child: Container(
                width: isMaximized ? MediaQuery.of(context).size.width : 200,
                height: isMaximized ? MediaQuery.of(context).size.height : 300,
                child: renderRemoteView(context),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Symptom'),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter your symptoms',
                    ),
                  ),
                  Text('Treatment'),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter the treatment details',
                    ),
                  ),
                  Text('Medication'),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter the medication details',
                    ),
                  ),
                ],
              ),
            ),
          ),
          _toolbar(),
        ],
      ),
    );
  }

  Widget renderRemoteView(BuildContext context) {
    if (_remoteUids.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: RtcLocalView.SurfaceView(
              channelId: dynamicChannelName,
            ),
          ),
          Text(
            'Waiting for others to join...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      );
    } else {
      if (_remoteUids.length == 1) {
        return Expanded(
          child: RtcRemoteView.SurfaceView(
            uid: _remoteUids[0],
            channelId: dynamicChannelName,
          ),
        );
      } else if (_remoteUids.length == 2) {
        return Column(
          children: [
            Expanded(
              child: RtcRemoteView.SurfaceView(
                uid: _remoteUids[0],
                channelId: dynamicChannelName,
              ),
            ),
            Expanded(
              child: RtcRemoteView.SurfaceView(
                uid: _remoteUids[1],
                channelId: dynamicChannelName,
              ),
            ),
          ],
        );
      } else {
        return Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 11 / 20,
                crossAxisSpacing: 5,
                mainAxisSpacing: 100,
              ),
              itemBuilder: (BuildContext context, index) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RtcRemoteView.SurfaceView(
                    uid: _remoteUids[index],
                    channelId: dynamicChannelName,
                  ),
                );
              },
              itemCount: _remoteUids.length,
            ),
          ),
        );
      }
    }
  }


  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {
              _onToggleMute();
            },
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(5),
            elevation: 2,
            fillColor: muted ? Colors.blue : Colors.white,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blue,
              size: 40,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              _onCallEnd();
            },
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(5),
            elevation: 2,
            fillColor: Colors.redAccent,
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 40,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              _onSwitchCamera();
            },
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(5),
            elevation: 2,
            fillColor: muted ? Colors.blue : Colors.white,
            child: Icon(
              Icons.switch_camera,
              color: muted ? Colors.white : Colors.blue,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onCallEnd() {
    _engine.leaveChannel();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SpecialistHomeScreen()));
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}

