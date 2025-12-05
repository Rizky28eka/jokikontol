import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../services/logger_service.dart';
import 'form_data_mapper.dart';

/// Mixin to eliminate duplication in form views using flutter_form_builder
mixin FormBuilderMixin<T extends StatefulWidget> on State<T> {
  final LoggerService _logger = LoggerService();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final Uuid _uuid = const Uuid();
  
  // Abstract properties that must be implemented by using class
  FormController get formController;
  PatientController get patientController;
  String get formType; // 'pengkajian', 'sap', etc.
  int? get formId; // null for new form, int for editing
  Patient? get currentPatient;
  int? get currentPatientId;
  
  // Initial values for the form
  Map<String, dynamic> initialValues = {};

  /// Helper to generate unique IDs for dynamic form lists
  String generateUuid() => _uuid.v4();

  /// Optional: Override to customize success message
  String get formSubmittedMessage => 'Form berhasil disubmit';
  
  /// Optional: Override to transform form data before saving/submitting
  Map<String, dynamic> transformFormData(Map<String, dynamic> formData) {
    // Convert DateTime objects to ISO8601 strings for JSON serialization
    return _convertDateTimeToString(formData) as Map<String, dynamic>;
  }

  /// Recursively convert DateTime objects to ISO8601 strings
  dynamic _convertDateTimeToString(dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String();
    } else if (value is Map) {
      return Map<String, dynamic>.from(
        value.map((key, val) => MapEntry(key.toString(), _convertDateTimeToString(val)))
      );
    } else if (value is List) {
      return value.map((item) => _convertDateTimeToString(item)).toList();
    }
    return value;
  }

  /// Optional: Override to transform initial data before patching to form
  Map<String, dynamic> transformInitialData(Map<String, dynamic> data) => data;
  
  /// Initialize form - call in initState
  Future<void> initializeForm({
    Patient? patient,
    int? patientId,
    int? formId,
  }) async {
    if (formId != null) {
      await loadFormData(formId);
    }
  }
  
  /// Load existing form data
  Future<void> loadFormData(int formId) async {
    final form = await formController.getFormById(formId);
    if (form != null && form.data != null && mounted) {
      // Apply reverse mapping to convert API flat structure back to form's nested structure
      final reversedData = FormDataMapper.mapFromApiFormat(
        form.type,
        Map<String, dynamic>.from(form.data!),
      );
      
      setState(() {
        initialValues = transformInitialData(reversedData);
      });
      // Schedule patchValue after the widget rebuilds with new initialValues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && formKey.currentState != null) {
          formKey.currentState!.patchValue(initialValues);
        }
      });
    }
  }
  
  /// Merges current form state into initialValues to persist data across sections
  void updateFormData() {
    if (formKey.currentState != null) {
      formKey.currentState!.save();
      final currentData = formKey.currentState!.value;
      initialValues.addAll(currentData);
    }
  }
  
  /// Submit form to server
  Future<void> submitForm() async {
    final effectivePatientId = currentPatientId ?? currentPatient?.id;
    if (effectivePatientId == null) {
      Get.snackbar('Error', 'Patient information is required');
      return;
    }

    // Check if form state is available
    if (formKey.currentState == null) {
      _logger.warning('FormBuilder state is null, cannot submit');
      Get.snackbar('Error', 'Form belum siap, coba lagi');
      return;
    }

    // Validate before submit
    if (!formKey.currentState!.saveAndValidate()) {
      Get.snackbar('Validasi Gagal', 'Mohon lengkapi semua field yang diperlukan');
      _logger.warning('Form validation failed');
      return;
    }

    updateFormData();
    final formData = transformFormData(Map<String, dynamic>.from(initialValues));

    try {
      _logger.info('Submitting form', context: {
        'formType': formType,
        'patientId': effectivePatientId,
        'hasState': true,
        'dataKeys': formData.keys.toList(),
      });
      
      final result = formId != null
          ? await formController.updateForm(
              id: formId!,
              data: formData,
              status: 'submitted',
            )
          : await formController.createForm(
              type: formType,
              patientId: effectivePatientId,
              data: formData,
              status: 'submitted',
            );

      if (mounted && result != null) {
        // Navigate back immediately without waiting
        Get.back(result: true);
        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isSnackbarOpen != true) {
            Get.snackbar(
              'Sukses',
              formSubmittedMessage,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        });
      }
    } catch (e) {
      _logger.error('Error submitting form', error: e);
      if (mounted) {
        Get.snackbar(
          'Error',
          'Gagal submit form: $e',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }
  
  /// Build action buttons (Submit only)
  Widget buildActionButtons({
    VoidCallback? onSubmit,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : (onSubmit ?? submitForm),
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.send_rounded),
          label: Text(isLoading ? 'Mengirim...' : 'Submit Form'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
