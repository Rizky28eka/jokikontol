import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../constants/app_routes.dart';
import '../services/logger_service.dart';
import 'dart:async';

class SplashController extends GetxController {
  late final AuthController _authController;
  final LoggerService _logger = LoggerService();

  @override
  void onInit() {
    super.onInit();
    _logger.info('SplashController initializing...');
    _authController = Get.find();
  }

  @override
  void onReady() {
    super.onReady();
    _logger.info('SplashController ready, starting initialization process...');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Log splash screen initialization
      _logger.info('Splash screen initialization started',
        context: {
          'timestamp': DateTime.now().toIso8601String(),
          'process': 'splash_init'
        }
      );

      // Wait for a bit to show splash screen
      _logger.debug('Starting splash screen delay for 2 seconds...');
      await Future.delayed(const Duration(seconds: 2));
      _logger.debug('Splash screen delay completed');

      _logger.info('Begin authentication check process',
        context: {
          'process': 'auth_check',
          'step': 'token_verification'
        }
      );

      // Log token existence check
      final tokenExists = await _checkTokenExists();
      _logger.debug('Token existence check complete',
        context: {
          'token_exists': tokenExists
        }
      );

      if (tokenExists) {
        _logger.info('Token found, proceeding with authentication verification');
      } else {
        _logger.info('No token found, user is not authenticated');
      }

      // Add timeout to prevent hanging on authentication check
      final bool isAuthenticated = await _runWithTimeout(
        _authController.checkAuth(),
        const Duration(seconds: 10), // 10 second timeout
        'Authentication check timeout'
      );

      _logger.info('Authentication check completed',
        context: {
          'is_authenticated': isAuthenticated,
          'process': 'auth_check',
          'step': 'verification_complete'
        }
      );

      if (isAuthenticated) {
        final userRole = _authController.user?.role;
        final userId = _authController.user?.id.toString();
        final userEmail = _authController.user?.email;

        _logger.auth(
          event: 'Splash authentication check success',
          userId: userId,
          userEmail: userEmail,
          success: true
        );

        _logger.info('User authenticated successfully, determining navigation destination',
          context: {
            'user_id': userId,
            'user_email': userEmail,
            'user_role': userRole,
            'process': 'navigation_decision'
          }
        );

        if (userRole == 'dosen') {
          _logger.navigation(from: 'Splash', to: 'DosenDashboard',
            arguments: {
              'userId': userId,
              'userRole': userRole
            }
          );
          _logger.info('Redirecting to dosen dashboard',
            context: {
              'destination': 'dosen_dashboard',
              'user_role': userRole,
              'process': 'navigation'
            }
          );
          Get.offAllNamed(AppRoutes.dosenDashboard);
        } else {
          _logger.navigation(from: 'Splash', to: 'MahasiswaDashboard',
            arguments: {
              'userId': userId,
              'userRole': userRole
            }
          );
          _logger.info('Redirecting to mahasiswa dashboard',
            context: {
              'destination': 'mahasiswa_dashboard',
              'user_role': userRole,
              'process': 'navigation'
            }
          );
          Get.offAllNamed(AppRoutes.mahasiswaDashboard);
        }
      } else {
        _logger.auth(
          event: 'Splash authentication check failed - no valid user',
          success: false
        );

        _logger.navigation(from: 'Splash', to: 'Login');
        _logger.info('User not authenticated, redirecting to login',
          context: {
            'destination': 'login',
            'reason': 'not_authenticated',
            'process': 'navigation'
          }
        );
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e, stackTrace) {
      _logger.error('Splash screen initialization failed',
        error: e,
        stackTrace: stackTrace,
        context: {
          'process': 'splash_init',
          'error_type': e.runtimeType.toString()
        }
      );

      // If there's an error checking auth, redirect to login as a fallback
      _logger.navigation(from: 'Splash', to: 'Login',
        arguments: {
          'reason': 'initialization_error'
        }
      );
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // Helper method to run async operations with timeout
  Future<T> _runWithTimeout<T>(Future<T> future, Duration timeout, String timeoutMessage) async {
    try {
      return await future.timeout(timeout, onTimeout: () {
        _logger.warning('$timeoutMessage after ${timeout.inSeconds} seconds');
        throw TimeoutException(timeoutMessage, timeout);
      });
    } catch (e) {
      if (e is TimeoutException) {
        _logger.error('Operation timed out: $timeoutMessage',
          context: {'timeout_duration': timeout.inSeconds});
        // Return a default value for authentication (false = not authenticated)
        if (T == bool) {
          return false as T;
        }
        rethrow;
      } else {
        _logger.error('Operation failed with error: $e', error: e);
        rethrow;
      }
    }
  }

  Future<bool> _checkTokenExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      _logger.debug('Token existence verification performed',
        context: {
          'token_found': token != null,
          'token_length': token?.length ?? 0
        }
      );
      return token != null;
    } catch (e) {
      _logger.error('Token existence check failed', error: e);
      return false;
    }
  }
}
