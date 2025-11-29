import 'package:get/get.dart';
import 'dart:convert';
import 'package:tamajiwa/services/logger_service.dart';
import '../models/nursing_diagnosis_model.dart';
import '../services/nursing_diagnosis_service.dart';

class NursingDiagnosisController extends GetxController {
  final LoggerService _logger = LoggerService();
  final RxList<NursingDiagnosis> _diagnoses = <NursingDiagnosis>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<NursingDiagnosis> get diagnoses => _diagnoses;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchDiagnoses();
  }

  Future<void> fetchDiagnoses() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.info('Fetching nursing diagnoses');

    try {
      final response = await NursingDiagnosisService.getDiagnoses();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> diagnosisList = data as List<dynamic>;

        _diagnoses.value = diagnosisList
            .map((json) =>
                NursingDiagnosis.fromJson(json as Map<String, dynamic>))
            .toList();
        _logger.info('Successfully fetched nursing diagnoses',
            context: {'count': _diagnoses.length});
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value =
            errorData['message'] ?? 'Failed to fetch diagnoses';
        _logger.error('Failed to fetch diagnoses',
            error: response.body, stackTrace: StackTrace.current);
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error fetching diagnoses: $e';
      _logger.error('Error fetching diagnoses',
          error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createDiagnosis(String name, String? description) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.info('Creating diagnosis',
        context: {'name': name, 'description': description});

    try {
      final response = await NursingDiagnosisService.createDiagnosis({
        'name': name,
        'description': description,
      });

      if (response.statusCode == 201) {
        await fetchDiagnoses(); // Refresh the list
        Get.snackbar('Success', 'Diagnosis created successfully');
        _logger.info('Diagnosis created successfully', context: {'name': name});
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value =
            errorData['message'] ?? 'Failed to create diagnosis';
        Get.snackbar('Error', _errorMessage.value);
        _logger.error('Failed to create diagnosis',
            error: _errorMessage.value, stackTrace: StackTrace.current);
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error creating diagnosis: $e';
      Get.snackbar('Error', _errorMessage.value);
      _logger.error('Error creating diagnosis',
          error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateDiagnosis(int id, String name, String? description) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.info('Updating diagnosis', context: {
      'id': id,
      'name': name,
      'description': description
    });

    try {
      final response = await NursingDiagnosisService.updateDiagnosis(id, {
        'name': name,
        'description': description,
      });

      if (response.statusCode == 200) {
        await fetchDiagnoses(); // Refresh the list
        Get.snackbar('Success', 'Diagnosis updated successfully');
        _logger.info('Diagnosis updated successfully', context: {'id': id});
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value =
            errorData['message'] ?? 'Failed to update diagnosis';
        Get.snackbar('Error', _errorMessage.value);
        _logger.error('Failed to update diagnosis',
            error: _errorMessage.value, stackTrace: StackTrace.current);
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error updating diagnosis: $e';
      Get.snackbar('Error', _errorMessage.value);
      _logger.error('Error updating diagnosis',
          error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteDiagnosis(int id) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.info('Deleting diagnosis', context: {'id': id});

    try {
      final response = await NursingDiagnosisService.deleteDiagnosis(id);

      if (response.statusCode == 200) {
        await fetchDiagnoses(); // Refresh the list
        Get.snackbar('Success', 'Diagnosis deleted successfully');
        _logger.info('Diagnosis deleted successfully', context: {'id': id});
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value =
            errorData['message'] ?? 'Failed to delete diagnosis';
        Get.snackbar('Error', _errorMessage.value);
        _logger.error('Failed to delete diagnosis',
            error: _errorMessage.value, stackTrace: StackTrace.current);
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error deleting diagnosis: $e';
      Get.snackbar('Error', _errorMessage.value);
      _logger.error('Error deleting diagnosis',
          error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
  }
}