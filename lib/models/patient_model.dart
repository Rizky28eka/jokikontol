class Patient {
  final int id;
  final String name;
  final String gender;
  final int age;
  final String address;
  final String rmNumber;
  final int createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.address,
    required this.rmNumber,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      address: json['address'],
      rmNumber: json['rm_number'],
      createdById: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'address': address,
      'rm_number': rmNumber,
      'created_by': createdById,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated values
  Patient copyWith({
    int? id,
    String? name,
    String? gender,
    int? age,
    String? address,
    String? rmNumber,
    int? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      address: address ?? this.address,
      rmNumber: rmNumber ?? this.rmNumber,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}