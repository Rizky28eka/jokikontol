import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../models/form_model.dart';
import '../services/hive_service.dart';
import '../services/logger_service.dart';

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
  String get draftSavedMessage => 'Draft berhasil disimpan';
  String get formSubmittedMessage => 'Form berhasil disubmit';
  
  /// Optional: Override to transform form data before saving/submitting
  Map<String, dynamic> transformFormData(Map<String, dynamic> formData) => formData;

  /// Optional: Override to transform initial data before patching to form
  Map<String, dynamic> transformInitialData(Map<String, dynamic> data) => data;
  
  /// Initialize form - call in initState
  Future<void> initializeForm({
    Patient? patient,
    int? patientId,
    int? formId,
  }) async {
    await HiveService.init();
    
    if (formId != null) {
      await loadFormData(formId);
    } else {
      await checkForDrafts(patient, patientId);
    }
  }
  
  /// Check if draft exists and prompt user
  Future<void> checkForDrafts(Patient? patient, int? patientId) async {
    final effectivePatientId = patientId ?? patient?.id;
    if (effectivePatientId == null) return;

    final draft = await HiveService.getDraftForm(formType, effectivePatientId);
    if (draft != null && mounted) {
      Get.defaultDialog(
        title: 'Draft Ditemukan',
        middleText: 'Apakah Anda ingin melanjutkan pengisian form dari draft yang tersimpan?',
        textConfirm: 'Ya',
        textCancel: 'Tidak',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          if (mounted && draft.data != null) {
            setState(() {
              initialValues = transformInitialData(Map<String, dynamic>.from(draft.data!));
              formKey.currentState?.patchValue(initialValues);
            });
          }
        },
        onCancel: () {
          // User declined, optionally delete draft
          HiveService.deleteDraftForm(formType, effectivePatientId);
        },
      );
    }
  }
  
  /// Load existing form data
  Future<void> loadFormData(int formId) async {
    final form = await formController.getFormById(formId);
    if (form != null && form.data != null && mounted) {
      setState(() {
        initialValues = transformInitialData(Map<String, dynamic>.from(form.data!));
        formKey.currentState?.patchValue(initialValues);
      });
    }
  }
  
  /// Save form as draft (local + server if formId exists)
  Future<void> saveDraft() async {
    final effectivePatientId = currentPatientId ?? currentPatient?.id;
    if (effectivePatientId == null) {
      Get.snackbar('Error', 'Patient information is required');
      return;
    }

    // Save current state to get values
    formKey.currentState?.save();
    final rawData = formKey.currentState?.value ?? {};
    final formData = transformFormData(Map<String, dynamic>.from(rawData));

    try {
      _logger.info('Saving draft', context: {'formType': formType, 'patientId': effectivePatientId});
      
      // Create FormModel for Hive
      final form = FormModel(
        id: formId ?? DateTime.now().millisecondsSinceEpoch,
        type: formType,
        userId: 0,
        patientId: effectivePatientId,
        status: 'draft',
        data: formData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        genogram: null,
      );
      
      // Save to Hive
      await HiveService.saveDraftForm(form);

      // If editing existing form, also update on server
      if (formId != null) {
        await formController.updateForm(
          id: formId!,
          data: formData,
          status: 'draft',
        );
      }

      if (mounted) {
        Get.snackbar(
          'Sukses',
          draftSavedMessage,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.error('Error saving draft', error: e);
      if (mounted) {
        Get.snackbar('Error', 'Gagal menyimpan draft: $e');
      }
    }
  }
  
  /// Submit form to server
  Future<void> submitForm() async {
    final effectivePatientId = currentPatientId ?? currentPatient?.id;
    if (effectivePatientId == null) {
      Get.snackbar('Error', 'Patient information is required');
      return;
    }

    // Validate before submit
    if (formKey.currentState?.saveAndValidate() != true) {
      Get.snackbar('Validasi Gagal', 'Mohon lengkapi semua field yang diperlukan');
      return;
    }

    final rawData = formKey.currentState?.value ?? {};
    final formData = transformFormData(Map<String, dynamic>.from(rawData));

    try {
      _logger.info('Submitting form', context: {'formType': formType, 'patientId': effectivePatientId});
      
      FormModel? resultForm;
      
      if (formId != null) {
        // Update existing form
        resultForm = await formController.updateForm(
          id: formId!,
          data: formData,
          status: 'submitted',
        );
      } else {
        // Create new form
        resultForm = await formController.createForm(
          type: formType,
          patientId: effectivePatientId,
          data: formData,
          status: 'submitted',
        );
      }

      if (resultForm != null && mounted) {
        // Delete local draft after successful submission
        await HiveService.deleteDraftForm(formType, effectivePatientId);
        
        Get.snackbar(
          'Sukses',
          formSubmittedMessage,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate back after short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Get.back();
        });
      }
    } catch (e) {
      _logger.error('Error submitting form', error: e);
      if (mounted) {
        // Save as local draft on failure
        final form = FormModel(
          id: formId ?? DateTime.now().millisecondsSinceEpoch,
          type: formType,
          userId: 0,
          patientId: effectivePatientId,
          status: 'draft',
          data: formData,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          genogram: null,
        );
        await HiveService.saveDraftForm(form);
        Get.snackbar(
          'Error',
          'Gagal submit form. Draft telah disimpan secara lokal.',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }
  
  /// Build action buttons (Draft + Submit)
  Widget buildActionButtons({
    VoidCallback? onSaveDraft,
    VoidCallback? onSubmit,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : (onSaveDraft ?? saveDraft),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan Draft'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
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
            ),
          ),
        ],
      ),
    );
  }
}
