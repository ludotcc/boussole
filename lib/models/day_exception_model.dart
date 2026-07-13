const _unset = Object();

class DayExceptionModel {
  final String id;
  final String familyId;
  final String? childId;

  /// Jour concerné au format yyyy-MM-dd.
  final String dateKey;

  /// Planning familial utilisé comme base.
  /// Stocké en `dayTypeId` pour compatibilité avec les données existantes.
  final String dayTypeId;

  String get familyPlanningId => dayTypeId;

  /// Liste des moments spécifiques à cette date.
  final List<String> momentIds;

  final bool active;

  final DateTime createdAt;

  final DateTime updatedAt;

  const DayExceptionModel({
    required this.id,
    required this.familyId,
    this.childId,
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
      'childId': childId,
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
      childId: map['childId'] as String?,
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
    Object? childId = _unset,
    String? dateKey,
    String? dayTypeId,
    String? familyPlanningId,
    List<String>? momentIds,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DayExceptionModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      childId: childId == _unset ? this.childId : childId as String?,
      dateKey: dateKey ?? this.dateKey,
      dayTypeId: familyPlanningId ?? dayTypeId ?? this.dayTypeId,
      momentIds: momentIds ?? this.momentIds,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
