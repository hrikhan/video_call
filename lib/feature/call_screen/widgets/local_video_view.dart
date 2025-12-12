import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class LocalVideoView extends StatelessWidget {
  const LocalVideoView({
    super.key,
    this.width = 120,
    this.height = 160,
    required this.rtcEngine,
  });

  final double width;
  final double height;
  final RtcEngine rtcEngine;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: rtcEngine,
          canvas: const VideoCanvas(uid: 0),
        ),
      ),
    );
  }
}
