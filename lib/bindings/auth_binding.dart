import '../controllers/dashboard_controller.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
  }
}