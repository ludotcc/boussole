class DayTypeModel {
  final String id;
  final String familyId;

  /// Nom affiché au parent.
  final String name;

  /// week / weekend / holidays / custom
  final String type;

  /// Ordre d'affichage.
  final int order;

  /// Liste des moments composant cette journée.
  final List<String> momentIds;

  final bool active;

  const DayTypeModel({
    required this.id,
    required this.familyId,
    required this.name,
    required this.type,
    required this.order,
    required this.momentIds,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'type': type,
      'order': order,
      'momentIds': momentIds,
      'active': active,
    };
  }

  factory DayTypeModel.fromMap(Map<String, dynamic> map) {
    return DayTypeModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      order: map['order'] as int,
      momentIds: List<String>.from(map['momentIds'] ?? const []),
      active: map['active'] as bool,
    );
  }

  DayTypeModel copyWith({
    String? id,
    String? familyId,
    String? name,
    String? type,
    int? order,
    List<String>? momentIds,
    bool? active,
  }) {
    return DayTypeModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      type: type ?? this.type,
      order: order ?? this.order,
      momentIds: momentIds ?? this.momentIds,
      active: active ?? this.active,
    );
  }
}
