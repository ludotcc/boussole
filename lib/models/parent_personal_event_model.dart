const _unset = Object();

class ParentPersonalEventModel {
  final String id;
  final String familyId;
  final String parentId;
  final String title;
  final String? description;
  final String type;
  final DateTime date;
  final String? time;
  final bool isAllDay;
  final String recurrenceType;
  final bool shareWithFamily;
  final String? familyEventId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ParentPersonalEventModel({
    required this.id,
    required this.familyId,
    required this.parentId,
    required this.title,
    this.description,
    this.type = 'personnel',
    required this.date,
    this.time,
    required this.isAllDay,
    this.recurrenceType = 'none',
    this.shareWithFamily = false,
    this.familyEventId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'parentId': parentId,
      'title': title,
      'description': description,
      'type': type,
      'date': date.toIso8601String(),
      'time': time,
      'isAllDay': isAllDay,
      'recurrenceType': recurrenceType,
      'shareWithFamily': shareWithFamily,
      'familyEventId': familyEventId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ParentPersonalEventModel.fromMap(Map<String, dynamic> map) {
    return ParentPersonalEventModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      parentId: map['parentId'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      type: map['type'] as String? ?? 'personnel',
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String?,
      isAllDay: map['isAllDay'] as bool? ?? false,
      recurrenceType: map['recurrenceType'] as String? ?? 'none',
      shareWithFamily: map['shareWithFamily'] as bool? ?? false,
      familyEventId: map['familyEventId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  ParentPersonalEventModel copyWith({
    String? id,
    String? familyId,
    String? parentId,
    String? title,
    Object? description = _unset,
    String? type,
    DateTime? date,
    Object? time = _unset,
    bool? isAllDay,
    String? recurrenceType,
    bool? shareWithFamily,
    Object? familyEventId = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParentPersonalEventModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      description: description == _unset
          ? this.description
          : description as String?,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time == _unset ? this.time : time as String?,
      isAllDay: isAllDay ?? this.isAllDay,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      shareWithFamily: shareWithFamily ?? this.shareWithFamily,
      familyEventId: familyEventId == _unset
          ? this.familyEventId
          : familyEventId as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
