import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../services/dashboard_service.dart';
import '../services/logger_service.dart';
import 'auth_controller.dart';

class DashboardController extends GetxController {
  final LoggerService _logger = LoggerService();
  final AuthController _authController = Get.find<AuthController>();

  final RxMap<String, dynamic> _mahasiswaStats = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> _dosenStats = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> _latestPatients = <Map<String, dynamic>>[].obs;
  final RxBool _isMahasiswaStatsLoading = false.obs;
  final RxBool _isDosenStatsLoading = false.obs;
  final RxBool _isLatestPatientsLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  Map<String, dynamic> get mahasiswaStats => _mahasiswaStats;
  Map<String, dynamic> get dosenStats => _dosenStats;
  List<Map<String, dynamic>> get latestPatients => _latestPatients;
  bool get isMahasiswaStatsLoading => _isMahasiswaStatsLoading.value;
  bool get isDosenStatsLoading => _isDosenStatsLoading.value;
  bool get isLatestPatientsLoading => _isLatestPatientsLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    final userRole = _authController.user?.role;
    final hasToken = _authController.token.isNotEmpty;
    
    _logger.info('Dashboard initialized', context: {
      'userRole': userRole,
      'hasToken': hasToken
    });

    if (!hasToken) {
      _logger.error('No token available');
      _showSessionExpiredDialog();
      return;
    }

    if (userRole == 'mahasiswa') {
      fetchMahasiswaStats();
      fetchLatestPatients();
    } else if (userRole == 'dosen') {
      fetchDosenStats();
    }
  }

  /// --------------------------------------------------------
  /// 🔒 CEK HTML RESPONSE (MENTAH) → artinya redirect login
  /// --------------------------------------------------------
  bool _isSessionExpired(response) {
    if (response.headers == null) {
      _logger.warning(
        'Response headers are null, cannot check session',
      );
      return false;
    }

    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    final isHtmlResponse = contentType.contains('text/html');

    if (isHtmlResponse) {
      _logger.warning(
        'Received HTML response -> likely session expired / redirect login',
        context: {'contentType': contentType}
      );

      Get.dialog(
        AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Your session has expired. Please log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                _authController.logout();
              },
              child: const Text('OK'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      return true;
    }
    return false;
  }

  /// --------------------------------------------------------
  /// 📊 FETCH MAHASISWA
  /// --------------------------------------------------------
  Future<void> fetchMahasiswaStats() async {
    _logger.info(
      'Fetching mahasiswa stats...',
      context: {'userId': _authController.user?.id},
    );

    _isMahasiswaStatsLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await DashboardService.getMahasiswaStats();

      if (_isSessionExpired(response)) return;

      // Check if response body is valid JSON
      if (response.body.isEmpty) {
        _errorMessage.value = 'Empty response from server';
        _logger.error(
          'Empty response body from mahasiswa stats API',
          context: {'statusCode': response.statusCode},
        );
        return;
      }

      Map<String, dynamic>? data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (e, stackTrace) {
        _logger.error(
          'Failed to decode JSON response from mahasiswa stats API',
          error: e,
          stackTrace: stackTrace,
          context: {
            'statusCode': response.statusCode,
            'responseBody': response.body,
          },
        );
        _errorMessage.value = 'Invalid response format: $e';
        return;
      }

      if (response.statusCode == 200) {
        // Assign the data (we're confident it's not null after successful parsing)
        _mahasiswaStats.value = data;
        _logger.info('Mahasiswa stats loaded successfully', context: data);
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be expired
        _errorMessage.value = 'Authentication required';
        _logger.error(
          'Authentication failed when fetching mahasiswa stats',
          context: {'statusCode': response.statusCode},
        );
        // Show session expired dialog
        _showSessionExpiredDialog();
      } else {
        // Other error status codes
        _errorMessage.value = data['message'] ?? 'Failed to fetch mahasiswa stats (Status: ${response.statusCode})';
        _logger.error(
          'Failed to fetch mahasiswa stats',
          error: _errorMessage.value,
          context: {
            'statusCode': response.statusCode,
            'responseBody': data,
          },
        );
      }
    } on FormatException catch (e, s) {
      _errorMessage.value = 'Invalid data format received';
      _logger.error('Invalid data format in mahasiswa stats response',
        error: e,
        stackTrace: s
      );
    } on Exception catch (e, s) {
      _errorMessage.value = 'Network error: $e';
      _logger.error('Network error fetching mahasiswa stats',
        error: e,
        stackTrace: s
      );
    } catch (e, s) {
      _errorMessage.value = 'Unexpected error: $e';
      _logger.error('Unexpected error in mahasiswa stats fetch',
        error: e,
        stackTrace: s
      );
    } finally {
      _isMahasiswaStatsLoading.value = false;
    }
  }

  /// --------------------------------------------------------
  /// 📊 FETCH DOSEN
  /// --------------------------------------------------------
  Future<void> fetchDosenStats() async {
    _logger.info(
      'Fetching dosen stats...',
      context: {'userId': _authController.user?.id},
    );

    _isDosenStatsLoading.value = true;
    _errorMessage.value = '';

    try {
      final response = await DashboardService.getDosenStats();

      if (_isSessionExpired(response)) return;

      // Check if response body is valid JSON
      if (response.body.isEmpty) {
        _errorMessage.value = 'Empty response from server';
        _logger.error(
          'Empty response body from dosen stats API',
          context: {'statusCode': response.statusCode},
        );
        return;
      }

      Map<String, dynamic>? data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (e, stackTrace) {
        _logger.error(
          'Failed to decode JSON response from dosen stats API',
          error: e,
          stackTrace: stackTrace,
          context: {
            'statusCode': response.statusCode,
            'responseBody': response.body,
          },
        );
        _errorMessage.value = 'Invalid response format: $e';
        return;
      }

      if (response.statusCode == 200) {
        // Assign the data (we're confident it's not null after successful parsing)
        _dosenStats.value = data;
        _logger.info('Dosen stats loaded successfully', context: data);
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be expired
        _errorMessage.value = 'Authentication required';
        _logger.error(
          'Authentication failed when fetching dosen stats',
          context: {'statusCode': response.statusCode},
        );
        // Show session expired dialog
        _showSessionExpiredDialog();
      } else {
        // Other error status codes
        _errorMessage.value = data['message'] ?? 'Failed to fetch dosen stats (Status: ${response.statusCode})';
        _logger.error(
          'Failed to fetch dosen stats',
          error: _errorMessage.value,
          context: {
            'statusCode': response.statusCode,
            'responseBody': data,
          },
        );
      }
    } on FormatException catch (e, s) {
      _errorMessage.value = 'Invalid data format received';
      _logger.error('Invalid data format in dosen stats response',
        error: e,
        stackTrace: s
      );
    } on Exception catch (e, s) {
      _errorMessage.value = 'Network error: $e';
      _logger.error('Network error fetching dosen stats',
        error: e,
        stackTrace: s
      );
    } catch (e, s) {
      _errorMessage.value = 'Unexpected error: $e';
      _logger.error('Unexpected error in dosen stats fetch',
        error: e,
        stackTrace: s
      );
    } finally {
      _isDosenStatsLoading.value = false;
    }
  }

  /// --------------------------------------------------------
  /// 👥 FETCH LATEST PATIENTS
  /// --------------------------------------------------------
  Future<void> fetchLatestPatients() async {
    _logger.info(
      'Fetching latest patients...',
      context: {'userId': _authController.user?.id},
    );

    _isLatestPatientsLoading.value = true;

    try {
      final response = await DashboardService.getLatestPatients();

      if (_isSessionExpired(response)) return;

      // Check if response body is valid JSON
      if (response.body.isEmpty) {
        _logger.error(
          'Empty response body from latest patients API',
          context: {'statusCode': response.statusCode},
        );
        return;
      }

      Map<String, dynamic>? data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (e, stackTrace) {
        _logger.error(
          'Failed to decode JSON response from latest patients API',
          error: e,
          stackTrace: stackTrace,
          context: {
            'statusCode': response.statusCode,
            'responseBody': response.body,
          },
        );
        return;
      }

      if (response.statusCode == 200) {
        // Extract the patients list from the response
        List<dynamic> patientsList = data['data'] ?? data['patients'] ?? [];

        // Convert to List<Map<String, dynamic>>
        List<Map<String, dynamic>> patients = patientsList
            .map((patient) => patient as Map<String, dynamic>)
            .toList();

        _latestPatients.assignAll(patients);
        _logger.info('Latest patients loaded successfully', context: {
          'count': patients.length,
          'data': data
        });
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be expired
        _logger.error(
          'Authentication failed when fetching latest patients',
          context: {'statusCode': response.statusCode},
        );
        // Show session expired dialog
        _showSessionExpiredDialog();
      } else {
        // Other error status codes
        _logger.error(
          'Failed to fetch latest patients',
          error: data['message'] ?? 'Unknown error',
          context: {
            'statusCode': response.statusCode,
            'responseBody': data,
          },
        );
      }
    } on FormatException catch (e, s) {
      _logger.error('Invalid data format in latest patients response',
        error: e,
        stackTrace: s
      );
    } on Exception catch (e, s) {
      _logger.error('Network error fetching latest patients',
        error: e,
        stackTrace: s
      );
    } catch (e, s) {
      _logger.error('Unexpected error in latest patients fetch',
        error: e,
        stackTrace: s
      );
    } finally {
      _isLatestPatientsLoading.value = false;
    }
  }

  /// Helper method to show session expired dialog
  void _showSessionExpiredDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please log in again.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _authController.logout();
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
