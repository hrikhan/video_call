import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/user_service/create_user.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever<User?>(user, _handleAuthChange);
  }

  void _handleAuthChange(User? firebaseUser) {
    if (firebaseUser != null) {
      _userService.updatePresence(firebaseUser.uid, isOnline: true);
    }
  }

  Future<void> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    _setLoading(true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final createdUser = credential.user;
      if (displayName != null && displayName.trim().isNotEmpty) {
        await createdUser?.updateDisplayName(displayName.trim());
      }
      if (createdUser != null) {
        await _userService.ensureUserDocument(
          createdUser,
          displayName: displayName,
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final signedIn = credential.user;
      if (signedIn != null) {
        await _userService.ensureUserDocument(signedIn);
        await _userService.updatePresence(signedIn.uid, isOnline: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _userService.updatePresence(uid, isOnline: false);
    }
    await _auth.signOut();
  }

  void _setLoading(bool value) {
    isLoading.value = value;
  }
}

class LoginFormController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class SignupFormController extends GetxController {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
