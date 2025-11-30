import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages.dart';
import 'constants/app_routes.dart';
import 'theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logger
  LoggerService().init();
  LoggerService().appStartup(environment: 'development');

  // Initialize AuthController permanently
  final authController = AuthController();
  await authController.initAuth();
  Get.put(authController, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tamajiwa',
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
