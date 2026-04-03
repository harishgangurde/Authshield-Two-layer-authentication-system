import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      print('❌ Error stopping sound: $e');
    }
  }

  Future<void> playAlertSound({required bool isCritical}) async {
    final prefs = await SharedPreferences.getInstance();

    final selectedTone = isCritical
        ? prefs.getString(AppConstants.keyCriticalAlertTone) ?? 'Loud Alert'
        : prefs.getString(AppConstants.keyAlarmRingtone) ?? 'Default Security';

    final selectedPath = isCritical
        ? prefs.getString(AppConstants.keyCriticalAlertTonePath)
        : prefs.getString(AppConstants.keyAlarmRingtonePath);

    print('🔔 playAlertSound called');
    print('🔔 isCritical: $isCritical');
    print('🔔 selectedTone: $selectedTone');
    print('🔔 selectedPath: $selectedPath');

    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);

      // ✅ TRY CUSTOM FILE SAFELY
      if (selectedPath != null && selectedPath.isNotEmpty) {
        try {
          final file = File(selectedPath);

          print('📂 Checking custom file: ${file.path}');
          print('📂 Exists: ${file.existsSync()}');

          if (file.existsSync()) {
            print('▶ Playing custom device file...');
            await _player.play(DeviceFileSource(selectedPath));
            return;
          } else {
            print('⚠ Custom selected file not found. Falling back to asset.');
          }
        } catch (e) {
          print('❌ Custom file playback error: $e');
        }
      }

      // ✅ FALLBACK TO BUNDLED ASSET TONES
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

      print('🎵 Playing fallback asset: $assetPath');
      await _player.play(AssetSource(assetPath));
    } catch (e, stack) {
      print('❌ FINAL Sound playback error: $e');
      print(stack);

      // ✅ LAST SAFETY FALLBACK
      try {
        await _player.play(AssetSource('audio/loud_alert.mp3'));
      } catch (fallbackError) {
        print('❌ Even fallback sound failed: $fallbackError');
      }
    }
  }

  Future<void> testSound() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);

      print('🧪 Playing test sound...');
      await _player.play(AssetSource('audio/loud_alert.mp3'));
    } catch (e, stack) {
      print('❌ Test sound error: $e');
      print(stack);
    }
  }
}
