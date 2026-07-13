class ChildDayProgressModel {
  final String id;
  final String familyId;
  final String childId;
  final String dateKey;
  final Map<String, String> momentStatuses;
  final Map<String, DateTime> startedAtByMomentId;
  final Map<String, int> dailyUseCountsByMomentId;
  final List<String> customOrderItemIds;
  final List<String> dismissedMomentIds;
  final DateTime updatedAt;

  const ChildDayProgressModel({
    required this.id,
    required this.familyId,
    required this.childId,
    required this.dateKey,
    required this.momentStatuses,
    this.startedAtByMomentId = const {},
    this.dailyUseCountsByMomentId = const {},
    this.customOrderItemIds = const [],
    this.dismissedMomentIds = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'childId': childId,
      'dateKey': dateKey,
      'momentStatuses': momentStatuses,
      'startedAtByMomentId': {
        for (final entry in startedAtByMomentId.entries)
          entry.key: entry.value.toIso8601String(),
      },
      'dailyUseCountsByMomentId': dailyUseCountsByMomentId,
      'customOrderItemIds': customOrderItemIds,
      'dismissedMomentIds': dismissedMomentIds,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChildDayProgressModel.fromMap(Map<String, dynamic> map) {
    return ChildDayProgressModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      childId: map['childId'] as String,
      dateKey: map['dateKey'] as String,
      momentStatuses: Map<String, String>.from(
        map['momentStatuses'] as Map? ?? const {},
      ),
      startedAtByMomentId: _startedAtByMomentIdFromMap(
        map['startedAtByMomentId'] as Map?,
      ),
      dailyUseCountsByMomentId: _intMapFromMap(
        map['dailyUseCountsByMomentId'] as Map?,
      ),
      customOrderItemIds: List<String>.from(
        map['customOrderItemIds'] as List? ?? const [],
      ),
      dismissedMomentIds: List<String>.from(
        map['dismissedMomentIds'] as List? ?? const [],
      ),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  static Map<String, DateTime> _startedAtByMomentIdFromMap(Map? map) {
    if (map == null) {
      return const {};
    }

    return {
      for (final entry in map.entries)
        if (entry.key is String && entry.value is String)
          entry.key as String: DateTime.parse(entry.value as String),
    };
  }

  static Map<String, int> _intMapFromMap(Map? map) {
    if (map == null) {
      return const {};
    }

    return {
      for (final entry in map.entries)
        if (entry.key is String && entry.value is num)
          entry.key as String: (entry.value as num).toInt(),
    };
  }
}
