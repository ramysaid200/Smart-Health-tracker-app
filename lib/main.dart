import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // Continue anyway to allow UI testing without Firebase
  }

  // Initialize local services
  try {
    await StorageService.instance.init();
    await NotificationService.instance.init();

    // Schedule daily reminders
    if (StorageService.instance.notificationsEnabled) {
      await NotificationService.instance.scheduleMorningReminder();
      await NotificationService.instance.scheduleEveningReminder();
    }
  } catch (e) {
    debugPrint("Local services initialization failed: $e");
  }

  runApp(const SmartHealthTrackerApp());
}
