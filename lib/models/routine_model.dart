class RoutineModel {
  final String id;

  /// Nom affiché.
  final String name;

  /// Illustration.
  final String icon;

  final String momentId;

  final int order;

  final bool active;

  final DateTime createdAt;

  const RoutineModel({
    required this.id,
    required this.name,
    required this.icon,
    this.momentId = '',
    this.order = 0,
    required this.active,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'momentId': momentId,
      'order': order,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RoutineModel.fromMap(Map<String, dynamic> map) {
    return RoutineModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      momentId: map['momentId'] as String? ?? '',
      order: map['order'] as int? ?? 0,
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  RoutineModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? momentId,
    int? order,
    bool? active,
    DateTime? createdAt,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      momentId: momentId ?? this.momentId,
      order: order ?? this.order,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
