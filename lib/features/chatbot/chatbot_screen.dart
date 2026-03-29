// lib/features/chatbot/chatbot_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/supabase_service.dart';
import '../../models/log_model.dart';
import '../../models/alert_model.dart';
import 'groq_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _groq = GroqService();
  final _supabase = SupabaseService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  List<GroqMessage> _messages = [];
  bool _sending = false;
  double _latencyMs = 0;

  // Fresh data fetched before every message
  List<LogModel> _recentLogs = [];
  List<AlertModel> _recentAlerts = [];
  int _ownerCount = 0;

  @override
  void initState() {
    super.initState();
    _messages = List.from(_groq.history);
  }

  // ── Fetch latest data from Supabase before every AI call ──────────────────
  Future<void> _refreshData() async {
    try {
      final stats = await _supabase.fetchDashboardStats();
      final logs = await _supabase.fetchRecentLogs(limit: 10);
      final alerts = await _supabase.fetchAlerts(limit: 5);
      _ownerCount = stats['ownerCount'] ?? 0;
      _recentLogs = logs;
      _recentAlerts = alerts;
    } catch (_) {
      // silently fail — AI will say no data
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _sending) return;
    _textController.clear();

    setState(() {
      _sending = true;
      _messages = List.from(_groq.history)
        ..add(GroqMessage(role: 'user', content: text));
    });
    _scrollToBottom();

    final stopwatch = Stopwatch()..start();

    // ✅ Always fetch fresh data before sending to AI
    await _refreshData();

    final response = await _groq.sendMessage(
      text,
      recentLogs: _recentLogs,
      recentAlerts: _recentAlerts,
      ownerCount: _ownerCount,
    );

    stopwatch.stop();

    if (mounted) {
      setState(() {
        _sending = false;
        _messages = List.from(_groq.history);
        _latencyMs = stopwatch.elapsedMilliseconds.toDouble();
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentPurple],
                ),
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Security Assistant',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'POWERED BY GROQ',
                  style: GoogleFonts.spaceMono(
                    color: AppColors.primary,
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/alerts'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBar(),
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcome()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _messages.length + (_sending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _sending) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessage(_messages[index], index);
                    },
                  ),
          ),
          if (_messages.isEmpty) _buildSuggestions(),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.bgCardLight)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.statusOnline,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Sentinel Neural Link Active',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (_latencyMs > 0)
            Text(
              'LATENCY: ${_latencyMs.toStringAsFixed(0)}MS',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage(GroqMessage msg, int index) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accentBlue],
                    ),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.black,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SENTINEL INTELLIGENCE',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.accentBlue : AppColors.bgCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                msg.content,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${_formatTime(msg.timestamp)}  •  ${isUser ? 'SENT' : 'DELIVERED'}',
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 30).ms).slideY(begin: 0.05);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accentBlue],
              ),
            ),
            child: const Icon(Icons.security, color: Colors.black, size: 14),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(delay: (i * 200).ms)
                    .then()
                    .fadeOut();
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentPurple],
                ),
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 36),
            ).animate().scale().fadeIn(),
            const SizedBox(height: 16),
            Text(
              'Sentinel Intelligence',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about your owners, security logs, alerts, or system health.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: GroqService.suggestions.map((s) {
          return GestureDetector(
            onTap: () => _sendMessage(s),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.bgCardLight),
              ),
              child: Text(
                s,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.bgCardLight)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.attach_file,
              color: AppColors.textMuted,
              size: 20,
            ),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Ask about your security logs...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: _sendMessage,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
            ),
          ),
          GestureDetector(
            onTap: _sending ? null : () => _sendMessage(_textController.text),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentPurple],
                ),
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $amPm';
  }
}
