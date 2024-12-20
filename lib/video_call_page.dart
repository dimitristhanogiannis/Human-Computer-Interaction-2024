import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

// Fill in the app ID obtained from the Agora Console
const appId = "4d3c0d2539e849ffa231cf29a7abe5c4";


class VideoCallPage extends StatefulWidget {
  final String channelName;
  final String token;

  const VideoCallPage({
    Key? key,
    required this.channelName,
    required this.token,
  }) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Get permissions
    await [Permission.microphone, Permission.camera].request();

    // Create RtcEngine instance
    _engine = await createAgoraRtcEngine();

    // Initialize RtcEngine
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
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        debugPrint("remote user $remoteUid left channel");
        setState(() {
          _remoteUid = null;
        });
      },
      onError: (ErrorCodeType err, String msg) {
        debugPrint('Error: $err, $msg');
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agora error: $msg')),
        );
      },
    ));

    try {
      await _engine.enableVideo();
      await _engine.startPreview();

      // Join channel with the token from the server
      await _engine.joinChannel(
        token: widget.token,
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
    } catch (e) {
      debugPrint('Error initializing Agora: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize video call: $e')),
      );
    }
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