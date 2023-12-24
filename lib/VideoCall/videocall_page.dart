import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:my_teleclinic/Specialists/specialist_home.dart';

class CallPage extends StatefulWidget {
  final String channelName;

  const CallPage({Key? key, required this.channelName}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    initializeAgora();
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
        print("Channel joined");
      },
      userJoined: (uid, elapsed) {
        print("Userjoined: $uid");
        setState(() {
          _remoteUids.add(uid);
        });
      },
      userOffline: (uid, elapsed) {
        print("Useroffline: $uid");
        setState(() {
          _remoteUids.remove(uid);
        });
      },
    ));
    await _engine.joinChannel(null, widget.channelName, null, 0);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (loading)
          ? const Center(
            child: CircularProgressIndicator(),
      )
          : Stack(
            children: [
            Center(
              child: renderRemoteView(context),
          ),
            Positioned(
              top: yPosition,
              left: xPosition,
              child: GestureDetector(
                onPanUpdate: (tapInfo) {
                  setState(() {
                    xPosition += tapInfo.delta.dx;
                    yPosition += tapInfo.delta.dy;
                  });
              },
                child: Container(
                  width: 100,
                  height: 130,
                  child: const RtcLocalView.SurfaceView(),
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
          channelId: widget.channelName,
        );
      } else if (_remoteUids.length == 2) {
        return Column(
          children: [
            RtcRemoteView.SurfaceView(
              uid: _remoteUids[0],
              channelId: widget.channelName,
            ),
            RtcRemoteView.SurfaceView(
              uid: _remoteUids[1],
              channelId: widget.channelName,
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
                  channelId: widget.channelName,
                ),
              );
            },
            itemCount: _remoteUids.length,
          ),
        );
      }
    } else {
      return const Text("Waiting for other user to join");
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
