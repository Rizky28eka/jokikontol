import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../services/nursing_data_global_service.dart';

class FormBinding implements Bindings {
  @override
  void dependencies() {
    // Check if FormController is already registered to avoid duplication
    if (!Get.isRegistered<FormController>()) {
      Get.lazyPut<FormController>(() => FormController());
    }

    // Check if PatientController is already registered to avoid duplication
    if (!Get.isRegistered<PatientController>()) {
      Get.lazyPut<PatientController>(() => PatientController());
    }

    // Check if NursingDataGlobalService is already registered to avoid duplication
    if (!Get.isRegistered<NursingDataGlobalService>()) {
      Get.lazyPut<NursingDataGlobalService>(() => NursingDataGlobalService());
    }
  }
}