import 'dart:math';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:my_teleclinic/Specialists/Profile/specialist_home.dart';

//letak kat CallNow
//SizedBox(height 30,),
//InkWell(
//onTap:() async{
//await [Permission.camera, Permission.microphone].request().then((value){
//Navigator.push(context, MaterialPageRoute(builder: (context)=>CallPage(channelName: _controller.text.trim())));
//});
//},


class CallPage extends StatefulWidget {
  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late RtcEngine _engine;
  bool loading = false;
  String appId = "9f2b77f5677646c89d25869fb5db3bcf";
  List<int> _remoteUids = [];
  double xPosition = 0;
  double yPosition = 0;
  bool muted = false;
  bool isMaximized = false;
  late String dynamicChannelName; // New dynamic channel name variable

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
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    await _engine.enableVideo();
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
    if (_remoteUids.isNotEmpty) {
      if (_remoteUids.length == 1) {
        return RtcRemoteView.SurfaceView(
          uid: _remoteUids[0],
          channelId: dynamicChannelName,
        );
      } else if (_remoteUids.length == 2) {
        return Column(
          children: [
            RtcRemoteView.SurfaceView(
              uid: _remoteUids[0],
              channelId: dynamicChannelName,
            ),
            RtcRemoteView.SurfaceView(
              uid: _remoteUids[1],
              channelId: dynamicChannelName,
            ),
          ],
        );
      } else {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 11 / 20,
              crossAxisSpacing: 5,
              mainAxisSpacing: 10,
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
        );
      }
    } else {
      return const Text("Waiting for other users to join");
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
