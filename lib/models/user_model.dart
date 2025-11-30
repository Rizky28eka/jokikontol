class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? username;
  final String? phoneNumber;
  final String? profilePhoto;
  final DateTime? usernameChangedAt;
  final DateTime? phoneChangedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.username,
    this.phoneNumber,
    this.profilePhoto,
    this.usernameChangedAt,
    this.phoneChangedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      profilePhoto: json['profile_photo'],
      usernameChangedAt: json['username_changed_at'] != null ? DateTime.parse(json['username_changed_at']) : null,
      phoneChangedAt: json['phone_changed_at'] != null ? DateTime.parse(json['phone_changed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'username': username,
      'phone_number': phoneNumber,
      'profile_photo': profilePhoto,
      'username_changed_at': usernameChangedAt?.toIso8601String(),
      'phone_changed_at': phoneChangedAt?.toIso8601String(),
    };
  }
}