import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/social_feed_service.dart';
import '../pages/social_post.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/call_screen/controllers/call_controller.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/call_screen/screen/call_screen.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/app_user.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/call_session.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/user_service/create_user.dart';

class SocialFeedController extends GetxController {
  final SocialFeedService _service = SocialFeedService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<SocialPost> posts = <SocialPost>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxnString callingPostId = RxnString();
  StreamSubscription<List<SocialPost>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenToFeed();
  }

  void _listenToFeed() {
    isLoading.value = true;
    _subscription ??= _service.streamPosts().listen(
      (event) {
        posts.assignAll(event);
        isLoading.value = false;
        errorMessage.value = '';
      },
      onError: (e) {
        errorMessage.value = 'Unable to load the social feed.';
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  String? get currentUserId => _auth.currentUser?.uid;

  bool canCallAuthor(SocialPost post) => currentUserId != post.authorId;

  Future<void> shareMedia({String? caption}) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Sign in required',
        'You need to be signed in to upload a photo.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: kIsWeb,
    );

    if (result == null || result.files.isEmpty) return;

    final PlatformFile file = result.files.first;
    if (!kIsWeb && (file.path == null || file.path!.isEmpty)) {
      Get.snackbar(
        'File error',
        'Unable to read the selected file.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isUploading.value = true;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseName =
          file.name.isNotEmpty ? file.name : 'photo_$timestamp.jpg';
      final sanitizedName =
          baseName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final storagePath = '${user.uid}_${timestamp}_$sanitizedName';
      final mimeType = _guessMime(file.extension);
      final mediaType = _isImageMime(mimeType) ? 'image' : 'video';

      String downloadUrl;
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('Selected file contains no data to upload.');
        }
        downloadUrl = await _service.uploadMedia(
          fileName: storagePath,
          bytes: file.bytes,
          mimeType: mimeType,
          resourceType: mediaType,
        );
      } else {
        downloadUrl = await _service.uploadMedia(
          fileName: storagePath,
          file: File(file.path!),
          mimeType: mimeType,
          resourceType: mediaType,
        );
      }

      await _service.createPost(
        authorId: user.uid,
        authorName:
            user.displayName ?? user.email?.split('@').first ?? 'Anonymous',
        mediaUrl: downloadUrl,
        mediaType: mediaType,
        caption: caption,
      );
      Get.snackbar(
        'Upload complete',
        mediaType == 'image'
            ? 'Your photo was shared successfully.'
            : 'Your video was shared successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Video upload failed: $e');
      Get.snackbar(
        'Upload failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  String _guessMime(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'mov':
        return 'video/quicktime';
      case 'mkv':
        return 'video/x-matroska';
      case 'avi':
        return 'video/x-msvideo';
      case 'webm':
        return 'video/webm';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'image/jpeg';
    }
  }

  bool _isImageMime(String mime) => mime.startsWith('image/');

  Future<void> requestRecipe(SocialPost post) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Sign in required',
        'You need to be signed in to start a call.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (currentUser.uid == post.authorId) {
      Get.snackbar(
        'This is your post',
        'You cannot call yourself for a recipe.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    callingPostId.value = post.id;
    try {
      final AppUser? author = await _userService.fetchUser(post.authorId);
      if (author == null) {
        Get.snackbar(
          'User unavailable',
          'We could not load the author details.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (!author.isOnline) {
        Get.snackbar(
          'User offline',
          'They appear to be offline right now.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      final CallSession session =
          await _userService.startCall(callee: author, caller: currentUser);
      if (Get.isRegistered<CallController>()) {
        await Get.delete<CallController>(force: true);
      }
      Get.put(CallController(session: session, isIncoming: false));
      Get.to(() => CallScreen(session: session));
    } catch (e) {
      Get.snackbar(
        'Call failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      callingPostId.value = null;
    }
  }
}
