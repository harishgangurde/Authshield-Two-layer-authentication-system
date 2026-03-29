// lib/features/chatbot/groq_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../models/log_model.dart';
import '../../models/alert_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  GroqMessage({required this.role, required this.content, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class GroqService {
  static final GroqService _instance = GroqService._internal();
  factory GroqService() => _instance;
  GroqService._internal();

  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  final List<GroqMessage> _history = [];
  List<GroqMessage> get history => List.unmodifiable(_history);

  String _buildSystemPrompt({
    List<LogModel>? recentLogs,
    List<AlertModel>? recentAlerts,
    int ownerCount = 0,
  }) {
    final hasLogs = recentLogs != null && recentLogs.isNotEmpty;
    final hasAlerts = recentAlerts != null && recentAlerts.isNotEmpty;

    final logsContext = hasLogs
        ? recentLogs
            .map(
              (l) =>
                  '- ${l.action} | Device: ${l.deviceId} | Status: ${l.statusLabel} | ${l.formattedDate} ${l.formattedTime}',
            )
            .join('\n')
        : 'NO LOGS IN DATABASE YET';

    final alertsContext = hasAlerts
        ? recentAlerts
            .map(
              (a) =>
                  '- ${a.title} | Device: ${a.deviceId} | ${a.formattedTime}',
            )
            .join('\n')
        : 'NO ALERTS IN DATABASE YET';

    return '''You are AuthShield Intelligence, an AI security assistant inside the AuthShield app.

YOUR NAME IS: AuthShield Intelligence. Never call yourself Sentinel Intelligence.

RESPONSE FORMAT RULES — VERY IMPORTANT:
- Keep ALL responses SHORT — maximum 5 lines.
- Use numbered points (1. 2. 3.) when listing things. Never use dashes or bullets.
- Never write long paragraphs. Break into short numbered lines.
- No asterisks (*), no hash (#), no bold, no italic, no markdown. Plain text only.
- Always end with one short question like "How can I help you?" or "What would you like to know?"

GREETING RESPONSE (when user says hi, hello, hey, hii):
Reply in exactly this short format:
"Hi! I am AuthShield Intelligence, your AI security assistant.
I can help you with:
1. Registered owners
2. Access logs and door activity
3. Security alerts
4. System health
What would you like to know?"

DATA RULES:
- NEVER invent or guess any data. Only use what is in LIVE SYSTEM DATA below.
- If no data exists, say so in one short sentence.

LIVE SYSTEM DATA:
App: ${AppConstants.appName}
Device ID: ${AppConstants.defaultDeviceId}
Active Owners: $ownerCount
Auth Protocol: ${AppConstants.authProtocol}

Recent Logs:
$logsContext

Active Alerts:
$alertsContext''';
  }

  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'`(.*?)`'), r'$1')
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('#', '')
        .trim();
  }

  Future<String> sendMessage(
    String userMessage, {
    List<LogModel>? recentLogs,
    List<AlertModel>? recentAlerts,
    int ownerCount = 0,
  }) async {
    _history.add(GroqMessage(role: 'user', content: userMessage));

    final messages =
        _history.map((m) => {'role': m.role, 'content': m.content}).toList();

    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.groqBaseUrl}/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': AppConstants.groqModel,
              'messages': [
                {
                  'role': 'system',
                  'content': _buildSystemPrompt(
                    recentLogs: recentLogs,
                    recentAlerts: recentAlerts,
                    ownerCount: ownerCount,
                  ),
                },
                ...messages,
              ],
              'max_tokens': 150,
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final raw = data['choices'][0]['message']['content'] as String;
        final cleaned = _stripMarkdown(raw);
        _history.add(GroqMessage(role: 'assistant', content: cleaned));
        return cleaned;
      } else {
        final errMsg =
            'Connection error ${response.statusCode}. Check your Groq API key.';
        _history.add(GroqMessage(role: 'assistant', content: errMsg));
        return errMsg;
      }
    } catch (e) {
      const fallback =
          'AuthShield Intelligence is offline. Check your internet connection.';
      _history.add(GroqMessage(role: 'assistant', content: fallback));
      return fallback;
    }
  }

  void clearHistory() => _history.clear();

  static List<String> get suggestions => [
        'How many owners are registered?',
        'Any active alerts right now?',
        'Show recent access logs',
        'What can you help me with?',
      ];
}
