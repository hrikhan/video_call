import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/feature/auth/controllers/auth_controller.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/app_user.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/call_session.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/user_service/create_user.dart';

class UserListController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final UserService _service = UserService();

  final RxList<AppUser> users = <AppUser>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<List<AppUser>>? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    ever<User?>(_auth.user, _handleAuthChange);
    _handleAuthChange(_auth.user.value);
  }

  void _handleAuthChange(User? user) {
    _userSubscription?.cancel();
    if (user == null) {
      users.clear();
      isLoading.value = false;
      errorMessage.value = '';
      return;
    }
    isLoading.value = true;
    _userSubscription = _service.streamOtherUsers(user.uid).listen(
      (data) {
        users.assignAll(data);
        errorMessage.value = '';
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  Future<CallSession?> startCall(AppUser callee) async {
    final currentUser = _auth.user.value;
    if (currentUser == null) return null;
    try {
      return await _service.startCall(callee: callee, caller: currentUser);
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }
}
