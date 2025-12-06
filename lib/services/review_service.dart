import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';
import '../services/logger_service.dart';

class ReviewService {
  static String get baseUrl => ApiConfig.currentBaseUrl;

  // GET all submitted forms
  static Future<http.Response> getSubmittedForms() async {
    final logger = LoggerService();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    logger.debug('Getting submitted forms', context: {'hasToken': token != null});

    final response = await http.get(
      Uri.parse('$baseUrl/forms/submitted'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    logger.network(
      method: 'GET',
      url: '$baseUrl/forms/submitted',
      statusCode: response.statusCode,
      requestBody: null,
      responseBody: response.body,
    );

    return response;
  }

  // POST review for a form
  static Future<http.Response> reviewForm(int formId, String status, String? comment) async {
    final logger = LoggerService();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    logger.info('Submitting form review', context: {'formId': formId, 'status': status, 'comment': comment ?? 'No comment'});

    final response = await http.post(
      Uri.parse('$baseUrl/forms/$formId/review'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'status': status,
        'comment': comment,
      }),
    );

    logger.network(
      method: 'POST',
      url: '$baseUrl/forms/$formId/review',
      statusCode: response.statusCode,
      requestBody: {'status': status, 'comment': comment},
      responseBody: response.body,
    );

    return response;
  }
}