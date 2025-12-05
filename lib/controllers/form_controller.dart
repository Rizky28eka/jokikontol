import 'dart:convert';

import 'package:get/get.dart';
import 'package:tamajiwa/services/logger_service.dart';
import '../models/form_model.dart';
import '../services/api_service.dart';
import '../utils/form_data_mapper.dart';

class FormController extends GetxController {
  final LoggerService _logger = LoggerService();
  final RxList<FormModel> _forms = <FormModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<FormModel> get forms => _forms;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  Future<void> fetchForms({String? type, int? patientId}) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _forms.clear(); // Clear previous data before fetching
    _logger.form(operation: 'fetch', formType: type ?? 'all', patientId: patientId?.toString());

    try {
      String endpoint = 'forms';
      if (type != null || patientId != null) {
        endpoint += '?';
        List<String> params = [];
        if (type != null) params.add('type=$type');
        if (patientId != null) params.add('patient_id=$patientId');
        endpoint += params.join('&');
      }

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> formList = (data['data'] is List) 
            ? data['data'] as List<dynamic>
            : (data['data']['data'] as List<dynamic>);

        _forms.value = formList
            .map((json) => FormModel.fromJson(json as Map<String, dynamic>))
            .toList();
        _logger.info(
          'Successfully fetched forms',
          context: {'count': formList.length, 'patientId': patientId},
        );
      } else {
        _errorMessage.value = 'Failed to fetch forms';
        _logger.error(
          'Failed to fetch forms',
          error: response.body,
          stackTrace: StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error fetching forms: $e';
      _logger.error('Error fetching forms', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<FormModel?> createForm({
    required String type,
    required int patientId,
    Map<String, dynamic>? data,
    String status = 'submitted',
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.form(
      operation: 'create',
      formType: type,
      patientId: patientId.toString(),
      status: status,
      data: data,
    );

    try {
      // Map form data to new structured format
      final mappedData = data != null 
          ? FormDataMapper.mapToApiFormat(type, {...data, 'patient_id': patientId, 'status': status})
          : {'type': type, 'patient_id': patientId, 'status': status, 'data': {}};

      _logger.info('Mapped data for API', context: {'mappedData': mappedData});

      final response = await ApiService.post('forms', body: mappedData);

      _logger.info('API Response', context: {'statusCode': response.statusCode, 'body': response.body});

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newForm = FormModel.fromJson(data['form']);
        // Don't auto-refresh to avoid ANR, let caller handle navigation
        _logger.info('Form created successfully', context: {'type': type, 'formId': newForm.id});
        return newForm;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to create form';
        _logger.error(
          'Failed to create form - API Error',
          error: _errorMessage.value,
          context: {'statusCode': response.statusCode, 'response': errorData},
        );
        if (Get.isSnackbarOpen != true) {
          Get.snackbar('Error', _errorMessage.value);
        }
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error creating form: $e';
      _logger.error('Error creating form', error: e, stackTrace: stackTrace);
      if (Get.isSnackbarOpen != true) {
        Get.snackbar(
          'Error', 
          'Gagal membuat form: ${e.toString()}',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      _isLoading.value = false;
    }
    return null;
  }

  Future<FormModel?> updateForm({
    required int id,
    String? type,
    int? patientId,
    Map<String, dynamic>? data,
    String? status,
    String? comments,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.form(
      operation: 'update',
      formType: type ?? 'unknown',
      formId: id.toString(),
      patientId: patientId?.toString(),
      status: status,
      data: data,
      metadata: {'comments': comments},
    );

    try {
      final Map<String, dynamic> body = {};
      if (type != null) body['type'] = type;
      if (patientId != null) body['patient_id'] = patientId;
      if (data != null) body['data'] = data;
      if (status != null) body['status'] = status;
      if (comments != null) body['comments'] = comments;

      final response = await ApiService.put('forms/$id', body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedForm = FormModel.fromJson(data['form']);
        // Don't auto-refresh to avoid ANR
        Get.snackbar('Success', 'Form updated successfully');
        _logger.info('Form updated successfully', context: {'formId': id});
        return updatedForm;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to update form';
        Get.snackbar('Error', _errorMessage.value);
        _logger.error(
          'Failed to update form',
          error: _errorMessage.value,
          stackTrace: StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error updating form: $e';
      Get.snackbar('Error', _errorMessage.value);
      _logger.error('Error updating form', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
    return null;
  }

  Future<FormModel?> getFormById(int id) async {
    _logger.form(
      operation: 'get by id',
      formType: 'unknown',
      formId: id.toString(),
    );
    try {
      final response = await ApiService.get('forms/$id');

      if (response.statusCode == 200) {
        final formData = json.decode(response.body);
        _logger.form(
          operation: 'Successfully fetched form by id',
          formType: formData['type'] ?? 'unknown',
          formId: id.toString(),
        );
        return FormModel.fromJson(formData);
      } else {
        _logger.warning('Could not find form with id $id');
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error fetching form: $e';
      _logger.error(
        'Error fetching form by id',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  /// Fetch SVG preview for a form's genogram as raw string
  Future<String?> fetchGenogramSvg(int formId) async {
    try {
      final response = await ApiService.get('forms/$formId/genogram/svg');
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      _logger.error('Error fetching genogram svg', error: e);
    }
    return null;
  }

  Future<bool> deleteForm(int id) async {
    _logger.form(
      operation: 'delete',
      formType: 'unknown',
      formId: id.toString(),
    );
    try {
      final response = await ApiService.delete('forms/$id');

      if (response.statusCode == 200) {
        // Remove from local list instead of fetching all
        _forms.removeWhere((form) => form.id == id);
        _logger.info('Form deleted successfully', context: {'formId': id});
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to delete form';
        _logger.error(
          'Failed to delete form',
          error: _errorMessage.value,
          stackTrace: StackTrace.current,
        );
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error deleting form: $e';
      _logger.error('Error deleting form', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
