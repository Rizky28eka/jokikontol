import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../services/logger_service.dart';
import '../controllers/auth_controller.dart';

class ApiService {
  static String get baseUrl => ApiConfig.currentBaseUrl;
  static final LoggerService _logger = LoggerService();

  // Helper method to get token with error handling
  static Future<String?> _getToken() async {
    try {
      final token = AuthController.to.token;
      
      if (token.isEmpty) {
        _logger.warning('Token is empty');
        return null;
      }
      
      final isValid = AuthController.to.isTokenValid();
      if (!isValid) {
        _logger.warning('Token is not valid');
        return null;
      }
      
      return token;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get token from AuthController',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // GET request with authorization
  static Future<http.Response> get(String endpoint) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        _logger.warning(
          'No token found for API request',
          context: {'endpoint': endpoint, 'method': 'GET'},
        );
        return http.Response('{"message": "Unauthenticated"}', 401);
      }

      final uri = Uri.parse('$baseUrl/$endpoint');
      _logger.info(
        'Making GET request',
        context: {'uri': uri.toString(), 'method': 'GET'},
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      _logger.apiCall(
        url: uri.toString(),
        method: 'GET',
        statusCode: response.statusCode,
        durationMs: null,
        responseData: response.body.length > 500
            ? response.body.substring(0, 500) + '...'
            : response.body,
      );

      return response;
    } catch (e, stackTrace) {
      _logger.error(
        'Network error in GET request',
        error: e,
        stackTrace: stackTrace,
        context: {'endpoint': endpoint},
      );
      return http.Response(
        jsonEncode({"message": "Network error", "error": e.toString()}),
        500,
      );
    }
  }

  // POST request with authorization
  static Future<http.Response> post(String endpoint, {dynamic body}) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        _logger.warning(
          'No token found for API request',
          context: {'endpoint': endpoint, 'method': 'POST'},
        );
        return http.Response('{"message": "Unauthenticated"}', 401);
      }

      final uri = Uri.parse('$baseUrl/$endpoint');
      _logger.info(
        'Making POST request',
        context: {'uri': uri.toString(), 'method': 'POST', 'body': body},
      );

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      _logger.apiCall(
        url: uri.toString(),
        method: 'POST',
        statusCode: response.statusCode,
        durationMs: null,
        requestBody: body,
        responseData: response.body.length > 500
            ? response.body.substring(0, 500) + '...'
            : response.body,
      );

      return response;
    } catch (e, stackTrace) {
      _logger.error(
        'Network error in POST request',
        error: e,
        stackTrace: stackTrace,
        context: {'endpoint': endpoint, 'body': body},
      );
      return http.Response(
        jsonEncode({"message": "Network error", "error": e.toString()}),
        500,
      );
    }
  }

  // PUT request with authorization
  static Future<http.Response> put(String endpoint, {dynamic body}) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        _logger.warning(
          'No token found for API request',
          context: {'endpoint': endpoint, 'method': 'PUT'},
        );
        return http.Response('{"message": "Unauthenticated"}', 401);
      }

      final uri = Uri.parse('$baseUrl/$endpoint');
      _logger.info(
        'Making PUT request',
        context: {'uri': uri.toString(), 'method': 'PUT', 'body': body},
      );

      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      _logger.apiCall(
        url: uri.toString(),
        method: 'PUT',
        statusCode: response.statusCode,
        durationMs: null,
        requestBody: body,
        responseData: response.body.length > 500
            ? response.body.substring(0, 500) + '...'
            : response.body,
      );

      return response;
    } catch (e, stackTrace) {
      _logger.error(
        'Network error in PUT request',
        error: e,
        stackTrace: stackTrace,
        context: {'endpoint': endpoint, 'body': body},
      );
      return http.Response(
        jsonEncode({"message": "Network error", "error": e.toString()}),
        500,
      );
    }
  }

  // DELETE request with authorization
  static Future<http.Response> delete(String endpoint) async {
    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        _logger.warning(
          'No token found for API request',
          context: {'endpoint': endpoint, 'method': 'DELETE'},
        );
        return http.Response('{"message": "Unauthenticated"}', 401);
      }

      final uri = Uri.parse('$baseUrl/$endpoint');
      _logger.info(
        'Making DELETE request',
        context: {'uri': uri.toString(), 'method': 'DELETE'},
      );

      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      _logger.apiCall(
        url: uri.toString(),
        method: 'DELETE',
        statusCode: response.statusCode,
        durationMs: null,
        responseData: response.body.length > 500
            ? response.body.substring(0, 500) + '...'
            : response.body,
      );

      return response;
    } catch (e, stackTrace) {
      _logger.error(
        'Network error in DELETE request',
        error: e,
        stackTrace: stackTrace,
        context: {'endpoint': endpoint},
      );
      return http.Response(
        jsonEncode({"message": "Network error", "error": e.toString()}),
        500,
      );
    }
  }

  // Public POST request (no authorization needed)
  static Future<http.Response> postPublic(
    String endpoint, {
    dynamic body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      _logger.info(
        'Making public POST request',
        context: {'uri': uri.toString(), 'method': 'POST'},
      );

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      _logger.apiCall(
        url: uri.toString(),
        method: 'POST',
        statusCode: response.statusCode,
        durationMs: null,
        requestBody: body,
        responseData: response.body.length > 500
            ? response.body.substring(0, 500) + '...'
            : response.body,
      );

      return response;
    } catch (e, stackTrace) {
      _logger.error(
        'Network error in public POST request',
        error: e,
        stackTrace: stackTrace,
        context: {'endpoint': endpoint, 'body': body},
      );
      return http.Response(
        jsonEncode({"message": "Network error", "error": e.toString()}),
        500,
      );
    }
  }

  // Public GET request (no authorization needed)
  static Future<http.Response> getPublic(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      _logger.info(
        'Making public GET request',
        context: {'uri': uri.toString(), 'method': 'GET'},
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      _logger.apiCall(
        url: uri.toString(),
        method: 'GET',
        statusCode: response.statusCode,
        durationMs: null,
        responseData: response.body.length > 500
            ? response.body.substring(0, 500) + '...'
            : response.body,
      );

      return response;
    } catch (e, stackTrace) {
      _logger.error(
        'Network error in public GET request',
        error: e,
        stackTrace: stackTrace,
        context: {'endpoint': endpoint},
      );
      return http.Response(
        jsonEncode({"message": "Network error", "error": e.toString()}),
        500,
      );
    }
  }
}
