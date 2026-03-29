// lib/core/constants/app_constants.dart

class AppConstants {
  // App Info
  static const String appName = 'AuthShield';
  static const String appVersion = 'v4.0.2';
  static const String appTagline = 'Smart 2FA • Secure Access';

  // Device
  static const String defaultDeviceId = 'AuthShield-X-9000';
  static const String authProtocol = '22-OMEGA';

  // Supabase Tables
  static const String ownersTable = 'owners';
  static const String alertsTable = 'alerts';
  static const String logsTable = 'access_logs';
  static const String settingsTable = 'settings';
  static const String capturedImagesTable = 'captured_images';

  // Supabase Storage Buckets
  static const String ownerImagesBucket = 'owner-images';
  static const String intruderImagesBucket = 'intruder-images';

  // ESP32 API
  static const String esp32BaseUrl = 'http://192.168.1.100';
  static const String unlockEndpoint = '/unlock';
  static const String statusEndpoint = '/status';
  static const String captureEndpoint = '/capture';

  // Realtime channels
  static const String alertsChannel = 'alerts-channel';
  static const String logsChannel = 'logs-channel';

  // ✅ UPDATED Groq Model — llama3-8b-8192 was decommissioned
  static const String groqModel = 'llama-3.1-8b-instant'; // ✅ Active model
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';

  // Max owners
  static const int maxOwners = 10;

  // SharedPrefs keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyPushAlerts = 'push_alerts';
  static const String keyOwnerActivity = 'owner_activity';
  static const String keySystemUpdates = 'system_updates';
  static const String keyAlarmRingtone = 'alarm_ringtone';
  static const String keyCriticalAlertTone = 'critical_alert_tone';
  static const String keyDeviceId = 'device_id';
  static const String keyOnboardingDone = 'onboarding_done';
}
