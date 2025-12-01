import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/form_model.dart';
import '../models/patient_model.dart';
import '../services/logger_service.dart';

class FormSelectionController extends GetxController {
  final FormController _formController = Get.find<FormController>();
  final PatientController _patientController = Get.find<PatientController>();
  final LoggerService _logger = LoggerService();

  final RxList<FormModel> _forms = <FormModel>[].obs;
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
    fetchForms();
  }



  Future<void> fetchForms() async {
    _logger.info('Fetching forms for patient: $patientId');
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      await _formController.fetchForms(patientId: patientId);
      _forms.value = _formController.forms;
    } catch (e) {
      _errorMessage.value = e.toString();
      _logger.error('Error fetching forms', error: e);
    } finally {
      _isLoading.value = false;
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

      String route = getFormRoute(formType);
      if (route.isNotEmpty) {
        await Get.toNamed(
          route,
          arguments: {
            'patient': selectedPatient,
            'patientId': patientId,
            'patientName': patientName,
            'formType': formType,
          },
        );

        // Always refresh to reflect any potential changes
        await fetchForms();
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
      await Get.toNamed(
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

      // Refresh forms after editing
      await fetchForms();
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
