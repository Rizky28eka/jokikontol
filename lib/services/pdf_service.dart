import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

class PdfService {
  static String get baseUrl => ApiConfig.currentBaseUrl;

  // Generate PDF for a form
  static Future<http.Response> generatePdf(int formId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/forms/$formId/generate-pdf'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response;
  }
}