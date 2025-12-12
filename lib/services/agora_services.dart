import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/app_constants/app_constant.dart';

class AgoraService {
  late final RtcEngine _engine;
  var isInitialized = false.obs;

  // Using RxnInt so UI reacts when remote user joins
  var remoteUid = RxnInt();

  RtcEngine get engine {
    if (!isInitialized.value) {
      throw Exception('AgoraService not initialized. Call initialize() first.');
    }
    return _engine;
  }

  Future<void> initialize() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: AppConstants.appId));
    await _engine.enableVideo();

    // Event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          print("Remote user joined: $uid");
          remoteUid.value = uid;
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
              print("Remote user left: $uid");
              if (remoteUid.value == uid) remoteUid.value = null;
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

  Future<void> joinChannel({int uid = 0}) async {
    // This is a temporary token for testing purposes. In a production environment,
    // you should generate tokens from a server.
    const String temporaryToken =
        "007eJxTYLh+OtvFsnnS6e2FOs+YdrvfKFsw50HDrdNCXXyvIp5Z3RJWYDA2NzCzNDAwMUlNszRJSTNNMjUxMEu2NE1JNbZItTQwWbLdOrMhkJFB1ekGIyMDBIL43AwlqcUlzhmJeXmpOQwMAKTmIxw=";
    await _engine.joinChannel(
      token: temporaryToken,
      channelId: AppConstants.channelName,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
    remoteUid.value = null;
    await _engine.release();
  }

  Future<void> toggleMute(bool muted) async {
    await _engine.muteLocalAudioStream(muted);
  }

  Future<void> toggleCamera(bool enabled) async {
    await _engine.enableLocalVideo(!enabled);
  }

  Future<void> switchCamera() async {
    await _engine.switchCamera();
  }
}
