import 'dart:convert';

import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';

class PatientController extends GetxController {
  final LoggerService _logger = LoggerService();
  final RxList<Patient> _patients = <Patient>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<Patient> get patients => _patients;
  RxBool get isLoading => _isLoading;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.patient(operation: 'fetch');

    try {
      final response = await ApiService.get('patients');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> patientList = data['data'] as List<dynamic>;

        _patients.value = patientList
            .map((json) => Patient.fromJson(json as Map<String, dynamic>))
            .toList();
        _logger.info(
          'Successfully fetched patients',
          context: {'count': patientList.length},
        );
      } else {
        _errorMessage.value = 'Failed to fetch patients';
        _logger.error(
          'Failed to fetch patients',
          error: response.body,
          stackTrace: StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error fetching patients: $e';
      _logger.error(
        'Error fetching patients',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Patient?> createPatient({
    required String name,
    required String gender,
    required int age,
    required String address,
    required String rmNumber,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.patient(
      operation: 'create',
      patientName: name,
      metadata: {'gender': gender, 'age': age, 'rmNumber': rmNumber},
    );

    try {
      final response = await ApiService.post(
        'patients',
        body: {
          'name': name,
          'gender': gender,
          'age': age,
          'address': address,
          'rm_number': rmNumber,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // Expecting the API to return the created patient
        final patientJson = data['data'] ?? data['patient'] ?? data;
        final createdPatient = Patient.fromJson(patientJson as Map<String, dynamic>);
        await fetchPatients(); // Refresh the list
        _logger.info('Patient created successfully', context: {'name': name, 'patientId': createdPatient.id});
        return createdPatient;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value =
            errorData['message'] ?? 'Failed to create patient';
        _logger.error(
          'Failed to create patient',
          error: _errorMessage.value,
          stackTrace: StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error creating patient: $e';
      _logger.error('Error creating patient', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
    return null;
  }

  Future<Patient?> updatePatient({
    required int id,
    required String name,
    required String gender,
    required int age,
    required String address,
    required String rmNumber,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.patient(
      operation: 'update',
      patientId: id.toString(),
      patientName: name,
      metadata: {'gender': gender, 'age': age, 'rmNumber': rmNumber},
    );

    try {
      final response = await ApiService.put(
        'patients/$id',
        body: {
          'name': name,
          'gender': gender,
          'age': age,
          'address': address,
          'rm_number': rmNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final patientJson = data['data'] ?? data['patient'] ?? data;
        final updatedPatient = Patient.fromJson(patientJson as Map<String, dynamic>);
        await fetchPatients(); // Refresh the list
        _logger.info(
          'Patient updated successfully',
          context: {'patientId': id},
        );
        return updatedPatient;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value =
            errorData['message'] ?? 'Failed to update patient';
        _logger.error(
          'Failed to update patient',
          error: _errorMessage.value,
          stackTrace: StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error updating patient: $e';
      _logger.error('Error updating patient', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
    return null;
  }

  Future<void> deletePatient(int id) async {
    _logger.patient(operation: 'delete', patientId: id.toString());
    try {
      final response = await ApiService.delete('patients/$id');

      if (response.statusCode == 200) {
        _patients.removeWhere((patient) => patient.id == id);
        _logger.info(
          'Patient deleted successfully',
          context: {'patientId': id},
        );
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value =
            errorData['message'] ?? 'Failed to delete patient';
        _logger.error(
          'Failed to delete patient',
          error: _errorMessage.value,
          stackTrace: StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error deleting patient: $e';
      _logger.error('Error deleting patient', error: e, stackTrace: stackTrace);
    }
  }

  Future<Patient?> getPatientById(int id) async {
    _logger.patient(operation: 'get by id', patientId: id.toString());
    try {
      final response = await ApiService.get('patients/$id');

      if (response.statusCode == 200) {
        final patientData = json.decode(response.body);
        _logger.info(
          'Successfully fetched patient by id',
          context: {'patientId': id},
        );
        return Patient.fromJson(patientData);
      } else {
        _logger.warning('Could not find patient with id $id');
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error fetching patient: $e';
      _logger.error(
        'Error fetching patient by id',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return null;
  }
}
