class ApiConfig {
  // Base URL for the API - can be changed based on environment
  // NOTE: If you encounter "Failed to fetch" errors with antivirus (Kaspersky):
  // 1. Use localhost instead of IP: 'http://localhost:8000/api'
  // 2. Add exception in antivirus settings for this app
  // 3. Or temporarily disable web protection during development
  // static const String baseUrl =
  //     'https://tamajiwa.bilcode.id/api'; // Update this with your backend URL
  static const String baseUrl =
      'https://tamajiwa.bilcode.id/api'; // Update this with your backend URL

  // Environment-based configurations
  static const String developmentBaseUrl = 'https://tamajiwa.bilcode.id/api';
  // static const String developmentBaseUrl = 'http://[nyesuain ip ente]:8000/api';
  static const String localhostBaseUrl = 'http://localhost:8000/api'; // Use this if antivirus blocks IP
  static const String productionBaseUrl = 'https://tamajiwa.bilcode.id/api';
  static const String stagingBaseUrl = 'https://staging.your-api.com/api';

  // Current environment - can be changed based on build flavor
  static String get currentBaseUrl {
    // In a real application, you might check for debug mode or build flavor
    // For now, we'll use the development URL
    // TIP: Change to localhostBaseUrl if you get connection errors
    return const bool.fromEnvironment('dart.vm.product')
        ? productionBaseUrl
        : developmentBaseUrl;
  }

  // API endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String userProfile = '/user/profile';
  static const String passwordResetRequest = '/forgot-password';
  static const String passwordReset = '/reset-password';
  static const String emailVerificationNotice = '/email/verification-notification';
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
