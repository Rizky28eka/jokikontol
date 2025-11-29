import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../constants/app_routes.dart';
import '../constants/api_config.dart';
import '../services/logger_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final RxString _token = ''.obs;
  DateTime? _loginTime;
  final LoggerService _logger = LoggerService();

  UserModel? get user => _user.value;
  String get token => _token.value;

  bool isTokenValid() {
    if (_token.value.isEmpty || _loginTime == null) return false;

    final difference = DateTime.now().difference(_loginTime!);
    if (difference.inHours >= 1) {
      _logger.info(
        'Token expired. Session duration: ${difference.inMinutes} minutes.',
      );
      logout(reason: 'Session expired');
      return false;
    }
    return true;
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    _logger.auth(event: 'Registration attempt', userEmail: email);
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _logger.warning(
        'Registration failed: Fields were empty.',
        context: {'email': email},
      );
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.register}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // Clear any lingering user data just in case.
        _user.value = null;
        _token.value = '';
        _loginTime = null;

        _logger.auth(event: 'Registration success', userEmail: email);

        Get.snackbar('Success', 'Registration successful! Please log in.');
        Get.offAllNamed(AppRoutes.login);
      } else {
        final errorMessage = data['message'] ?? 'An unknown error occurred.';
        _logger.auth(
          event: 'Registration failed',
          userEmail: email,
          success: false,
          errorMessage: errorMessage,
        );
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final formattedErrors = errors.values
              .map((e) => (e as List).join('\n'))
              .join('\n');
          Get.snackbar('Registration Failed', formattedErrors);
        } else {
          Get.snackbar('Registration Failed', errorMessage);
        }
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Registration connection error',
        error: e,
        stackTrace: stackTrace,
        context: {'email': email},
      );
      Get.snackbar('Error', 'Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    _logger.auth(event: 'Login attempt', userEmail: email);
    if (email.isEmpty || password.isEmpty) {
      _logger.warning(
        'Login failed: Fields were empty.',
        context: {'email': email},
      );
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.login}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(data['user']);
        final token = data['token'];

        _token.value = token;
        _loginTime = DateTime.now();
        _user.value = user;

        _logger.auth(
          event: 'Login success',
          userId: user.id.toString(),
          userEmail: user.email,
        );

        Get.snackbar('Success', 'Login successful');

        if (user.role == 'dosen') {
          Get.offAllNamed(AppRoutes.dosenDashboard);
        } else {
          Get.offAllNamed(AppRoutes.mahasiswaDashboard);
        }
      } else {
        final message = data['message'] ?? 'Invalid credentials';
        _logger.auth(
          event: 'Login failed',
          userEmail: email,
          success: false,
          errorMessage: message,
        );
        Get.snackbar('Login Failed', message);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Login connection error',
        error: e,
        stackTrace: stackTrace,
        context: {'email': email},
      );
      Get.snackbar('Error', 'Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout({String? reason}) async {
    _logger.auth(
      event: 'Logout attempt',
      userId: _user.value?.id.toString(),
      userEmail: _user.value?.email,
      errorMessage: reason,
    );
    try {
      if (_token.value.isNotEmpty) {
        // Attempt to call logout API, but don't block local logout if it fails
        try {
          await http.post(
            Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.logout}'),
            headers: <String, String>{
              'Authorization': 'Bearer ${_token.value}',
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );
        } catch (e) {
          _logger.warning(
            'API Logout failed, proceeding with local logout',
            context: {'error': e.toString()},
          );
        }
      }

      _token.value = '';
      _loginTime = null;
      _user.value = null;

      _logger.auth(
        event: 'Logout success',
        userId: _user.value?.id.toString(),
        userEmail: _user.value?.email,
      );

      if (reason != null) {
        Get.snackbar(
          'Session Expired',
          'Your session has expired. Please log in again.',
        );
      } else {
        Get.snackbar('Success', 'Logged out successfully');
      }
      Get.offAllNamed(AppRoutes.login);
    } catch (e, stackTrace) {
      _logger.error(
        'Logout failed',
        error: e,
        stackTrace: stackTrace,
        context: {'userId': _user.value?.id.toString()},
      );
      // Force logout on error
      _token.value = '';
      _loginTime = null;
      _user.value = null;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<bool> checkAuth() async {
    _logger.debug('Checking authentication status...');

    if (!isTokenValid()) {
      _logger.info('No valid token found, user is not authenticated.');
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.userProfile}'),
        headers: <String, String>{
          'Authorization': 'Bearer ${_token.value}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user.value = UserModel.fromJson(data);
        _logger.info(
          'User is authenticated.',
          context: {'userId': _user.value?.id},
        );
        return true;
      } else {
        _logger.warning(
          'Auth check failed: Invalid token response.',
          context: {'statusCode': response.statusCode},
        );
        logout(reason: 'Session invalid');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Auth check connection error',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<UserModel?> getUserProfile() async {
    _logger.debug('Fetching user profile...');

    if (!isTokenValid()) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.userProfile}'),
        headers: <String, String>{
          'Authorization': 'Bearer ${_token.value}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data);
        _user.value = user;
        _logger.info(
          'Successfully fetched user profile.',
          context: {'userId': user.id},
        );
        return user;
      } else {
        _logger.warning(
          'Failed to fetch user profile.',
          context: {'statusCode': response.statusCode},
        );
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Get user profile failed',
        error: e,
        stackTrace: stackTrace,
        context: {'userId': _user.value?.id.toString()},
      );
    }
    return null;
  }

  Future<void> updateProfile({String? name, String? password}) async {
    _logger.info(
      'Attempting to update profile...',
      context: {'userId': _user.value?.id},
    );

    if (!isTokenValid()) {
      _logger.error('Profile update failed: Not authenticated.');
      Get.snackbar('Error', 'Not authenticated');
      return;
    }

    isLoading.value = true;

    try {
      final Map<String, dynamic> body = {};
      if (name != null && name.isNotEmpty) {
        body['name'] = name;
      }
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
        body['password_confirmation'] = password;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.userProfile}'),
        headers: <String, String>{
          'Authorization': 'Bearer ${_token.value}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedUser = UserModel.fromJson(data['user']);
        _user.value = updatedUser;

        _logger.info(
          'Profile updated successfully.',
          context: {'userId': updatedUser.id},
        );
        Get.snackbar('Success', data['message']);
      } else {
        final errorData = json.decode(response.body);
        _logger.error(
          'Profile update failed.',
          context: {
            'statusCode': response.statusCode,
            'error': errorData['message'],
          },
        );
        Get.snackbar(
          'Update Failed',
          errorData['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Profile update connection error',
        error: e,
        stackTrace: stackTrace,
        context: {'userId': _user.value?.id.toString()},
      );
      Get.snackbar('Error', 'Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
