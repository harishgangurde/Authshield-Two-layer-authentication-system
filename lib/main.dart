// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/supabase_service.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

const String _supabaseUrl = 'https://kvgnjhqkkjginhcjgvcn.supabase.co';
const String _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2Z25qaHFra2pnaW5oY2pndmNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMDI3MDUsImV4cCI6MjA4OTc3ODcwNX0.ttg-cj88I5OqQNMCzu937TdREM9yUT0ocWOTnc9Ha_I';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // ✅ Load saved theme before app starts
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
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  await NotificationService().initialize();
  await NotificationService().requestPermissionsOnce();

  runApp(const SentinelApp());
}
