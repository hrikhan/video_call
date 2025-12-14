import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/app_constants/app_constant.dart';

class AgoraService {
  RtcEngine? _engine;
  var isInitialized = false.obs;

  // Using RxnInt so UI reacts when remote user joins
  var remoteUid = RxnInt();

  RtcEngine get engine {
    final current = _engine;
    if (current == null || !isInitialized.value) {
      throw Exception('AgoraService not initialized. Call initialize() first.');
    }
    return current;
  }

  Future<void> initialize() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: AppConstants.appId));
    await _engine!.enableVideo();
    await _engine!.enableLocalVideo(true);
    await _engine!.setVideoEncoderConfiguration(
      VideoEncoderConfiguration(
        dimensions: const VideoDimensions(width: 960, height: 540),
        frameRate: FrameRate.frameRateFps30.value(),
        orientationMode: OrientationMode.orientationModeFixedPortrait,
      ),
    );
    await _engine!.startPreview();

    // Event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onError: (ErrorCodeType err, String msg) {
          print("Agora error $err: $msg");
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          print("Remote user joined: $uid");
          remoteUid.value = uid;
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
              print("Remote user left: $uid");
              if (remoteUid.value == uid) remoteUid.value = null;
            },
        onFirstLocalVideoFrame: (VideoSourceType source, int width, int height, int elapsed) {
          print("First local video frame: ${width}x$height after ${elapsed}ms");
        },
        onLocalVideoStateChanged: (
          VideoSourceType source,
          LocalVideoStreamState state,
          LocalVideoStreamReason reason,
        ) {
          print("Local video state: $state reason: $reason source: $source");
        },
        onJoinChannelSuccess:
            (RtcConnection connection, int elapsed) async {
              print(
                  "Joined channel: ${connection.channelId}, local uid: ${connection.localUid}");
              await _engine?.startPreview();
            },
        onConnectionStateChanged:
            (
              RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason,
            ) {
              print("Connection state: $state, reason: $reason");
            },
      ),
    );

    isInitialized.value = true;
  }

  Future<void> joinChannel({
    required String token,
    String? channelId,
    int uid = 0,
  }) async {
    // Make sure we publish and subscribe in a communication channel.
    const options = ChannelMediaOptions(
      channelProfile: ChannelProfileType.channelProfileCommunication,
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      publishCameraTrack: true,
      publishMicrophoneTrack: true,
      autoSubscribeAudio: true,
      autoSubscribeVideo: true,
    );

    // Bind local preview with uid 0 for consistency with AgoraVideoView
    await _engine!.setupLocalVideo(const VideoCanvas(
      uid: 0,
      sourceType: VideoSourceType.videoSourceCameraPrimary,
    ));
    await _engine!.startPreview();

    await _engine!.joinChannel(
      token: token,
      channelId: channelId ?? AppConstants.channelName,
      uid: uid,
      options: options,
    );
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
    remoteUid.value = null;
    await _engine?.release();
    _engine = null;
    isInitialized.value = false;
  }

  Future<void> toggleMute(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  Future<void> toggleCamera(bool cameraOff) async {
    final enable = !cameraOff;
    await _engine?.enableLocalVideo(enable);
    if (enable) {
      await _engine?.startPreview();
    } else {
      await _engine?.stopPreview();
    }
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }
}
