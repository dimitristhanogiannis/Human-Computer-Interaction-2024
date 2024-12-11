import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class StatusBar extends StatefulWidget {
  final RtcEngine rtcEngine; // Pass the RtcEngine instance from parent
  StatusBar({required this.rtcEngine});

  @override
  _StatusBarState createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  bool micStatus = false; // Track microphone mute state

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: micStatus
                  ? Icon(
                      Icons.mic_off,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.mic,
                      color: Colors.white,
                    ),
              onPressed: toggleMute,
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.red,
            child: IconButton(
              icon: Icon(
                Icons.call_end,
                color: Colors.white,
              ),
              onPressed: disconnectCall,
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 20,
            child: IconButton(
              icon: Icon(
                Icons.switch_camera,
                color: Colors.white,
              ),
              onPressed: toggleCamera,
            ),
          ),
        ],
      ),
    );
  }

  void toggleMute() {
    setState(() {
      micStatus = !micStatus;
    });
    // Use the RtcEngine instance from the widget
    widget.rtcEngine.muteLocalAudioStream(micStatus);
  }

  void toggleCamera() {
    // Use the RtcEngine instance from the widget
    widget.rtcEngine.switchCamera();
  }

  void disconnectCall() {
    Navigator.pop(context);
  }
}
