import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:video_calling_system/app.dart';
import 'package:video_calling_system/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
