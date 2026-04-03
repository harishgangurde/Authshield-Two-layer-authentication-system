// lib/core/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);

    // ✅ Create notification channel (VERY IMPORTANT for Android)
    const channel = AndroidNotificationChannel(
      'intrusion_channel',
      'Intrusion Alerts',
      description: 'Critical security alerts',
      importance: Importance.max,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestPermissionsOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool(_permissionKey) ?? false;

    if (!alreadyAsked) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await prefs.setBool(_permissionKey, true);
    }
  }

  // 🔥 THIS IS THE IMPORTANT NEW FUNCTION
  Future<void> showFirebaseNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'AuthShield Alert';
    final body = message.notification?.body ?? 'Unknown face detected';

    const androidDetails = AndroidNotificationDetails(
      'intrusion_channel',
      'Intrusion Alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );

    // 🔊 Always play sound for Firebase alert
    await playAlarm(isCritical: true);
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
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFEF4444),
      enableVibration: true,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

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
      importance: Importance.defaultImportance,
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
    } catch (e) {
      print('❌ Audio error: $e');
    }
  }

  Future<void> stopAlarm() async {
    await _audioPlayer.stop();
  }
}
