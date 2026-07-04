class MomentModel {
  final String id;

  /// Famille propriétaire.
  final String familyId;

  /// Nom affiché.
  final String name;

  /// Type du moment.
  /// Exemples : routine, meal, school, leisure...
  final String type;

  /// Clé de l'illustration.
  /// Exemples : routineMorning, breakfast, videoGames...
  final String iconKey;

  /// Clé de la couleur.
  /// Exemples : momentMorning, momentMeal...
  final String colorKey;

  /// Position dans la journée.
  final int position;

  /// Ce moment ouvre une routine.
  final bool hasRoutine;

  /// Routine associée.
  final String? routineId;

  final bool active;

  final DateTime createdAt;

  const MomentModel({
    required this.id,
    required this.familyId,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorKey,
    required this.position,
    required this.hasRoutine,
    this.routineId,
    required this.active,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'type': type,
      'iconKey': iconKey,
      'colorKey': colorKey,
      'position': position,
      'hasRoutine': hasRoutine,
      'routineId': routineId,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MomentModel.fromMap(Map<String, dynamic> map) {
    return MomentModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      iconKey: map['iconKey'] as String,
      colorKey: map['colorKey'] as String,
      position: map['position'] as int,
      hasRoutine: map['hasRoutine'] as bool,
      routineId: map['routineId'] as String?,
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  MomentModel copyWith({
    String? id,
    String? familyId,
    String? name,
    String? type,
    String? iconKey,
    String? colorKey,
    int? position,
    bool? hasRoutine,
    String? routineId,
    bool? active,
    DateTime? createdAt,
  }) {
    return MomentModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      colorKey: colorKey ?? this.colorKey,
      position: position ?? this.position,
      hasRoutine: hasRoutine ?? this.hasRoutine,
      routineId: routineId ?? this.routineId,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
