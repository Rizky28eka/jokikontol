import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';
import '../services/logger_service.dart';

class DashboardService {
  static String get baseUrl => ApiConfig.currentBaseUrl;
  static final LoggerService _logger = LoggerService();

  // 🔒 Helper mengambil token
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      return token;
    } catch (e, stackTrace) {
      _logger.error('Failed to get token from SharedPreferences',
        error: e,
        stackTrace: stackTrace
      );
      return null;
    }
  }

  // 🔽 Wrapper request GET
  static Future<http.Response> _get(String endpoint) async {
    try {
      final token = await _getToken();

      // Jika token null, backend pasti redirect -> langsung error
      if (token == null || token.isEmpty) {
        _logger.warning('No token found for API request',
          context: {'endpoint': endpoint}
        );
        return http.Response('{"message": "Unauthenticated"}', 401);
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      _logger.info('Making API request',
        context: {'uri': uri.toString(), 'method': 'GET'}
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json', // ⭐ WAJIB
          'Authorization': 'Bearer $token', // ⭐ WAJIB
          'Content-Type': 'application/json',
        },
      );

      _logger.apiCall(
        url: uri.toString(),
        method: 'GET',
        statusCode: response.statusCode,
        durationMs: null,
        responseData: response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body
      );

      return response;
    } catch (e, stackTrace) {
      _logger.error('Network error in API request',
        error: e,
        stackTrace: stackTrace,
        context: {'endpoint': endpoint}
      );
      return http.Response(jsonEncode({"message": "Network error", "error": e.toString()}), 500);
    }
  }

  // Mahasiswa Stats
  static Future<http.Response> getMahasiswaStats() async {
    return _get('/dashboard/mahasiswa');
  }

  // Dosen Stats
  static Future<http.Response> getDosenStats() async {
    return _get('/dashboard/dosen');
  }

  // Latest Patients for Mahasiswa Dashboard
  static Future<http.Response> getLatestPatients() async {
    // Adding query parameter to get only latest patients (e.g., last 5)
    return _get('/patients?limit=5&sort=created_at,desc');
  }
}
