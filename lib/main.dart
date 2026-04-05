import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/supabase_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/api_service.dart';
import 'firebase_options.dart';
import 'app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.showFirebaseNotification(message);

  print('📩 Background message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env loaded successfully");
  } catch (e) {
    print("❌ Error loading .env file: $e");
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("🔥 Firebase initialized successfully");

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  await loadSavedTheme();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1520),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SupabaseService.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  // ✅ Load saved ESP32 IP / Base URL
  await ApiService().loadBaseUrl();

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissionsOnce();

  runApp(const SentinelApp());
}
