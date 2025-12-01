import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/auth_controller.dart';

class MainShellBinding implements Bindings {
  @override
  void dependencies() {
    // Ensure AuthController is available (already permanent from main.dart)
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    
    // Put DashboardController as permanent to maintain state
    if (!Get.isRegistered<DashboardController>()) {
      Get.put<DashboardController>(DashboardController(), permanent: true);
    }
  }
}
