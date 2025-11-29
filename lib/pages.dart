import 'package:get/get.dart';
import 'package:tamajiwa/bindings/form_selection_binding.dart';
import 'package:tamajiwa/views/form_selection_view.dart';
import 'constants/app_routes.dart';
import 'bindings/splash_binding.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/register_page.dart';
import 'views/profile_view.dart';
import 'views/dosen_dashboard_view.dart';
import 'views/mahasiswa_dashboard_view.dart';
import 'views/patient_form_view.dart';
import 'views/mental_health_assessment_form_view.dart';
import 'views/resume_kegawatdaruratan_form_view.dart';
import 'views/resume_poliklinik_form_view.dart';
import 'views/sap_form_view.dart';
import 'views/catatan_tambahan_form_view.dart';
import 'views/nursing_management_view.dart';
import 'views/dosen_review_dashboard_view.dart';
import 'views/form_review_view.dart';
import 'views/dosen_dashboard_view_with_stats.dart';
import 'views/genogram_builder_view.dart';
import 'bindings/auth_binding.dart';
import 'bindings/patient_binding.dart';
import 'bindings/form_binding.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dosenDashboard,
      page: () => DosenDashboardView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.mahasiswaDashboard,
      page: () => MahasiswaDashboardView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/patient-form',
      page: () => PatientFormView(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: '/form-selection',
      page: () => FormSelectionView(),
      binding: FormSelectionBinding(),
    ),
    GetPage(
      name: '/mental-health-assessment-form',
      page: () => MentalHealthAssessmentFormView(),
      binding: FormBinding(),
    ),
    GetPage(
      name: '/genogram-builder',
      page: () => GenogramBuilderView(),
      binding: null, // No binding needed for this simple view
    ),
    GetPage(
      name: '/resume-kegawatdaruratan-form',
      page: () => ResumeKegawatdaruratanFormView(),
      binding: FormBinding(),
    ),
    GetPage(
      name: '/resume-poliklinik-form',
      page: () => ResumePoliklinikFormView(),
      binding: FormBinding(),
    ),
    GetPage(
      name: '/sap-form',
      page: () => SapFormView(),
      binding: FormBinding(),
    ),
    GetPage(
      name: '/catatan-tambahan-form',
      page: () => CatatanTambahanFormView(),
      binding: FormBinding(),
    ),
    GetPage(
      name: '/nursing-management',
      page: () => NursingManagementView(),
      binding: null, // No specific binding needed
    ),
    GetPage(
      name: '/dosen-review-dashboard',
      page: () => DosenReviewDashboardView(),
      binding: null, // No specific binding needed
    ),
    GetPage(
      name: '/form-review/:formId',
      page: () => FormReviewView(),
      binding: null, // No specific binding needed
    ),
    GetPage(
      name: '/mahasiswa-dashboard-stats',
      page: () => MahasiswaDashboardView(),
      binding: null, // No specific binding needed
    ),
    GetPage(
      name: '/dosen-dashboard-stats',
      page: () => DosenDashboardViewWithStats(),
      binding: null, // No specific binding needed
    ),
  ];
}