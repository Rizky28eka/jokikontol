class NursingIntervention {
  final int id;
  final String name;
  final String? description;
  final int createdById;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  NursingIntervention({
    required this.id,
    required this.name,
    this.description,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NursingIntervention.fromJson(Map<String, dynamic> json) {
    return NursingIntervention(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdById: json['created_by']['id'],
      createdByName: json['created_by']['name'] ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by_id': createdById,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}