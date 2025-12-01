import '../controllers/auth_controller.dart';
import '../models/user_role.dart';

class RoleGuard {
  static UserRole currentRole() {
    final roleString = AuthController.to.user?.role;
    return UserRole.fromString(roleString);
  }

  static bool isMahasiswa() => currentRole() == UserRole.mahasiswa;
  static bool isDosen() => currentRole() == UserRole.dosen;

  // Capabilities - expand later for fine-grained permissions
  static bool canReviewForms() => isDosen();
  static bool canManageNursingData() => isDosen();
  static bool canCreateForms() => isMahasiswa() || isDosen();
  static bool canEditOwnForm(String formOwnerId) {
    final userId = AuthController.to.user?.id.toString();
    return userId != null && userId == formOwnerId;
  }
}
