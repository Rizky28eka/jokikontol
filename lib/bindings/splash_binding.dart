import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // AuthController already initialized in main.dart
    Get.put<SplashController>(SplashController());
  }
}
