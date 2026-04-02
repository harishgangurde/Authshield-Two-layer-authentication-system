// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/supabase_service.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before any async calls
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Load environment variables from the .env file
    await dotenv.load(fileName: ".env");
    print("✅ .env loaded successfully");
  } catch (e) {
    print("❌ Error loading .env file: $e");
    // Fallback or exit if .env is critical
  }

  // 3. Load saved theme (assuming this is a global function in your project)
  await loadSavedTheme();

  // 4. Lock orientation to Portrait for security/UI consistency
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 5. Configure System UI (Status bar & Navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1520),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 6. Initialize Supabase using values from .env
  await SupabaseService.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  // 7. Setup Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissionsOnce();

  // 8. Launch the App
  runApp(const SentinelApp());
}
