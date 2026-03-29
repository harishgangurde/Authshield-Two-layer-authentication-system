// lib/features/history/history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/supabase_service.dart';
import '../../models/log_model.dart';
import 'widgets/log_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _supabase = SupabaseService();
  List<LogModel> _logs = [];
  bool _loading = true;
  bool _loadingMore = false;
  DateTime? _filterDate;
  LogStatus? _filterStatus;
  int _page = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _subscribeRealtime();
  }

  Future<void> _loadLogs({bool append = false}) async {
    if (!append)
      setState(() => _loading = true);
    else
      setState(() => _loadingMore = true);

    try {
      final logs = await _supabase.fetchLogs(
        limit: _pageSize,
        fromDate: _filterDate,
        status: _filterStatus,
      );
      if (mounted) {
        setState(() {
          if (append) {
            _logs.addAll(logs);
          } else {
            _logs = logs;
          }
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
    }
  }

  void _subscribeRealtime() {
    _supabase.subscribeToLogs((log) {
      if (mounted) setState(() => _logs.insert(0, log));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.bgCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _filterDate = picked);
      _loadLogs();
    }
  }

  void _pickStatus() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Status',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              null,
              LogStatus.success,
              LogStatus.failure,
              LogStatus.manual,
            ].map(
              (s) => ListTile(
                title: Text(
                  s == null ? 'All' : s.name.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    color: _filterStatus == s
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: _filterStatus == s
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _filterStatus = s);
                  Navigator.pop(context);
                  _loadLogs();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity History',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.statusOnline,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE MONITORING ACTIVE',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filters
                Row(
                  children: [
                    _filterChip(
                      icon: Icons.calendar_today,
                      label: _filterDate != null
                          ? DateFormat('MMM d').format(_filterDate!)
                          : 'Filter by Date',
                      onTap: _pickDate,
                      active: _filterDate != null,
                    ),
                    const SizedBox(width: 10),
                    if (_filterDate != null)
                      GestureDetector(
                        onTap: () {
                          setState(() => _filterDate = null);
                          _loadLogs();
                        },
                        child: const Icon(
                          Icons.close,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _filterChip(
                      icon: Icons.tune,
                      label: _filterStatus != null
                          ? _filterStatus!.name.toUpperCase()
                          : 'Filter by Status (Success/Fail)',
                      onTap: _pickStatus,
                      active: _filterStatus != null,
                    ),
                    const SizedBox(width: 10),
                    if (_filterStatus != null)
                      GestureDetector(
                        onTap: () {
                          setState(() => _filterStatus = null);
                          _loadLogs();
                        },
                        child: const Icon(
                          Icons.close,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? _buildShimmer()
                : _logs.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.bgCard,
                    onRefresh: _loadLogs,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: _logs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _logs.length) {
                          return _buildFetchMore();
                        }
                        return LogTile(log: _logs[index])
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideY(begin: 0.05);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.bgCardLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: active ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFetchMore() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _loadingMore
            ? const CircularProgressIndicator(color: AppColors.primary)
            : OutlinedButton(
                onPressed: () => _loadLogs(append: true),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.bgCardLight),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'FETCH OLDER LOGS',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            'No logs found',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
