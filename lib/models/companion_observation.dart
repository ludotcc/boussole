import 'package:cloud_firestore/cloud_firestore.dart';

enum CompanionObservationType {
  displayed,
  chosen,
  refused,
  requestedMore,
  closedWithoutChoice,
}

class CompanionObservation {
  const CompanionObservation({
    required this.id,
    required this.childId,
    required this.sessionId,
    required this.type,
    required this.createdAt,
    this.momentId,
  });

  final String id;
  final String childId;
  final String sessionId;
  final CompanionObservationType type;
  final DateTime createdAt;
  final String? momentId;

  Map<String, dynamic> toMap() => {
    'childId': childId,
    'sessionId': sessionId,
    'type': type.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'momentId': momentId,
  };

  factory CompanionObservation.fromMap(String id, Map<String, dynamic> map) =>
      CompanionObservation(
        id: id,
        childId: map['childId'] as String? ?? '',
        sessionId: map['sessionId'] as String? ?? '',
        type: CompanionObservationType.values.firstWhere(
          (value) => value.name == map['type'],
          orElse: () => CompanionObservationType.displayed,
        ),
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        momentId: map['momentId'] as String?,
      );
}
