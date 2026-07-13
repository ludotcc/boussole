const _unset = Object();

class FamilyEventModel {
  final String id;
  final String familyId;
  final String title;
  final String? description;
  final String type;
  final DateTime date;
  final String? time;
  final bool isAllDay;
  final bool isSensitiveMoment;
  final List<String> memberIds;
  final String recurrenceType;
  final String childTimeDisplayType;
  final int? timerMinutes;
  final int? maxDurationMinutes;
  final String? endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyEventModel({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    required this.type,
    required this.date,
    this.time,
    required this.isAllDay,
    this.isSensitiveMoment = false,
    required this.memberIds,
    required this.recurrenceType,
    this.childTimeDisplayType = 'none',
    this.timerMinutes,
    this.maxDurationMinutes,
    this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'description': description,
      'type': type,
      'date': date.toIso8601String(),
      'time': time,
      'isAllDay': isAllDay,
      'isSensitiveMoment': isSensitiveMoment,
      'memberIds': memberIds,
      'recurrenceType': recurrenceType,
      'childTimeDisplayType': childTimeDisplayType,
      'timerMinutes': timerMinutes,
      'maxDurationMinutes': maxDurationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FamilyEventModel.fromMap(Map<String, dynamic> map) {
    final rawType = map['childTimeDisplayType'] as String? ?? 'none';
    final legacyDuration = (map['durationMinutes'] as num?)?.toInt();
    final legacyEndTime = map['endTime'] as String?;
    final childTimeDisplayType = switch (rawType) {
      'duration' => 'timer',
      'endTime' => 'maxDuration',
      'timer' || 'maxDuration' => rawType,
      _ => 'none',
    };

    return FamilyEventModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      type: map['type'] as String? ?? 'autre',
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String?,
      isAllDay: map['isAllDay'] as bool? ?? false,
      isSensitiveMoment: map['isSensitiveMoment'] as bool? ?? false,
      memberIds: List<String>.from(map['memberIds'] as List? ?? const []),
      recurrenceType: map['recurrenceType'] as String? ?? 'none',
      childTimeDisplayType: childTimeDisplayType,
      timerMinutes: (map['timerMinutes'] as num?)?.toInt() ?? legacyDuration,
      maxDurationMinutes: (map['maxDurationMinutes'] as num?)?.toInt(),
      endTime: legacyEndTime,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  FamilyEventModel copyWith({
    String? id,
    String? familyId,
    String? title,
    Object? description = _unset,
    String? type,
    DateTime? date,
    Object? time = _unset,
    bool? isAllDay,
    bool? isSensitiveMoment,
    List<String>? memberIds,
    String? recurrenceType,
    String? childTimeDisplayType,
    Object? timerMinutes = _unset,
    Object? maxDurationMinutes = _unset,
    Object? endTime = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyEventModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      title: title ?? this.title,
      description: description == _unset
          ? this.description
          : description as String?,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time == _unset ? this.time : time as String?,
      isAllDay: isAllDay ?? this.isAllDay,
      isSensitiveMoment: isSensitiveMoment ?? this.isSensitiveMoment,
      memberIds: memberIds ?? this.memberIds,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      childTimeDisplayType: childTimeDisplayType ?? this.childTimeDisplayType,
      timerMinutes: timerMinutes == _unset
          ? this.timerMinutes
          : timerMinutes as int?,
      maxDurationMinutes: maxDurationMinutes == _unset
          ? this.maxDurationMinutes
          : maxDurationMinutes as int?,
      endTime: endTime == _unset ? this.endTime : endTime as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
