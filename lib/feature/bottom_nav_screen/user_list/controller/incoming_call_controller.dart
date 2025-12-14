import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/feature/auth/controllers/auth_controller.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/call_screen/controllers/call_controller.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/call_screen/screen/call_screen.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/call_session.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/user_service/create_user.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/widgets/incoming_call_sheet.dart';

class IncomingCallController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final UserService _service = UserService();

  StreamSubscription<CallSession?>? _subscription;
  CallSession? _pendingSession;
  bool _isDialogVisible = false;

  @override
  void onInit() {
    super.onInit();
    ever<User?>(_auth.user, _handleAuthChange);
    _handleAuthChange(_auth.user.value);
  }

  void _handleAuthChange(User? user) {
    _subscription?.cancel();
    _dismissDialog();
    if (user == null) return;
    _subscription =
        _service.listenForIncomingCall(user.uid).listen((callSession) {
      if (callSession == null) {
        _dismissDialog();
        return;
      }
      _pendingSession = callSession;
      _showIncomingSheet(callSession);
    });
  }

  void _showIncomingSheet(CallSession session) {
    if (_isDialogVisible) return;
    _isDialogVisible = true;
    SystemSound.play(SystemSoundType.alert);
    Get.dialog(
      IncomingCallSheet(
        session: session,
        onAccept: () => acceptCall(session),
        onDecline: () => declineCall(session),
      ),
      barrierDismissible: false,
    ).whenComplete(() {
      _isDialogVisible = false;
      _pendingSession = null;
    });
  }

  Future<void> acceptCall(CallSession session) async {
    await _service.acceptCall(session);
    _dismissDialog();
    if (Get.isRegistered<CallController>()) {
      await Get.delete<CallController>(force: true);
    }
    Get.put(CallController(session: session, isIncoming: true));
    Get.to(() => CallScreen(session: session));
  }

  Future<void> declineCall(CallSession session) async {
    await _service.declineCall(session);
    _dismissDialog();
  }

  void _dismissDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    _isDialogVisible = false;
    _pendingSession = null;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
