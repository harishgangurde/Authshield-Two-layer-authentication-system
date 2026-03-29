// lib/features/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/supabase_service.dart';
import '../../models/log_model.dart';
import '../override/override_dialog.dart';
import 'widgets/status_card.dart';
import 'widgets/stats_card.dart';
import 'widgets/unlock_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabase = SupabaseService();
  bool _loading = true;
  int _ownerCount = 0;
  int _activeAlerts = 0;
  DateTime? _lastAlertTime;
  List<LogModel> _recentLogs = [];
  String _lastSync = 'just now';
  String _deviceId = AppConstants.defaultDeviceId;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeRealtime();
  }

  Future<void> _loadData() async {
    try {
      final stats = await _supabase.fetchDashboardStats();
      final logs = await _supabase.fetchRecentLogs();
      if (mounted) {
        setState(() {
          _ownerCount = stats['ownerCount'] ?? 0;
          _activeAlerts = stats['activeAlerts'] ?? 0;
          final lastLog = stats['lastAlert'] as LogModel?;
          _lastAlertTime = lastLog?.timestamp;
          _recentLogs = logs;
          _lastSync = 'just now';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _subscribeRealtime() {
    _supabase.subscribeToLogs((log) {
      if (mounted) {
        setState(() {
          _recentLogs.insert(0, log);
          if (_recentLogs.length > 3)
            _recentLogs = _recentLogs.take(3).toList();
          _lastSync = 'just now';
        });
      }
    });
    _supabase.subscribeToAlerts((alert) {
      if (mounted) setState(() => _activeAlerts++);
    });
  }

  String _formatLastAlert() {
    if (_lastAlertTime == null) return 'Never';
    return timeago.format(_lastAlertTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bgCard,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Device profile
                  _buildDeviceProfile().animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),

                  // System status
                  StatusCard(
                    isOnline: _isOnline,
                    activeAlerts: _activeAlerts,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),

                  // Unlock button
                  UnlockButton(
                    onTap: () => _showOverrideDialog(context),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),

                  // Stats row
                  if (_loading)
                    _buildStatsShimmer()
                  else
                    _buildStatsGrid().animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 24),

                  // Recent activity
                  _buildRecentActivity().animate().fadeIn(delay: 500.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/owners/add'),
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          'ADD OWNER',
          style: GoogleFonts.spaceMono(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.bgDark,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.shield, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Text(
            AppConstants.appName,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pushNamed('/alerts'),
            ),
            if (_activeAlerts > 0)
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
    );
  }

  Widget _buildDeviceProfile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HARDWARE PROFILE',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Device ID: $_deviceId',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.statusOnline,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Last sync: $_lastSync',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        StatsCard(
          icon: Icons.people,
          label: 'Current Owners',
          value: _ownerCount.toString(),
          tag: 'NETWORK',
          onTap: () => Navigator.of(context).pushNamed('/owners'),
        ),
        const SizedBox(height: 12),
        StatsCard(
          icon: Icons.shield_outlined,
          label: 'Active Alerts',
          value: _activeAlerts.toString(),
          tag: 'LIVE FEED',
          accentColor: _activeAlerts > 0 ? AppColors.danger : AppColors.primary,
          onTap: () => Navigator.of(context).pushNamed('/alerts'),
        ),
        const SizedBox(height: 12),
        StatsCard(
          icon: Icons.history,
          label: 'Last Alert',
          value: _formatLastAlert(),
          tag: 'LOGS',
          onTap: () => Navigator.of(context).pushNamed('/history'),
        ),
      ],
    );
  }

  Widget _buildStatsShimmer() {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ACTIVITY LOG',
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            color: AppColors.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        if (_recentLogs.isEmpty)
          _buildEmptyLogs()
        else
          ..._recentLogs.asMap().entries.map((entry) {
            final log = entry.value;
            return _buildLogRow(log)
                .animate()
                .fadeIn(delay: (600 + entry.key * 100).ms)
                .slideX(begin: -0.05);
          }),
      ],
    );
  }

  Widget _buildLogRow(LogModel log) {
    final dotColor = log.status == LogStatus.success
        ? AppColors.statusOnline
        : log.status == LogStatus.failure
        ? AppColors.danger
        : AppColors.accentBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              log.action,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            log.formattedTime,
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLogs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'No recent activity',
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
      ),
    );
  }

  void _showOverrideDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => const OverrideDialog(),
    );
  }
}
