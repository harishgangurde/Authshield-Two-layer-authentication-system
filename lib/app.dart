// lib/app.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'features/splash/splash_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/alerts/alerts_screen.dart';
import 'features/owners/owners_screen.dart';
import 'features/owners/add_owner_screen.dart';
import 'features/history/history_screen.dart';
import 'features/chatbot/chatbot_screen.dart';
import 'features/settings/settings_screen.dart';

// ✅ Global notifier — changing this rebuilds the entire app
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.dark);

// Call this from settings screen to toggle theme
void setAppTheme(bool isDark) async {
  appThemeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(AppConstants.keyThemeMode, isDark);
}

// Load saved theme on startup
Future<void> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool(AppConstants.keyThemeMode) ?? true;
  appThemeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

class SentinelApp extends StatelessWidget {
  const SentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: '/splash',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/splash':
                return MaterialPageRoute(builder: (_) => const SplashScreen());
              case '/dashboard':
                return MaterialPageRoute(
                  builder: (_) => const MainShell(index: 0),
                );
              case '/alerts':
                return MaterialPageRoute(
                  builder: (_) => const MainShell(index: 1),
                );
              case '/owners':
                return MaterialPageRoute(
                  builder: (_) => const MainShell(index: 2),
                );
              case '/owners/add':
                return MaterialPageRoute(
                  builder: (_) => const AddOwnerScreen(),
                );
              case '/chat':
                return MaterialPageRoute(
                  builder: (_) => const MainShell(index: 3),
                );
              case '/settings':
                return MaterialPageRoute(
                  builder: (_) => const MainShell(index: 4),
                );
              case '/history':
                return MaterialPageRoute(builder: (_) => const HistoryScreen());
              default:
                return MaterialPageRoute(
                  builder: (_) => const MainShell(index: 0),
                );
            }
          },
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  final int index;
  const MainShell({super.key, this.index = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _initFCM();
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    AlertsScreen(),
    OwnersScreen(),
    ChatbotScreen(),
    SettingsScreen(),
  ];

  Future<void> _initFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // 🔐 Ask permission (Android 13+)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print(
          '🔔 Notification permission status: ${settings.authorizationStatus}');

      // 🔥 Get current FCM token
      final token = await messaging.getToken();
      print('🔥 FCM TOKEN: $token');

      if (token != null) {
        await _supabaseService.saveDeviceToken(token);
      }

      // 🔄 Save refreshed token automatically
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print('🔄 FCM TOKEN REFRESHED: $newToken');
        await _supabaseService.saveDeviceToken(newToken);
      });

      // 📩 Foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('📩 Foreground Firebase message received');
        print(
            '📩 Title: ${message.notification?.title ?? message.data['title']}');
        print('📩 Body: ${message.notification?.body ?? message.data['body']}');
        print('📩 Data: ${message.data}');

        await NotificationService().showFirebaseNotification(message);
      });

      // 👆 App opened from notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print(
            '📲 Notification tapped: ${message.notification?.title ?? message.data['title']}');
      });

      // 🚀 App launched from terminated state via notification
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        print('🚀 App opened from terminated notification');
        print(
            '🚀 Title: ${initialMessage.notification?.title ?? initialMessage.data['title']}');
      }
    } catch (e) {
      print('❌ FCM init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.navBg
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.bgCardLight
                : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.grid_view_rounded, 'DASHBOARD'),
              _navItem(1, Icons.shield_outlined, 'ALERTS'),
              _navItem(2, Icons.people_outline, 'OWNERS'),
              _navItem(3, Icons.smart_toy_outlined, 'AI CHAT'),
              _navItem(4, Icons.settings_outlined, 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                  ? AppColors.navActive
                  : AppColors.primary.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? (isDark ? Colors.white : AppColors.primary)
                  : (isDark ? AppColors.textMuted : Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 8,
                color: isActive
                    ? (isDark ? Colors.white : AppColors.primary)
                    : (isDark ? AppColors.textMuted : Colors.grey.shade500),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
