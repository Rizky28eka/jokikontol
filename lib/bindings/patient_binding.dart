import 'package:get/get.dart';
import '../controllers/patient_controller.dart';
import '../controllers/form_controller.dart';

class PatientBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientController());
    if (!Get.isRegistered<FormController>()) {
      Get.lazyPut<FormController>(() => FormController());
    }
  }
}