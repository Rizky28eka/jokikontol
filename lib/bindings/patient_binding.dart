import 'package:get/get.dart';
import '../controllers/patient_controller.dart';

class PatientBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientController());
  }
}