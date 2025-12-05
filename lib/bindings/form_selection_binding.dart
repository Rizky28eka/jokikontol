import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/form_selection_controller.dart';
import '../controllers/patient_controller.dart';

class FormSelectionBinding implements Bindings {
  @override
  void dependencies() {
    // Always create new FormSelectionController for fresh data
    Get.lazyPut<FormSelectionController>(() => FormSelectionController(), fenix: true);
    
    // Check if FormController is already registered to avoid duplication
    if (!Get.isRegistered<FormController>()) {
      Get.lazyPut<FormController>(() => FormController());
    }

    // Check if PatientController is already registered to avoid duplication
    if (!Get.isRegistered<PatientController>()) {
      Get.lazyPut<PatientController>(() => PatientController());
    }
  }
}