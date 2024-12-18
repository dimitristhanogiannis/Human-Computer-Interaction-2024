import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

// Fill in the app ID obtained from the Agora Console
const appId = "4d3c0d2539e849ffa231cf29a7abe5c4";

// Replace with your temporary token generated in the Agora Console
const token =
    "007eJxTYEhxeXX6qJ91U4JZxb1ms5dx62Nk/ogpMv1q73DTTr6jm6vAYJJinGyQYmRqbJlqYWKZlpZoZGyYnGZkmWiemJRqmmySsiMpvSGQkcFgSQkjIwMEgvjsDMkZiXl5qTkMDAB71x/h";

class VideoCallPage extends StatefulWidget {
  final String channelName; // Add channelName parameter

  const VideoCallPage({Key? key, required this.channelName}) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _isMuted = false; // Track mute state
  bool _isCameraOff = false; // Track camera state

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Get microphone and camera permissions
    await [Permission.microphone, Permission.camera].request();

    // Create RtcEngine instance
    _engine = await createAgoraRtcEngine();

    // Initialize RtcEngine and set the channel profile to live broadcasting
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint('local user ${connection.localUid} joined');
        setState(() {
          _localUserJoined = true;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint("remote user $remoteUid joined");
        setState(() {
          _remoteUid = remoteUid;
        });
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        debugPrint("remote user $remoteUid left channel");
        setState(() {
          _remoteUid = null;
        });
      },
    ));

    await _engine.enableVideo();
    await _engine.startPreview();

    // Join the channel dynamically with the channelName passed from MatchesScreen
    await _engine.joinChannel(
      token: token,
      channelId: widget.channelName,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
      uid: 0,
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color deepPurple = Color(0xFF7B1FA2);

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Video Call',
            style: TextStyle(
              fontSize: 30,
              color: deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _localUserJoined
                  ? (_isCameraOff
                      ? Container(
                          color: Colors.grey,
                          child: const Center(
                            child: Icon(Icons.videocam_off, size: 40),
                          ),
                        )
                      : AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        ))
                  : const Center(child: CircularProgressIndicator()),
            ),
            Expanded(
              child: _remoteVideo(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Mic Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                      _engine.muteLocalAudioStream(_isMuted);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepPurple,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                    ),
                    child: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                  // Camera Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isCameraOff = !_isCameraOff;
                      });
                      _engine.enableLocalVideo(!_isCameraOff);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepPurple,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                    ),
                    child: Icon(
                      _isCameraOff ? Icons.videocam_off : Icons.videocam,
                      color: Colors.white,
                    ),
                  ),
                  // End Call Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // End call (go back)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection:
              RtcConnection(channelId: widget.channelName), // Use dynamic channel name
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Please wait for user to join',
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}