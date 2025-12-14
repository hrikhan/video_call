import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/call_session.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/user_service/create_user.dart';
import 'package:video_calling_system/services/agora_services.dart';

class CallController extends GetxController {
  CallController({
    required this.session,
    this.isIncoming = false,
  });

  final CallSession session;
  final bool isIncoming;
  final AgoraService _agoraService = AgoraService();
  final UserService _userService = UserService();

  var isJoined = false.obs;
  var callDuration = "00:00".obs;
  var isMuted = false.obs;
  var isCameraOff = false.obs;
  var isFrontCamera = true.obs;
  var permissionsGranted = false.obs;
  final RxnInt localUid = RxnInt();

  Timer? _callTimer;
  bool _timerRunning = false;
  bool _isInitializing = false;
  int _elapsedSeconds = 0;
  Worker? _remoteWatcher;
  StreamSubscription<CallSession?>? _sessionWatcher;
  bool _hasLeftScreen = false;

  AgoraService get agora => _agoraService;

  @override
  void onInit() {
    super.onInit();
    _remoteWatcher = ever<int?>(_agoraService.remoteUid,
        (uid) => uid != null ? _startCallTimer() : _stopCallTimer());
    _sessionWatcher = _userService.watchCall(session.id).listen(_onSession);
  }

  void _startCallTimer() {
    if (_timerRunning) return;
    _timerRunning = true;
    _elapsedSeconds = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      callDuration.value = _formatDuration(_elapsedSeconds);
    });
  }

  void _stopCallTimer({bool reset = false}) {
    _callTimer?.cancel();
    _timerRunning = false;
    if (reset) {
      _elapsedSeconds = 0;
      callDuration.value = "00:00";
    }
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> initCall() async {
    if (_isInitializing) return;
    _isInitializing = true;
    try {
      if (_agoraService.isInitialized.value) {
        await _agoraService.leaveChannel();
      }
      final granted = await _ensurePermissions();
      if (!granted) {
        _isInitializing = false;
        return;
      }
      callDuration.value = "00:00";
      isMuted.value = false;
      isCameraOff.value = false;
      isFrontCamera.value = true;
      await _agoraService.initialize();
      final uid = Random().nextInt(100000);
      localUid.value = uid;
      await _agoraService.joinChannel(
        token: session.token,
        channelId: session.channelName,
        uid: uid,
      );
      isJoined.value = true;
      print("Successfully joined channel ${session.channelName} with uid: $uid");
    } catch (e) {
      print("Error initializing call: $e");
    } finally {
      _isInitializing = false;
    }
  }

  Future<bool> _ensurePermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    final granted = statuses.values.every((status) => status.isGranted);
    permissionsGranted.value = granted;
    if (!granted) {
      Get.snackbar(
        "Permissions needed",
        "Enable camera and microphone to show your video.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return granted;
  }

  Future<void> leaveCall({bool triggeredByRemote = false}) async {
    if (_hasLeftScreen) return;
    _hasLeftScreen = true;
    _stopCallTimer(reset: true);
    localUid.value = null;
    if (_agoraService.isInitialized.value) {
      await _agoraService.leaveChannel();
    }
    isJoined.value = false;
    if (!triggeredByRemote) {
      await _userService.endCall(session);
    }
    Get.close(1);
    Future.microtask(() {
      if (Get.isRegistered<CallController>()) {
        Get.delete<CallController>(force: true);
      }
    });
  }

  void ensureCallStarted() {
    if (!isJoined.value && !_isInitializing) {
      initCall();
    }
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    _agoraService.toggleMute(isMuted.value);
  }

  void toggleCamera() {
    isCameraOff.value = !isCameraOff.value;
    _agoraService.toggleCamera(isCameraOff.value);
  }

  void switchCamera() {
    isFrontCamera.value = !isFrontCamera.value;
    _agoraService.switchCamera();
  }

  void _onSession(CallSession? updated) {
    if (updated == null) {
      if (!_hasLeftScreen) {
        leaveCall(triggeredByRemote: true);
      }
      return;
    }
    if (updated.status == CallStatus.declined && !isIncoming) {
      Get.snackbar('Call declined',
          '${session.calleeName} is currently unavailable.');
      leaveCall(triggeredByRemote: true);
    } else if (updated.status == CallStatus.ended && !_hasLeftScreen) {
      leaveCall(triggeredByRemote: true);
    }
  }

  @override
  void onClose() {
    _stopCallTimer();
    _remoteWatcher?.dispose();
    _sessionWatcher?.cancel();
    super.onClose();
  }
}
