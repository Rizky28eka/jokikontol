class ApiConfig {
  // Base URL for the API - can be changed based on environment
  static const String baseUrl =
      'http://10.100.184.125:8000/api'; // Update this with your backend URL

  // Environment-based configurations
  static const String developmentBaseUrl = 'http://10.100.184.125:8000/api';
  static const String productionBaseUrl = 'https://your-production-api.com/api';
  static const String stagingBaseUrl = 'https://staging.your-api.com/api';

  // Current environment - can be changed based on build flavor
  static String get currentBaseUrl {
    // In a real application, you might check for debug mode or build flavor
    // For now, we'll use the development URL
    return const bool.fromEnvironment('dart.vm.product')
        ? productionBaseUrl
        : developmentBaseUrl;
  }

  // API endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String userProfile = '/user/profile';
  static const String patients = '/patients';
  static const String forms = '/forms';
  static const String dashboardMahasiswa = '/dashboard/mahasiswa';
  static const String dashboardDosen = '/dashboard/dosen';
  static const String diagnoses = '/diagnoses';
  static const String interventions = '/interventions';
  static const String formsSubmitted = '/forms/submitted';
  static const String formReview = '/forms/{id}/review';
  static const String formGeneratePdf = '/forms/{id}/generate-pdf';
  static const String formUploadMaterial = '/forms/{id}/upload-material';
  static const String formUploadPhoto = '/forms/{id}/upload-photo';

  // Helper methods for dynamic endpoints
  static String formReviewEndpoint(String id) => '/forms/$id/review';
  static String formGeneratePdfEndpoint(String id) => '/forms/$id/generate-pdf';
  static String formUploadMaterialEndpoint(String id) => '/forms/$id/upload-material';
  static String formUploadPhotoEndpoint(String id) => '/forms/$id/upload-photo';
}
