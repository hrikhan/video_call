import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:video_calling_system/app_constants/app_constant.dart';

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
        connection: RtcConnection(channelId: AppConstants.channelName),
        canvas: VideoCanvas(uid: uid),
        // Keep TextureView so Flutter overlays (local preview/controls) remain visible.
        useAndroidSurfaceView: false,
      ),
    );
  }
}
