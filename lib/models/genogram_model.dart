class GenogramModel {
  final int id;
  final int formId;
  final Map<String, dynamic>? structure;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  GenogramModel({
    required this.id,
    required this.formId,
    this.structure,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GenogramModel.fromJson(Map<String, dynamic> json) {
    return GenogramModel(
      id: json['id'],
      formId: json['form_id'],
      structure: json['structure'] != null ? Map<String, dynamic>.from(json['structure']) : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'form_id': formId,
      'structure': structure,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GenogramModel copyWith({
    int? id,
    int? formId,
    Map<String, dynamic>? structure,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GenogramModel(
      id: id ?? this.id,
      formId: formId ?? this.formId,
      structure: structure ?? this.structure,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}