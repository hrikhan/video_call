import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/app_constants/utils/colors.dart';
import 'package:video_calling_system/app_constants/utils/global_textstyle.dart';
import 'package:video_calling_system/feature/bottom_navbar/controller/bottom_nav_controller.dart';
import 'package:video_calling_system/feature/bottom_navbar/pages/call_hub_page.dart';
import 'package:video_calling_system/feature/bottom_navbar/pages/profile_page.dart';
import 'package:video_calling_system/feature/bottom_navbar/pages/social_page.dart';

class BottomNavbarScreen extends StatelessWidget {
  BottomNavbarScreen({super.key});

  final BottomNavController navController = Get.put(BottomNavController());

  final List<Widget> _pages = [
    const SocialPage(),
    CallHubPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.public, label: 'Social'),
      _NavItem(icon: Icons.videocam_rounded, label: 'Calls'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Scaffold(
      body: Obx(() => _pages[navController.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.neutralCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              )
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final selected = navController.currentIndex.value == index;
              final item = items[index];
              return Expanded(
                child: GestureDetector(
                  onTap: () => navController.changeTab(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: selected ? AppColors.primary : Colors.black45,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GlobalTextStyle.body(
                            color: selected ? AppColors.primary : Colors.black54,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
