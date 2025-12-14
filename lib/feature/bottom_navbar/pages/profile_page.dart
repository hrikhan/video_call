import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/app_constants/utils/colors.dart';
import 'package:video_calling_system/app_constants/utils/global_textstyle.dart';
import 'package:video_calling_system/feature/auth/controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    return Container(
      color: AppColors.neutralBg,
      child: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          ),
          Obx(() {
            final user = auth.user.value;
            final displayName = user?.displayName?.trim();
            final email = user?.email;
            final initials =
                (displayName?.isNotEmpty == true
                        ? displayName!.substring(0, 1)
                        : (email?.isNotEmpty == true ? email![0] : 'U'))
                    .toUpperCase();
            final joinedLabel =
                'Joined: ${(user?.metadata.creationTime)?.toLocal().toIso8601String().split('T').first ?? 'Unknown'}';
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initials,
                        style: GlobalTextStyle.heading(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName?.isNotEmpty == true
                        ? displayName!
                        : email ?? 'Guest User',
                    style: GlobalTextStyle.heading(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email ?? 'No email linked',
                    style: GlobalTextStyle.body(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    joinedLabel,
                    style: GlobalTextStyle.body(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neutralCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account info',
                          style: GlobalTextStyle.heading(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Name',
                          value: displayName?.isNotEmpty == true
                              ? displayName!
                              : 'Not set',
                        ),
                        _InfoRow(
                          label: 'Email',
                          value: email ?? 'Not available',
                        ),
                        _InfoRow(
                          label: 'UID',
                          value: user?.uid ?? 'Unknown',
                          isMonospace: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.neutralCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        _ProfileTile(
                          icon: Icons.person_outline,
                          iconColor: AppColors.primary,
                          title: 'Account',
                          subtitle: 'Edit profile, change password',
                        ),
                        _ProfileTile(
                          icon: Icons.lock_outline,
                          iconColor: AppColors.secondary,
                          title: 'Privacy',
                          subtitle: 'Security and permissions',
                        ),
                        _ProfileTile(
                          icon: Icons.notifications_none,
                          iconColor: Colors.teal,
                          title: 'Notifications',
                          subtitle: 'Push and email alerts',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      'Privacy Policy • Terms & Conditions',
                      style: GlobalTextStyle.body(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => auth.signOut(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        'Log out',
                        style: GlobalTextStyle.heading(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GlobalTextStyle.body(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: isMonospace
                  ? const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    )
                  : GlobalTextStyle.body(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GlobalTextStyle.heading(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GlobalTextStyle.body(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.neutralBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GlobalTextStyle.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GlobalTextStyle.body(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}
