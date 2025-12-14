import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:video_calling_system/app_constants/app_constant.dart';

class LocalVideoView extends StatelessWidget {
  const LocalVideoView({
    super.key,
    this.width = 120,
    this.height = 160,
    required this.rtcEngine,
    required this.uid,
  });

  final double width;
  final double height;
  final RtcEngine rtcEngine;
  final int uid;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: rtcEngine,
          canvas: VideoCanvas(
            // Use 0 for local preview binding to avoid device-specific UID issues.
            uid: 0,
            renderMode: RenderModeType.renderModeHidden,
            sourceType: VideoSourceType.videoSourceCameraPrimary,
            mirrorMode: VideoMirrorModeType.videoMirrorModeAuto,
          ),
          // Use a TextureView so it can be clipped/rounded in the UI.
          useAndroidSurfaceView: false,
          useFlutterTexture: true,
        ),
      ),
    );
  }
}
