class DayExceptionModel {
  final String id;
  final String familyId;

  /// Jour concerné au format yyyy-MM-dd.
  final String dateKey;

  /// Journée type utilisée comme base.
  final String dayTypeId;

  /// Liste des moments spécifiques à cette date.
  final List<String> momentIds;

  final bool active;

  final DateTime createdAt;

  final DateTime updatedAt;

  const DayExceptionModel({
    required this.id,
    required this.familyId,
    required this.dateKey,
    required this.dayTypeId,
    required this.momentIds,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'dateKey': dateKey,
      'dayTypeId': dayTypeId,
      'momentIds': momentIds,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DayExceptionModel.fromMap(Map<String, dynamic> map) {
    return DayExceptionModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      dateKey: map['dateKey'] as String,
      dayTypeId: map['dayTypeId'] as String,
      momentIds: List<String>.from(map['momentIds'] ?? const []),
      active: map['active'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  DayExceptionModel copyWith({
    String? id,
    String? familyId,
    String? dateKey,
    String? dayTypeId,
    List<String>? momentIds,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DayExceptionModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      dateKey: dateKey ?? this.dateKey,
      dayTypeId: dayTypeId ?? this.dayTypeId,
      momentIds: momentIds ?? this.momentIds,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
