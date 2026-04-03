import 'dart:io';
import 'dart:typed_data';
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

  static const String _permissionKey = 'notification_permission_asked';

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'intrusion_channel_v4',
      'Intrusion Alerts',
      description: 'Critical security intrusion alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('siren'),
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

  Future<void> showFirebaseNotification(RemoteMessage message) async {
    final title = message.data['title'] ??
        message.notification?.title ??
        'AuthShield Alert';

    final body = message.data['body'] ??
        message.notification?.body ??
        'Unknown face detected';

    final androidDetails = AndroidNotificationDetails(
      'intrusion_channel_v4',
      'Intrusion Alerts',
      channelDescription: 'Critical security intrusion alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('siren'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1500]),
      ticker: 'ticker',
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
      autoCancel: true,
      ongoing: false,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );

    await playAlarm(isCritical: true);
  }

  Future<void> showIntrusionAlert({
    required String title,
    required String body,
    bool isCritical = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'intrusion_channel_v4',
      'Intrusion Alerts',
      channelDescription: 'Critical security intrusion alerts',
      importance: Importance.max,
      priority: Priority.high,
      color: const Color(0xFFEF4444),
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('siren'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1500]),
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
      autoCancel: true,
      ongoing: false,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );

    if (isCritical) {
      await playAlarm(isCritical: true);
    }
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
      final prefs = await SharedPreferences.getInstance();

      final selectedTone = isCritical
          ? prefs.getString('critical_alert_tone') ?? 'Loud Alert'
          : prefs.getString('alarm_ringtone') ?? 'Default Security';

      final selectedPath = isCritical
          ? prefs.getString('critical_alert_tone_path')
          : prefs.getString('alarm_ringtone_path');

      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);

      if (selectedPath != null &&
          selectedPath.isNotEmpty &&
          File(selectedPath).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(selectedPath));
        return;
      }

      final assetMap = {
        'Default Security': 'audio/default_security.mp3',
        'Soft Beep': 'audio/soft_beep.mp3',
        'Pulse': 'audio/pulse.mp3',
        'Chime': 'audio/chime.mp3',
        'Loud Alert': 'audio/loud_alert.mp3',
        'Siren': 'audio/siren.mp3',
        'Alarm Bell': 'audio/alarm_bell.mp3',
        'Emergency Buzz': 'audio/emergency_buzz.mp3',
      };

      final assetPath = assetMap[selectedTone] ?? 'audio/loud_alert.mp3';
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('❌ Audio error: $e');
    }
  }

  Future<void> stopAlarm() async {
    await _audioPlayer.stop();
  }
}
