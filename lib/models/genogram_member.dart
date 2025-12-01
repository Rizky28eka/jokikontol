import 'package:uuid/uuid.dart';

enum Gender { male, female, other }
enum LifeStatus { alive, deceased, unknown }
enum RelType { parentChild, marriage, sibling, other }

class GenogramMember {
  final String id;
  final String name;
  final int age;
  final Gender gender;
  final LifeStatus status;
  final bool isClient;

  GenogramMember({
    String? id,
    required this.name,
    required this.age,
    required this.gender,
    this.status = LifeStatus.alive,
    this.isClient = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender.name,
    'status': status.name,
    'isClient': isClient,
  };

  factory GenogramMember.fromJson(Map<String, dynamic> json) => GenogramMember(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    gender: Gender.values.firstWhere((e) => e.name == json['gender'], orElse: () => Gender.other),
    status: LifeStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => LifeStatus.alive),
    isClient: json['isClient'] ?? false,
  );

  GenogramMember copyWith({
    String? name,
    int? age,
    Gender? gender,
    LifeStatus? status,
    bool? isClient,
  }) => GenogramMember(
    id: id,
    name: name ?? this.name,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    status: status ?? this.status,
    isClient: isClient ?? this.isClient,
  );
}

class GenogramRelationship {
  final String id;
  final String fromId;
  final String toId;
  final RelType type;

  GenogramRelationship({
    String? id,
    required this.fromId,
    required this.toId,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromId': fromId,
    'toId': toId,
    'type': type.name,
  };

  factory GenogramRelationship.fromJson(Map<String, dynamic> json) => GenogramRelationship(
    id: json['id'],
    fromId: json['fromId'],
    toId: json['toId'],
    type: RelType.values.firstWhere((e) => e.name == json['type'], orElse: () => RelType.other),
  );
}
