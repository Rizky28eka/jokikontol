import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../controllers/auth_controller.dart';

class PatientService {
  static Future<http.Response> list({String? query}) async {
    final token = AuthController.to.token;
    final uri = Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.patients}')
        .replace(queryParameters: query != null && query.isNotEmpty ? {'search': query} : null);
    return http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }
}
