import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../../app.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushAlerts = true;
  bool _ownerActivity = false;
  bool _systemUpdates = true;
  bool _darkMode = true;

  String _alarmRingtone = 'Default Security';
  String _criticalAlertTone = 'Loud Alert';
  String _deviceId = AppConstants.defaultDeviceId;

  String? _alarmRingtonePath;
  String? _criticalAlertTonePath;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final _supabase = Supabase.instance.client;

  bool _isUpdatingPassword = false;
  String _currentDoorPassword = '••••';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadDoorPassword();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushAlerts = prefs.getBool(AppConstants.keyPushAlerts) ?? true;
      _ownerActivity = prefs.getBool(AppConstants.keyOwnerActivity) ?? false;
      _systemUpdates = prefs.getBool(AppConstants.keySystemUpdates) ?? true;
      _darkMode = prefs.getBool(AppConstants.keyThemeMode) ?? true;

      _alarmRingtone =
          prefs.getString(AppConstants.keyAlarmRingtone) ?? 'Default Security';
      _criticalAlertTone =
          prefs.getString(AppConstants.keyCriticalAlertTone) ?? 'Loud Alert';

      _alarmRingtonePath = prefs.getString(AppConstants.keyAlarmRingtonePath);
      _criticalAlertTonePath =
          prefs.getString(AppConstants.keyCriticalAlertTonePath);

      _deviceId = prefs.getString(AppConstants.keyDeviceId) ??
          AppConstants.defaultDeviceId;
    });
  }

  Future<void> _loadDoorPassword() async {
    try {
      final response = await _supabase
          .from('settings')
          .select('value')
          .eq('key', 'keypad_password')
          .maybeSingle();

      if (response != null && response['value'] != null) {
        setState(() {
          _currentDoorPassword = response['value'].toString();
        });
      } else {
        setState(() {
          _currentDoorPassword = '1234';
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading keypad password: $e');
      setState(() {
        _currentDoorPassword = '1234';
      });
    }
  }

  Future<void> _saveDoorPassword(String newPassword) async {
    setState(() => _isUpdatingPassword = true);

    try {
      await _supabase.from('settings').update({
        'value': newPassword,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('key', 'keypad_password');

      setState(() {
        _currentDoorPassword = newPassword;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Door password updated successfully',
              style: GoogleFonts.spaceGrotesk(),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving keypad password: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update password',
              style: GoogleFonts.spaceGrotesk(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPassword = false);
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Change Door Password',
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  style: GoogleFonts.spaceGrotesk(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: GoogleFonts.inter(color: subColor),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  style: GoogleFonts.spaceGrotesk(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: GoogleFonts.inter(color: subColor),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  style: GoogleFonts.spaceGrotesk(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: GoogleFonts.inter(color: subColor),
                    counterText: '',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed:
                _isUpdatingPassword ? null : () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: subColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isUpdatingPassword
                ? null
                : () async {
                    final current = currentController.text.trim();
                    final newPass = newController.text.trim();
                    final confirm = confirmController.text.trim();

                    if (current != _currentDoorPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Current password is incorrect',
                            style: GoogleFonts.spaceGrotesk(),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (newPass.length != 4 || int.tryParse(newPass) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Password must be exactly 4 digits',
                            style: GoogleFonts.spaceGrotesk(),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (newPass != confirm) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Passwords do not match',
                            style: GoogleFonts.spaceGrotesk(),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await _saveDoorPassword(newPass);
                  },
            child: _isUpdatingPassword
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  Future<void> _removePref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> _pickCustomTone(bool isCritical) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final fileName = result.files.single.name;

      setState(() {
        if (isCritical) {
          _criticalAlertTone = 'Custom Tone';
          _criticalAlertTonePath = path;
        } else {
          _alarmRingtone = 'Custom Tone';
          _alarmRingtonePath = path;
        }
      });

      await _savePref(
        isCritical
            ? AppConstants.keyCriticalAlertTone
            : AppConstants.keyAlarmRingtone,
        'Custom Tone',
      );

      await _savePref(
        isCritical
            ? AppConstants.keyCriticalAlertTonePath
            : AppConstants.keyAlarmRingtonePath,
        path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selected: $fileName',
              style: GoogleFonts.spaceGrotesk(),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  Future<void> _previewTone(bool isCritical) async {
    final path = isCritical ? _criticalAlertTonePath : _alarmRingtonePath;

    if (path == null || path.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No custom tone selected',
              style: GoogleFonts.spaceGrotesk(),
            ),
          ),
        );
      }
      return;
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not play selected file',
              style: GoogleFonts.spaceGrotesk(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _selectRingtone(bool isCritical) async {
    final options = isCritical
        ? ['Loud Alert', 'Siren', 'Alarm Bell', 'Emergency Buzz']
        : ['Default Security', 'Soft Beep', 'Pulse', 'Chime'];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCritical ? 'Critical Alert Tone' : 'Alarm Ringtone',
                  style: GoogleFonts.spaceGrotesk(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ...options.map(
                  (o) => ListTile(
                    title: Text(
                      o,
                      style: GoogleFonts.spaceGrotesk(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing:
                        (isCritical ? _criticalAlertTone : _alarmRingtone) == o
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                    onTap: () => Navigator.pop(context, o),
                  ),
                ),
                const Divider(height: 24),
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: Text(
                    'Choose from device',
                    style: GoogleFonts.spaceGrotesk(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Pick MP3 / WAV / M4A file',
                    style: GoogleFonts.inter(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickCustomTone(isCritical);
                  },
                ),
                if ((isCritical
                        ? _criticalAlertTonePath
                        : _alarmRingtonePath) !=
                    null)
                  ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: Text(
                      'Preview selected custom tone',
                      style: GoogleFonts.spaceGrotesk(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await _previewTone(isCritical);
                    },
                  ),
                if ((isCritical
                        ? _criticalAlertTonePath
                        : _alarmRingtonePath) !=
                    null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    title: Text(
                      'Remove custom tone',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);

                      if (isCritical) {
                        setState(() {
                          _criticalAlertTone = 'Loud Alert';
                          _criticalAlertTonePath = null;
                        });
                        await _savePref(
                            AppConstants.keyCriticalAlertTone, 'Loud Alert');
                        await _removePref(
                            AppConstants.keyCriticalAlertTonePath);
                      } else {
                        setState(() {
                          _alarmRingtone = 'Default Security';
                          _alarmRingtonePath = null;
                        });
                        await _savePref(
                            AppConstants.keyAlarmRingtone, 'Default Security');
                        await _removePref(AppConstants.keyAlarmRingtonePath);
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        if (isCritical) {
          _criticalAlertTone = selected;
          _criticalAlertTonePath = null;
        } else {
          _alarmRingtone = selected;
          _alarmRingtonePath = null;
        }
      });

      await _savePref(
        isCritical
            ? AppConstants.keyCriticalAlertTone
            : AppConstants.keyAlarmRingtone,
        selected,
      );

      await _removePref(
        isCritical
            ? AppConstants.keyCriticalAlertTonePath
            : AppConstants.keyAlarmRingtonePath,
      );
    }
  }

  String _displaySubtitle(String tone, String? path) {
    if (tone == 'Custom Tone' && path != null && path.isNotEmpty) {
      return File(path).uri.pathSegments.last;
    }
    return tone;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.bgCard : AppColors.lightCard;
    final bgColor = isDark ? AppColors.bgDark : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.lightCard,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.shield, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'App Settings',
              style: GoogleFonts.spaceGrotesk(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: textColor),
            onPressed: () => Navigator.of(context).pushNamed('/alerts'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _sectionHeader('🔔', 'ALARMS', subColor)
              .animate()
              .fadeIn(delay: 100.ms),
          _settingsTile(
            title: 'Alarm ringtone selection',
            subtitle: _displaySubtitle(_alarmRingtone, _alarmRingtonePath),
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            trailing: Icon(Icons.chevron_right, color: subColor, size: 18),
            onTap: () => _selectRingtone(false),
          ).animate().fadeIn(delay: 150.ms),
          _settingsTile(
            title: 'Critical Alert Tone',
            subtitle:
                _displaySubtitle(_criticalAlertTone, _criticalAlertTonePath),
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            trailing: Icon(Icons.chevron_right, color: subColor, size: 18),
            onTap: () => _selectRingtone(true),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          _sectionHeader('🔐', 'SECURITY', subColor)
              .animate()
              .fadeIn(delay: 225.ms),
          _settingsTile(
            title: 'Change Door Password',
            subtitle: 'Current: $_currentDoorPassword',
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            trailing: _isUpdatingPassword
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.lock_outline, color: subColor, size: 18),
            onTap: _showChangePasswordDialog,
          ).animate().fadeIn(delay: 240.ms),
          const SizedBox(height: 24),
          _sectionHeader('📡', 'NOTIFICATIONS', subColor)
              .animate()
              .fadeIn(delay: 250.ms),
          _switchTile(
            title: 'Push Alerts',
            subtitle: 'Instant mobile push notifications',
            value: _pushAlerts,
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            onChanged: (v) {
              setState(() => _pushAlerts = v);
              _savePref(AppConstants.keyPushAlerts, v);
            },
          ).animate().fadeIn(delay: 300.ms),
          _switchTile(
            title: 'Owner Activity',
            subtitle: 'Updates when sub-users login',
            value: _ownerActivity,
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            onChanged: (v) {
              setState(() => _ownerActivity = v);
              _savePref(AppConstants.keyOwnerActivity, v);
            },
          ).animate().fadeIn(delay: 350.ms),
          _switchTile(
            title: 'System Updates',
            subtitle: 'Critical kernel and firmware news',
            value: _systemUpdates,
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            onChanged: (v) {
              setState(() => _systemUpdates = v);
              _savePref(AppConstants.keySystemUpdates, v);
            },
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
          _sectionHeader('🖥️', 'DEVICE INFORMATION', subColor)
              .animate()
              .fadeIn(delay: 450.ms),
          _settingsTile(
            title: 'Device ID',
            subtitle: _deviceId,
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            trailing: IconButton(
              icon: Icon(Icons.info_outline, color: subColor, size: 18),
              onPressed: () => _showDeviceInfo(textColor, subColor),
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 24),
          _sectionHeader('🎨', 'APPEARANCE', subColor)
              .animate()
              .fadeIn(delay: 550.ms),
          _switchTile(
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            value: _darkMode,
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            leading: Icon(Icons.dark_mode, color: subColor, size: 22),
            onChanged: (v) {
              setState(() => _darkMode = v);
              setAppTheme(v);
            },
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 24),
          _sectionHeader('ℹ️', 'APP INFO', subColor)
              .animate()
              .fadeIn(delay: 650.ms),
          _settingsTile(
            title: AppConstants.appName,
            subtitle: 'Version ${AppConstants.appVersion}',
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            trailing: const Icon(
              Icons.shield,
              color: AppColors.primary,
              size: 18,
            ),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }

  Widget _sectionHeader(String emoji, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: color,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    Widget? trailing,
    Widget? leading,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: leading,
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(color: textColor, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(color: subColor, fontSize: 12),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    Widget? leading,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: leading,
        title: Text(
          title,
          style: GoogleFonts.spaceGrotesk(color: textColor, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(color: subColor, fontSize: 12),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  void _showDeviceInfo(Color textColor, Color subColor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Device Information',
          style: GoogleFonts.spaceGrotesk(color: textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Device ID', _deviceId, textColor, subColor),
            const SizedBox(height: 8),
            _infoRow(
              'Protocol',
              AppConstants.authProtocol,
              textColor,
              subColor,
            ),
            const SizedBox(height: 8),
            _infoRow(
              'App Version',
              AppConstants.appVersion,
              textColor,
              subColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.spaceGrotesk(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color textColor, Color subColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(fontSize: 11, color: subColor),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceMono(fontSize: 11, color: textColor),
          ),
        ),
      ],
    );
  }
}
