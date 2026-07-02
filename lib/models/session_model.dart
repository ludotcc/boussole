class SessionModel {
  final String userId;
  final String familyId;
  final String firstName;
  final String email;
  final String avatar;

  const SessionModel({
    required this.userId,
    required this.familyId,
    required this.firstName,
    required this.email,
    required this.avatar,
  });

  SessionModel copyWith({
    String? userId,
    String? familyId,
    String? firstName,
    String? email,
    String? avatar,
  }) {
    return SessionModel(
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
    );
  }
}
