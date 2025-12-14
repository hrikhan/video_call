import 'dart:math';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling_system/app_constants/app_constant.dart';
import 'package:video_calling_system/services/agora_services.dart';
import 'dart:async';

class CallController extends GetxController {
  final AgoraService _agoraService = AgoraService();

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

  AgoraService get agora => _agoraService;

  @override
  void onInit() {
    super.onInit();
    _remoteWatcher = ever<int?>(_agoraService.remoteUid,
        (uid) => uid != null ? _startCallTimer() : _stopCallTimer());
    initCall();
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
        token: AppConstants.tempToken,
        channelId: AppConstants.channelName,
        uid: uid,
      );
      isJoined.value = true;
      print("Successfully joined channel with uid: $uid");
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

  void leaveCall() async {
    _stopCallTimer(reset: true);
    localUid.value = null;
    await _agoraService.leaveChannel();
    isJoined.value = false;
    Get.back();
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

  @override
  void onClose() {
    _stopCallTimer();
    _remoteWatcher?.dispose();
    super.onClose();
  }
}
