import 'package:cloud_firestore/cloud_firestore.dart';

enum CompanionMemoryStatus { proposed, validated, refused }

enum CompanionMemoryType {
  preference,
  habit,
  likedActivity,
  likedContext,
  helpfulApproach,
}

class CompanionMemory {
  const CompanionMemory({
    required this.id,
    required this.childId,
    required this.type,
    required this.value,
    required this.status,
    required this.priority,
    required this.reliability,
    required this.observationCount,
    required this.createdAt,
    required this.updatedAt,
    required this.lastObservedAt,
    this.decidedAt,
    this.decidedByParentId,
  });

  final String id;
  final String childId;
  final CompanionMemoryType type;
  final String value;
  final CompanionMemoryStatus status;
  final int priority;
  final double reliability;
  final int observationCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastObservedAt;
  final DateTime? decidedAt;
  final String? decidedByParentId;

  bool get isValidated => status == CompanionMemoryStatus.validated;
  bool get isProposed => status == CompanionMemoryStatus.proposed;

  CompanionMemory decide({
    required CompanionMemoryStatus decision,
    required String parentId,
    required DateTime decidedAt,
  }) {
    if (!isProposed || decision == CompanionMemoryStatus.proposed) return this;
    return CompanionMemory(
      id: id,
      childId: childId,
      type: type,
      value: value,
      status: decision,
      priority: priority,
      reliability: reliability,
      observationCount: observationCount,
      createdAt: createdAt,
      updatedAt: decidedAt,
      lastObservedAt: lastObservedAt,
      decidedAt: decidedAt,
      decidedByParentId: parentId,
    );
  }

  Map<String, dynamic> toMap() => {
    'childId': childId,
    'type': type.name,
    'value': value,
    'status': status.name,
    'priority': priority,
    'reliability': reliability,
    'observationCount': observationCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'lastObservedAt': Timestamp.fromDate(lastObservedAt),
    'decidedAt': decidedAt == null ? null : Timestamp.fromDate(decidedAt!),
    'decidedByParentId': decidedByParentId,
  };

  factory CompanionMemory.fromMap(String id, Map<String, dynamic> map) {
    final now = DateTime.now();
    DateTime date(String key, [DateTime? fallback]) => map[key] is Timestamp
        ? (map[key] as Timestamp).toDate()
        : fallback ?? now;
    return CompanionMemory(
      id: id,
      childId: map['childId'] as String? ?? '',
      type: CompanionMemoryType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => CompanionMemoryType.preference,
      ),
      value: map['value'] as String? ?? '',
      status: CompanionMemoryStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => CompanionMemoryStatus.proposed,
      ),
      priority: ((map['priority'] as num?) ?? 0).toInt(),
      reliability: ((map['reliability'] as num?) ?? 0).toDouble(),
      observationCount: ((map['observationCount'] as num?) ?? 0).toInt(),
      createdAt: date('createdAt'),
      updatedAt: date('updatedAt'),
      lastObservedAt: date('lastObservedAt'),
      decidedAt: map['decidedAt'] is Timestamp ? date('decidedAt') : null,
      decidedByParentId: map['decidedByParentId'] as String?,
    );
  }
}
