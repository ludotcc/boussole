import 'user_role.dart';

class SessionModel {
  final String userId;
  final String familyId;
  final String firstName;
  final String email;
  final String avatar;

  /// Parent ou enfant connecté.
  final UserRole role;

  const SessionModel({
    required this.userId,
    required this.familyId,
    required this.firstName,
    required this.email,
    required this.avatar,
    required this.role,
  });

  SessionModel copyWith({
    String? userId,
    String? familyId,
    String? firstName,
    String? email,
    String? avatar,
    UserRole? role,
  }) {
    return SessionModel(
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
    );
  }
}
