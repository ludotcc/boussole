class ChildModel {
  final String id;
  final String familyId;
  final String firstName;
  final String avatar;
  final int age;
  final DateTime createdAt;

  const ChildModel({
    required this.id,
    required this.familyId,
    required this.firstName,
    required this.avatar,
    required this.age,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'firstName': firstName,
      'avatar': avatar,
      'age': age,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      firstName: map['firstName'] as String,
      avatar: map['avatar'] as String,
      age: map['age'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
