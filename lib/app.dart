import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/feature/auth/controllers/auth_controller.dart';
import 'package:video_calling_system/feature/auth/screen/login_screen.dart';
import 'package:video_calling_system/feature/bottom_navbar/screen/bottom_navbar_screen.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/controller/incoming_call_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(IncomingCallController(), permanent: true);
    return GetMaterialApp(
      title: 'oplo Olpoi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == null) {
            return LoginScreen();
          }
          return BottomNavbarScreen();
        },
      ),
    );
  }
}
