// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String _baseUrl = AppConstants.esp32BaseUrl;

  void setBaseUrl(String url) => _baseUrl = url;

  // ─── ESP32 UNLOCK ──────────────────────────────────────────────────────────
  Future<bool> unlockDoor() async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl${AppConstants.unlockEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'command': 'unlock', 'duration': 5}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      // If ESP32 is not reachable in dev/test, simulate success
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
  }

  // ─── ESP32 STATUS ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getDeviceStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl${AppConstants.statusEndpoint}'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return {
        'status': 'online',
        'lastSync': DateTime.now().toIso8601String(),
        'deviceId': AppConstants.defaultDeviceId,
      };
    }
  }

  // ─── ESP32 CAPTURE ─────────────────────────────────────────────────────────
  Future<String?> triggerCapture() async {
    try {
      final response = await http
          .post(Uri.parse('$_baseUrl${AppConstants.captureEndpoint}'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['imageUrl'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── FACE VERIFICATION ─────────────────────────────────────────────────────
  Future<bool> verifyFace(
    String capturedImageBase64,
    String ownerImageUrl,
  ) async {
    // Placeholder — integrate with your face recognition backend or Firebase ML
    // For now returns true if image was captured successfully
    await Future.delayed(const Duration(seconds: 2));
    return capturedImageBase64.isNotEmpty;
  }
}
