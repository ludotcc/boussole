class StepModel {
  final String id;

  final String routineId;

  final String title;

  final String description;

  final String icon;

  final int order;

  final bool active;

  final DateTime createdAt;

  const StepModel({
    required this.id,
    required this.routineId,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
    required this.active,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineId': routineId,
      'title': title,
      'description': description,
      'icon': icon,
      'order': order,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StepModel.fromMap(Map<String, dynamic> map) {
    return StepModel(
      id: map['id'] as String,
      routineId: map['routineId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      order: map['order'] as int,
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  StepModel copyWith({
    String? id,
    String? routineId,
    String? title,
    String? description,
    String? icon,
    int? order,
    bool? active,
    DateTime? createdAt,
  }) {
    return StepModel(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
