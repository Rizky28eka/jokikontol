enum UserRole {
  mahasiswa,
  dosen,
  unknown;

  static UserRole fromString(String? value) {
    switch (value) {
      case 'mahasiswa':
        return UserRole.mahasiswa;
      case 'dosen':
        return UserRole.dosen;
      default:
        return UserRole.unknown;
    }
  }

  String get label {
    switch (this) {
      case UserRole.mahasiswa:
        return 'Mahasiswa';
      case UserRole.dosen:
        return 'Dosen';
      case UserRole.unknown:
        return 'Tidak Dikenal';
    }
  }
}
