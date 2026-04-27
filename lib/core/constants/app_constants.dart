class AppConstants {
  // ================= APP INFO =================
  static const String appName = 'AuthShield';
  static const String appVersion = 'v1.0';
  static const String appTagline = 'Smart 2LA • Secure Access';

  // ================= DEVICE =================
  static const String defaultDeviceId = 'AuthShield-X-9000';
  static const String authProtocol = '22-OMEGA';

  // ================= SUPABASE TABLES =================
  static const String ownersTable = 'owners';
  static const String alertsTable = 'alerts';
  static const String logsTable = 'access_logs';
  static const String settingsTable = 'settings';
  static const String capturedImagesTable = 'captured_images';

  // ================= SUPABASE STORAGE BUCKETS =================
  static const String ownerImagesBucket = 'owner-images';
  static const String intruderImagesBucket = 'intruder-images';

  // ================= ESP32 API =================
  // ⚠️ IMPORTANT:
  // Replace this if your ESP32 IP changes
  static const String esp32BaseUrl = 'http://10.176.52.180';
  static const backendBaseUrl = "http://10.176.52.180:8000";

  static const String unlockEndpoint = '/unlock';
  static const String statusEndpoint = '/status';
  static const String captureEndpoint = '/capture';

  // ================= REALTIME CHANNELS =================
  static const String alertsChannel = 'alerts-channel';
  static const String logsChannel = 'logs-channel';

  // ================= GROQ API =================
  static const String groqModel = 'llama-3.1-8b-instant';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';

  // ================= LIMITS =================
  static const int maxOwners = 10;

  // ================= SHARED PREFS KEYS =================
  static const String keyThemeMode = 'theme_mode';
  static const String keyPushAlerts = 'push_alerts';
  static const String keyOwnerActivity = 'owner_activity';
  static const String keySystemUpdates = 'system_updates';
  static const String keyAlarmRingtone = 'alarm_ringtone';
  static const String keyCriticalAlertTone = 'critical_alert_tone';
  static const String keyDeviceId = 'device_id';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyAlarmRingtonePath = 'alarm_ringtone_path';
  static const String keyCriticalAlertTonePath = 'critical_alert_tone_path';
}
