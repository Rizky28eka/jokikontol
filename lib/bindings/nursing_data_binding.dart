import 'package:get/get.dart';
import '../services/nursing_data_global_service.dart';

class NursingDataBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NursingDataGlobalService(), permanent: true);
  }
}