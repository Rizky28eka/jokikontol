import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/form_model.dart';
import '../models/patient_model.dart';
import '../services/logger_service.dart';
import '../services/hive_service.dart';

class FormSelectionController extends GetxController {
  final FormController _formController = Get.find<FormController>();
  final PatientController _patientController = Get.find<PatientController>();
  final LoggerService _logger = LoggerService();

  final RxList<FormModel> _forms = <FormModel>[].obs;
  final RxMap<String, FormModel?> _localDrafts = <String, FormModel?>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<FormModel> get forms => _forms;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  int get patientId =>
      int.tryParse(Get.arguments?['patientId']?.toString() ?? '0') ?? 0;
  String get patientName =>
      Get.arguments?['patientName']?.toString() ?? 'Unknown Patient';

  @override
  void onInit() {
    super.onInit();
    fetchLocalDrafts();
    fetchForms();
  }

  /// Load local drafts from Hive for the currently selected patient
  Future<void> fetchLocalDrafts() async {
    try {
      final allDrafts = await HiveService.getDraftForms();
      _localDrafts.clear();
      for (var d in allDrafts) {
        if (d.patientId == patientId) {
          _localDrafts[d.type] = d;
        }
      }
    } catch (e) {
      _logger.error('Error fetching local drafts', error: e);
    }
  }

  /// Returns true if the given form type has a local (Hive) draft
  bool isLocalDraft(String formType) {
    return _localDrafts.containsKey(formType) && _localDrafts[formType] != null;
  }

  /// Get the local draft for a given type, if exists
  FormModel? getLocalDraft(String formType) {
    return _localDrafts[formType];
  }

  /// Deletes a local draft for the given form type for the current patient
  Future<void> deleteLocalDraft(String formType) async {
    try {
      if (patientId <= 0) {
        Get.snackbar('Error', 'Patient is not selected');
        return;
      }
      await HiveService.deleteDraftForm(formType, patientId);
      _localDrafts.remove(formType);
      await fetchForms();
      Get.snackbar('Berhasil', 'Draft lokal berhasil dihapus');
    } catch (e) {
      _logger.error('Failed to delete local draft', error: e);
      Get.snackbar('Gagal', 'Gagal menghapus draft lokal');
    }
  }

  Future<void> fetchForms() async {
    _logger.info('Fetching forms for patient: $patientId');
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      await _formController.fetchForms(patientId: patientId);
      _forms.value = _formController.forms;
      // Also fetch local drafts to reflect any hive-saved drafts
      await fetchLocalDrafts();
    } catch (e) {
      _errorMessage.value = e.toString();
      _logger.error('Error fetching forms', error: e);
    } finally {
      _isLoading.value = false;
    }
  }

  bool hasDraft(String formType) {
    final serverDraftFound = _forms.any((f) => f.type == formType && f.status == 'draft');
    final localDraftFound = _localDrafts[formType] != null;
    return serverDraftFound || localDraftFound;
  }

  /// Combined server forms and local drafts (local drafts are added only if there is no matching server draft)
  List<FormModel> get combinedForms {
    final List<FormModel> merged = List<FormModel>.from(_forms);
    for (var entry in _localDrafts.entries) {
      final localDraft = entry.value;
      if (localDraft == null) continue;
      // If server already has a draft for this type skip adding local draft
      final hasServerDraft = _forms.any((f) => f.type == localDraft.type && f.status == 'draft');
      if (!hasServerDraft) merged.add(localDraft);
    }
    // Sort so most recent are at top
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  /// Check whether a particular form item in the list originates from local Hive drafts
  bool isFormLocal(FormModel form) {
    final local = _localDrafts[form.type];
    return local != null && local.id == form.id;
  }

  FormModel? getDraft(String formType) {
    try {
      final server = _forms.firstWhere((f) => f.type == formType && f.status == 'draft');
      return server;
    } catch (e) {
      return _localDrafts[formType];
    }
  }

  Future<void> createForm(String formType) async {
    _logger.form(
      operation: 'Creating new form',
      formType: formType,
      patientId: patientId.toString(),
      metadata: {'patientName': patientName, 'formType': formType},
    );

    try {
      if (patientId <= 0) {
        Get.snackbar('Error', 'Patient is not selected');
        return;
      }
      final patient = await _patientController.getPatientById(patientId);

      // If patient is not found, create a placeholder with minimal required data
      final Patient selectedPatient =
          patient ??
          Patient(
            id: patientId,
            name: patientName,
            gender: 'N/A',
            age: 0,
            address: 'N/A',
            rmNumber: 'N/A',
            createdById: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      final createdForm = await _formController.createForm(
        type: formType,
        patientId: patientId,
        status: 'draft',
      );

      String route = getFormRoute(formType);
      if (route.isNotEmpty) {
        await _formController.fetchForms(patientId: patientId);

        final result = await Get.toNamed(
          route,
          arguments: {
            if (createdForm != null) 'formId': createdForm.id,
            'patient': selectedPatient,
            'patientId': patientId,
            'patientName': patientName,
            'formType': formType,
          },
        );

        // If the pushed route returned a FormModel (draft or saved), update lists
        if (result != null && result is FormModel) {
          // Refresh server forms and local drafts
          await fetchForms();
          await fetchLocalDrafts();
        } else {
          // Always refresh to reflect any potential changes
          await fetchForms();
        }
      } else {
        _logger.warning(
          'Unknown form type selected',
          context: {'formType': formType},
        );
      }
    } catch (e) {
      _logger.error(
        'Failed to create form',
        error: e,
        context: {
          'formType': formType,
          'patientId': patientId,
          'patientName': patientName,
        },
      );
      Get.snackbar('Error', 'Gagal membuat form: ${e.toString()}');
    }
  }

  Future<void> openExistingForm(FormModel form) async {
    String route = getFormRoute(form.type);
    if (route.isNotEmpty) {
      final patient = await _patientController.getPatientById(patientId);
      final Patient selectedPatient =
          patient ??
          Patient(
            id: patientId,
            name: patientName,
            gender: 'N/A',
            age: 0,
            address: 'N/A',
            rmNumber: 'N/A',
            createdById: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
      
      final fullForm = await _formController.getFormById(form.id);
      Map<String, dynamic>? formData = fullForm?.data;
      // If the server doesn't have the form (local draft), try Hive for draft data
      if (formData == null) {
        try {
          final local = await HiveService.getDraftForm(form.type, patientId);
          formData = local?.data;
        } catch (e) {
          // ignore errors
        }
      }
      final result = await Get.toNamed(
        route,
        arguments: {
          'formId': fullForm?.id,
          'patient': selectedPatient,
          'patientId': patientId,
          'patientName': patientName,
          'formType': form.type,
          'formData': formData,
        },
      );

      // If a form was returned (saved or draft), refresh lists
      if (result != null && result is FormModel) {
        await fetchForms();
        await fetchLocalDrafts();
      } else {
        await fetchForms();
      }
    } else {
      _logger.warning(
        'Unknown form type for existing form',
        context: {'formType': form.type, 'formId': form.id},
      );
      Get.snackbar('Error', 'Tipe form tidak dikenali');
    }
  }

  Future<void> deleteForm(FormModel form) async {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    
    _logger.form(
      operation: 'Deleting form',
      formType: form.type,
      formId: form.id.toString(),
      metadata: {'status': form.status, 'patientId': patientId.toString()},
    );

    try {
      final success = await _formController.deleteForm(form.id);

      if (success) {
        _forms.removeWhere((f) => f.id == form.id);
        try {
          await HiveService.deleteDraftForm(form.type, patientId);
          _localDrafts.remove(form.type);
        } catch (e) {
          // ignore errors
        }
        
        _logger.form(
          operation: 'Form deleted successfully',
          formType: form.type,
          formId: form.id.toString(),
        );

        Get.snackbar(
          'Berhasil',
          'Form berhasil dihapus',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(milliseconds: 800),
        );
      } else {
        _logger.error(
          'Failed to delete form',
          context: {'formId': form.id.toString(), 'formType': form.type},
        );

        Get.snackbar(
          'Gagal',
          'Gagal menghapus form',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      _logger.error(
        'Error deleting form',
        error: e,
        stackTrace: StackTrace.current,
        context: {'formId': form.id.toString(), 'formType': form.type},
      );

      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menghapus form: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  String getFormRoute(String formType) {
    switch (formType) {
      case 'pengkajian':
        return '/mental-health-assessment-form';
      case 'resume_kegawatdaruratan':
        return '/resume-kegawatdaruratan-form';
      case 'resume_poliklinik':
        return '/resume-poliklinik-form';
      case 'sap':
        return '/sap-form';
      case 'catatan_tambahan':
        return '/catatan-tambahan-form';
      default:
        return '';
    }
  }

  String getFormTitle(String type) {
    switch (type) {
      case 'pengkajian':
        return 'Pengkajian Kesehatan Jiwa';
      case 'resume_kegawatdaruratan':
        return 'Resume Kegawatdaruratan Psikiatri';
      case 'resume_poliklinik':
        return 'Resume Poliklinik';
      case 'sap':
        return 'SAP (Satuan Acara Penyuluhan)';
      case 'catatan_tambahan':
        return 'Catatan Tambahan';
      default:
        return type;
    }
  }
}
