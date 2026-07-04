import 'user_role.dart';

class ParentModel {
  final String uid;
  final String familyId;
  final String firstName;
  final String email;
  final String avatar;
  final DateTime createdAt;

  /// Toujours "parent" pour ce modèle.
  final UserRole role;

  const ParentModel({
    required this.uid,
    required this.familyId,
    required this.firstName,
    required this.email,
    required this.avatar,
    required this.createdAt,
    this.role = UserRole.parent,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'familyId': familyId,
      'firstName': firstName,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'role': role.name,
    };
  }

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      uid: map['uid'] as String,
      familyId: map['familyId'] as String,
      firstName: map['firstName'] as String,
      email: map['email'] as String,
      avatar: map['avatar'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.parent,
      ),
    );
  }
}
