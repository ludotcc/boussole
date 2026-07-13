const _unset = Object();

class MomentScheduleModes {
  static const daily = 'daily';
  static const weekdays = 'weekdays';
  static const singleDate = 'singleDate';
  static const weekly = 'weekly';

  static const values = [daily, weekdays, singleDate, weekly];
}

class MomentModel {
  final String id;

  /// Famille propriétaire.
  final String familyId;

  /// Nom affiché.
  final String name;

  final String? guidanceText;

  /// Clé de l'illustration.
  /// Exemples : routineMorning, breakfast, videoGames...
  final String iconKey;

  /// Position dans le planning familial.
  final int position;

  /// Heure interne de tri, en minutes depuis minuit.
  final int? orderMinutes;

  /// Ce moment ouvre une routine.
  final bool hasRoutine;

  /// Routine associée.
  final String? routineId;

  final String childTimeDisplayType;

  final int? timerMinutes;

  final int? maxDurationMinutes;

  final bool isMultiUse;

  final int? maxDailyUses;

  final String scheduleMode;

  final List<int> weekdays;

  final DateTime? singleDate;

  final bool active;

  final DateTime createdAt;

  const MomentModel({
    required this.id,
    required this.familyId,
    required this.name,
    this.guidanceText,
    required this.iconKey,
    required this.position,
    this.orderMinutes,
    required this.hasRoutine,
    this.routineId,
    this.childTimeDisplayType = 'none',
    this.timerMinutes,
    this.maxDurationMinutes,
    this.isMultiUse = false,
    this.maxDailyUses,
    this.scheduleMode = MomentScheduleModes.daily,
    this.weekdays = const [],
    this.singleDate,
    required this.active,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'guidanceText': guidanceText,
      'iconKey': iconKey,
      'position': position,
      'orderMinutes': orderMinutes,
      'hasRoutine': hasRoutine,
      'routineId': routineId,
      'childTimeDisplayType': childTimeDisplayType,
      'timerMinutes': timerMinutes,
      'maxDurationMinutes': maxDurationMinutes,
      'isMultiUse': isMultiUse,
      'maxDailyUses': maxDailyUses,
      'scheduleMode': scheduleMode,
      'weekdays': weekdays,
      'singleDate': singleDate?.toIso8601String(),
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MomentModel.fromMap(Map<String, dynamic> map) {
    final scheduleMode =
        map['scheduleMode'] as String? ?? MomentScheduleModes.daily;

    return MomentModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String,
      guidanceText: map['guidanceText'] as String?,
      iconKey: map['iconKey'] as String,
      position: map['position'] as int,
      orderMinutes: map['orderMinutes'] as int?,
      hasRoutine: map['hasRoutine'] as bool,
      routineId: map['routineId'] as String?,
      childTimeDisplayType: map['childTimeDisplayType'] as String? ?? 'none',
      timerMinutes: (map['timerMinutes'] as num?)?.toInt(),
      maxDurationMinutes: (map['maxDurationMinutes'] as num?)?.toInt(),
      isMultiUse: map['isMultiUse'] as bool? ?? false,
      maxDailyUses: (map['maxDailyUses'] as num?)?.toInt(),
      scheduleMode: MomentScheduleModes.values.contains(scheduleMode)
          ? scheduleMode
          : MomentScheduleModes.daily,
      weekdays: List<int>.from(
        (map['weekdays'] as List? ?? const []).map((weekday) {
          return (weekday as num).toInt();
        }),
      ),
      singleDate: map['singleDate'] is String
          ? DateTime.tryParse(map['singleDate'] as String)
          : null,
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  MomentModel copyWith({
    String? id,
    String? familyId,
    String? name,
    Object? guidanceText = _unset,
    String? iconKey,
    int? position,
    Object? orderMinutes = _unset,
    bool? hasRoutine,
    Object? routineId = _unset,
    String? childTimeDisplayType,
    Object? timerMinutes = _unset,
    Object? maxDurationMinutes = _unset,
    bool? isMultiUse,
    Object? maxDailyUses = _unset,
    String? scheduleMode,
    List<int>? weekdays,
    Object? singleDate = _unset,
    bool? active,
    DateTime? createdAt,
  }) {
    return MomentModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      guidanceText: guidanceText == _unset
          ? this.guidanceText
          : guidanceText as String?,
      iconKey: iconKey ?? this.iconKey,
      position: position ?? this.position,
      orderMinutes: orderMinutes == _unset
          ? this.orderMinutes
          : orderMinutes as int?,
      hasRoutine: hasRoutine ?? this.hasRoutine,
      routineId: routineId == _unset ? this.routineId : routineId as String?,
      childTimeDisplayType: childTimeDisplayType ?? this.childTimeDisplayType,
      timerMinutes: timerMinutes == _unset
          ? this.timerMinutes
          : timerMinutes as int?,
      maxDurationMinutes: maxDurationMinutes == _unset
          ? this.maxDurationMinutes
          : maxDurationMinutes as int?,
      isMultiUse: isMultiUse ?? this.isMultiUse,
      maxDailyUses: maxDailyUses == _unset
          ? this.maxDailyUses
          : maxDailyUses as int?,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      weekdays: weekdays ?? this.weekdays,
      singleDate: singleDate == _unset
          ? this.singleDate
          : singleDate as DateTime?,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
