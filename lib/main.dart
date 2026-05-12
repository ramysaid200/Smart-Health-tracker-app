import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local services
  await StorageService.instance.init();
  await NotificationService.instance.init();

  // Schedule daily reminders
  if (StorageService.instance.notificationsEnabled) {
    await NotificationService.instance.scheduleMorningReminder();
    await NotificationService.instance.scheduleEveningReminder();
  }

  runApp(const SmartHealthTrackerApp());
}
