import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/app_constants/utils/colors.dart';
import 'package:video_calling_system/app_constants/utils/global_textstyle.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/call_screen/controllers/call_controller.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/call_screen/screen/call_screen.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/controller/user_list_controller.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/app_user.dart';

class CallHubPage extends StatelessWidget {
  CallHubPage({super.key});

  final UserListController controller = Get.put(UserListController());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutralBg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            Row(
              children: [
                Text(
                  'Your Contacts',
                  style: GlobalTextStyle.heading(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 14),

            const SizedBox(height: 10),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    controller.errorMessage.value,
                    style: GlobalTextStyle.body(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (controller.users.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No other users are online yet. Share the app to start calling!',
                    textAlign: TextAlign.center,
                    style: GlobalTextStyle.body(color: AppColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: controller.users
                    .map(
                      (user) => _ContactTile(
                        user: user,
                        onCall: () => _startCall(user),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _startCall(AppUser user) async {
    final session = await controller.startCall(user);
    if (session == null) {
      Get.snackbar(
        'Unable to start call',
        'Please try again in a moment.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (Get.isRegistered<CallController>()) {
      await Get.delete<CallController>(force: true);
    }
    Get.put(CallController(session: session, isIncoming: false));
    Get.to(() => CallScreen(session: session));
  }
}

class _ContactTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onCall;

  const _ContactTile({required this.user, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.neutralCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Text(
            (user.displayName.isNotEmpty ? user.displayName[0] : '?')
                .toUpperCase(),
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        title: Text(
          user.displayName,
          style: GlobalTextStyle.heading(fontSize: 15, color: Colors.black87),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: user.isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              user.isOnline ? 'Online' : 'Offline',
              style: GlobalTextStyle.body(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: AppColors.primary),
          onPressed: user.isOnline ? onCall : null,
        ),
      ),
    );
  }
}
