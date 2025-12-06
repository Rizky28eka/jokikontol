import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../controllers/auth_controller.dart';

class NursingService {
  static Future<http.Response> listDiagnoses() async {
    final token = AuthController.to.token;
    return http.get(
      Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.diagnoses}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  static Future<http.Response> listInterventions() async {
    final token = AuthController.to.token;
    return http.get(
      Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.interventions}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }
}
