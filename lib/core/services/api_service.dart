import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String _baseUrl = AppConstants.esp32BaseUrl;

  String get baseUrl => _baseUrl;

  // ─── LOAD SAVED ESP URL ────────────────────────────────────────────────────
  Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('esp_ip') ?? AppConstants.esp32BaseUrl;
    print("🌐 Loaded ESP Base URL: $_baseUrl");
  }

  // ─── SAVE ESP URL ──────────────────────────────────────────────────────────
  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('esp_ip', url);
    _baseUrl = url;
    print("🌐 API Base URL updated & saved: $_baseUrl");
  }

  // ─── ESP32 UNLOCK ──────────────────────────────────────────────────────────
  Future<bool> unlockDoor() async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.unlockEndpoint}');
      print("🔓 Sending unlock request to: $url");

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'command': 'unlock', 'duration': 5}),
          )
          .timeout(const Duration(seconds: 10));

      print("📡 Unlock response code: ${response.statusCode}");
      print("📩 Unlock response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Unlock API error: $e");
      return false;
    }
  }

  // ─── ESP32 STATUS ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getDeviceStatus() async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.statusEndpoint}');
      print("📡 Checking device status: $url");

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      print("📡 Status response code: ${response.statusCode}");
      print("📩 Status response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("❌ Status API error: $e");
      return null;
    }
  }

  // ─── TEST CONNECTION ───────────────────────────────────────────────────────
  Future<bool> testConnection() async {
    try {
      final status = await getDeviceStatus();
      return status != null;
    } catch (e) {
      print("❌ Test connection failed: $e");
      return false;
    }
  }

  // ─── ESP32 CAPTURE (optional future use) ───────────────────────────────────
  Future<String?> triggerCapture() async {
    try {
      final url = Uri.parse('$_baseUrl${AppConstants.captureEndpoint}');
      print("📸 Triggering capture: $url");

      final response =
          await http.post(url).timeout(const Duration(seconds: 15));

      print("📡 Capture response code: ${response.statusCode}");
      print("📩 Capture response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['imageUrl'];
      }

      return null;
    } catch (e) {
      print("❌ Capture API error: $e");
      return null;
    }
  }

  // ─── FACE VERIFICATION PLACEHOLDER ─────────────────────────────────────────
  Future<bool> verifyFace(
    String capturedImageBase64,
    String ownerImageUrl,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    return capturedImageBase64.isNotEmpty;
  }
}
