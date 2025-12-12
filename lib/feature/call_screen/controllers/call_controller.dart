import 'dart:math';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling_system/services/agora_services.dart';
import 'dart:async';

class CallController extends GetxController {
  final AgoraService _agoraService = AgoraService();

  var isJoined = false.obs;
  var callDuration = "00:00".obs;
  var isMuted = false.obs;
  var isCameraOff = false.obs;
  var isFrontCamera = true.obs;

  late Timer _callTimer;
  int _elapsedSeconds = 0;

  AgoraService get agora => _agoraService;

  @override
  void onInit() {
    super.onInit();
    initCall();
    _startCallTimer();
  }

  void _startCallTimer() {
    _elapsedSeconds = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      callDuration.value = _formatDuration(_elapsedSeconds);
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> initCall() async {
    try {
      await [Permission.camera, Permission.microphone].request();
      await _agoraService.initialize();
      final uid = Random().nextInt(100000);
      await _agoraService.joinChannel(uid: uid);
      isJoined.value = true;
      print("Successfully joined channel with uid: $uid");
    } catch (e) {
      print("Error initializing call: $e");
    }
  }

  void leaveCall() async {
    _callTimer.cancel();
    await _agoraService.leaveChannel();
    isJoined.value = false;
    Get.back();
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
    if (_callTimer.isActive) _callTimer.cancel();
    super.onClose();
  }
}
