import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:camconnect/video_call_utils/AppID.dart';
import 'package:flutter/material.dart';


class VideoCall extends StatefulWidget {
  final String channelName;
  VideoCall(this.channelName);
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  late final RtcEngine _engine; // Instance of RtcEngine

  @override
  void dispose() {
    // Clear users and properly dispose of RtcEngine instance
    _users.clear();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize Agora SDK
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    await _engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await _engine.joinChannel(
      token: "",
      channelId: widget.channelName,
      options: const ChannelMediaOptions(),
      uid: 0,
    );
  }

  /// Add Agora SDK instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = createAgoraRtcEngine(); // Create the RtcEngine instance
    await _engine.initialize(
      RtcEngineContext(
        appId: APP_ID,
      ),
    );
    await _engine.enableVideo();
  }

  /// Agora event handlers
  void _addAgoraEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (ErrorCodeType error, String message) {
          setState(() {
            final info = 'onError: $message';
            _infoStrings.add(info);
          });
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            final info =
                'onJoinChannel: ${connection.channelId}, uid: ${connection.localUid}';
            _infoStrings.add(info);
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            _infoStrings.add('onLeaveChannel');
            _users.clear();
          });
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          setState(() {
            final info = 'userJoined: $uid';
            _infoStrings.add(info);
            _users.add(uid);
          });
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          setState(() {
            final info = 'userOffline: $uid, reason: $reason';
            _infoStrings.add(info);
            _users.remove(uid);
          });
        },
        onFirstRemoteVideoFrame: (RtcConnection connection, int uid, int width,
            int height, int elapsed) {
          setState(() {
            final info = 'firstRemoteVideo: $uid ${width}x $height';
            _infoStrings.add(info);
          });
        },
      ),
    );
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraVideoView> list = [
      AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      ),
    ];
    _users.forEach((int uid) {
      list.add(
        AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: uid),
            connection: const RtcConnection(channelId: "yourChannelId"),
          ),
        ),
      );
    });
    return list;
  }

  /// Remote video view wrapper
  Widget _videoView(view) {
    return Container(height: 651.4, child: view);
  }

  /// Local video view row wrapper
  Widget _localVideoView(view) {
    return Container(
      height: 150,
      width: 120,
      child: view,
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Stack(
          children: <Widget>[
            _videoView(views[1]),
            Align(
                alignment: Alignment(0.95, -0.95),
                child: _localVideoView(views[0])),
          ],
        ));
      default:
    }
    return Container();
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          _viewRows(),
          _panel(),
        ],
      ),
    );
  }
}
