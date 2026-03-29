// lib/features/alerts/alerts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/supabase_service.dart';
import '../../models/alert_model.dart';
import 'widgets/alert_card.dart';
import '../notifications/notification_popup.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _supabase = SupabaseService();
  List<AlertModel> _alerts = [];
  bool _loading = true;
  AlertModel? _liveAlert;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    _subscribeRealtime();
  }

  Future<void> _loadAlerts() async {
    try {
      final alerts = await _supabase.fetchAlerts();
      if (mounted)
        setState(() {
          _alerts = alerts;
          _loading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _subscribeRealtime() {
    _supabase.subscribeToAlerts((alert) {
      if (mounted) {
        setState(() {
          _alerts.insert(0, alert);
          _liveAlert = alert;
        });
        _showLiveBanner(alert);
      }
    });
  }

  void _showLiveBanner(AlertModel alert) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => NotificationPopup(alert: alert),
    );
  }

  Future<void> _clearAll() async {
    await _supabase.clearAllAlerts();
    setState(() => _alerts.clear());
  }

  Future<void> _dismissAlert(AlertModel alert) async {
    await _supabase.dismissAlert(alert.id!);
    setState(() => _alerts.removeWhere((a) => a.id == alert.id));
  }

  Future<void> _initiateLockout(AlertModel alert) async {
    await _supabase.initiateLockout(alert.id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(
            'Lockout initiated for ${alert.deviceId}',
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveAlerts = _alerts.where((a) => !a.dismissed).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // Live intrusion banner
          if (_liveAlert != null)
            SliverToBoxAdapter(child: _buildLiveBanner(_liveAlert!)),

          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgDark,
            title: Row(
              children: [
                const Icon(Icons.shield, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'High-Tech Sentinel',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                  if (liveAlerts.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SECURITY LOGS',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Intruder Alerts',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: liveAlerts.isEmpty ? null : _clearAll,
                      child: Text(
                        'CLEAR ALL',
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Alert cards
                if (_loading)
                  ..._buildShimmer()
                else if (liveAlerts.isEmpty)
                  _buildEmpty()
                else
                  ...liveAlerts.asMap().entries.map((entry) {
                    return AlertCard(
                          alert: entry.value,
                          onDismiss: () => _dismissAlert(entry.value),
                          onLockout: () => _initiateLockout(entry.value),
                          onViewLogs: () =>
                              Navigator.of(context).pushNamed('/history'),
                        )
                        .animate()
                        .fadeIn(delay: (entry.key * 100).ms)
                        .slideY(begin: 0.1);
                  }),

                const SizedBox(height: 20),
                // Observation protocol info
                _buildObservationNote(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBanner(AlertModel alert) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.danger,
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INTRUSION DETECTED',
                  style: GoogleFonts.spaceMono(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'LIVE NOW • ${alert.formattedTime} • ${alert.deviceId}',
                  style: GoogleFonts.spaceMono(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -1).fadeIn();
  }

  List<Widget> _buildShimmer() {
    return List.generate(
      3,
      (_) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'All Clear',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No active intrusion alerts',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withOpacity(0.15),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.accentBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Observation Protocol',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Images are captured automatically by the ESP32-CAM module upon any unauthorized access attempt. Higher resolution versions are stored on the secure local cloud.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
