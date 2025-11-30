import 'package:http/http.dart' as http;
import './api_service.dart';

class DashboardService {
  // Mahasiswa Stats
  static Future<http.Response> getMahasiswaStats() async {
    return ApiService.get('dashboard/mahasiswa');
  }

  // Dosen Stats
  static Future<http.Response> getDosenStats() async {
    return ApiService.get('dashboard/dosen');
  }

  // Latest Patients for Mahasiswa Dashboard
  static Future<http.Response> getLatestPatients() async {
    return ApiService.get('patients?limit=5&sort=created_at,desc');
  }
}
