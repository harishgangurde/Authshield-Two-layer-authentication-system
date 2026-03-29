// lib/core/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _alarmRingtone = 'default_security';
  String _criticalAlertTone = 'loud_alert';

  static const String _permissionKey = 'notification_permission_asked';

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // we handle manually
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initSettings);
  }

  // ✅ Only asks permission ONCE — never again after first time
  Future<void> requestPermissionsOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool(_permissionKey) ?? false;

    if (!alreadyAsked) {
      await _requestPermissions();
      await prefs.setBool(_permissionKey, true);
    }
  }

  Future<void> _requestPermissions() async {
    // Android 13+ notification permission
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // iOS permission
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void setRingtones({String? alarm, String? critical}) {
    if (alarm != null) _alarmRingtone = alarm;
    if (critical != null) _criticalAlertTone = critical;
  }

  Future<void> showIntrusionAlert({
    required String title,
    required String body,
    bool isCritical = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'intrusion_channel',
      'Intrusion Alerts',
      channelDescription: 'Critical security intrusion notifications',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFEF4444),
      enableVibration: true,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );

    if (isCritical) await playAlarm(isCritical: true);
  }

  Future<void> showAccessGranted(String ownerName) async {
    const androidDetails = AndroidNotificationDetails(
      'access_channel',
      'Access Notifications',
      channelDescription: 'Access granted/denied notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(
      0,
      'Access Granted',
      '$ownerName has been granted access',
      details,
    );
  }

  Future<void> playAlarm({bool isCritical = false}) async {
    try {
      final tone = isCritical ? _criticalAlertTone : _alarmRingtone;
      await _audioPlayer.play(AssetSource('audio/$tone.mp3'));
    } catch (_) {}
  }

  Future<void> stopAlarm() async {
    await _audioPlayer.stop();
  }
}
