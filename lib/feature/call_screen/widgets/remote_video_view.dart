import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class RemoteVideoView extends StatelessWidget {
  final int uid;
  final RtcEngine rtcEngine;

  const RemoteVideoView({
    super.key,
    required this.uid,
    required this.rtcEngine,
  });

  @override
  Widget build(BuildContext context) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: rtcEngine,
        connection: RtcConnection(channelId: 'default'),
        canvas: VideoCanvas(uid: uid),
      ),
    );
  }
}
