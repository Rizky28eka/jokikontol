import 'genogram_model.dart';
import 'user_model.dart';
import 'patient_model.dart';

class FormUser {
  final int id;
  final String name;

  FormUser({required this.id, required this.name});

  factory FormUser.fromJson(Map<String, dynamic> json) {
    return FormUser(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class FormPatient {
  final int id;
  final String name;

  FormPatient({required this.id, required this.name});

  factory FormPatient.fromJson(Map<String, dynamic> json) {
    return FormPatient(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class FormModel {
  final int id;
  final String type;
  final int userId;
  final int patientId;
  final String status;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GenogramModel? genogram;
  final UserModel? user;
  final Patient? patient;

  final String? comments;

  FormModel({
    required this.id,
    required this.type,
    required this.userId,
    required this.patientId,
    required this.status,
    this.data,
    required this.createdAt,
    required this.updatedAt,
    this.genogram,
    this.user,
    this.patient,
    this.comments,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'],
      type: json['type'],
      userId: json['user_id'],
      patientId: json['patient_id'],
      status: json['status'],
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      genogram: json['genogram'] != null
          ? GenogramModel.fromJson(json['genogram'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      patient: json['patient'] != null
          ? Patient.fromJson(json['patient'])
          : null,
      comments: json['comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'user_id': userId,
      'patient_id': patientId,
      'status': status,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'genogram': genogram?.toJson(),
      'user': user?.toJson(),
      'patient': patient?.toJson(),
      'comments': comments,
    };
  }

  FormModel copyWith({
    int? id,
    String? type,
    int? userId,
    int? patientId,
    String? status,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    GenogramModel? genogram,
    UserModel? user,
    Patient? patient,
    String? comments,
  }) {
    return FormModel(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      patientId: patientId ?? this.patientId,
      status: status ?? this.status,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      genogram: genogram ?? this.genogram,
      user: user ?? this.user,
      patient: patient ?? this.patient,
      comments: comments ?? this.comments,
    );
  }
}
