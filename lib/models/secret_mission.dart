import 'package:cloud_firestore/cloud_firestore.dart';

enum SecretMissionStatus {
  available,
  accepted,
  completedByChild,
  awaitingParentValidation,
  validated,
  refused,
  expired,
}

enum SecretMissionCategory {
  family,
  helping,
  creativity,
  nature,
  courage,
  emotions,
}

enum SecretMissionOrigin { automatic, parent }

class SecretMission {
  const SecretMission({
    required this.id,
    required this.childId,
    required this.catalogId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.origin,
    required this.reward,
    required this.idempotencyKey,
    this.guardianId,
    this.validatedAt,
    this.validatedBy,
    this.announcementDeliveredAt,
    this.announcementPending = false,
  });
  final String id;
  final String childId;
  final String catalogId;
  final String title;
  final String description;
  final SecretMissionCategory category;
  final SecretMissionStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final SecretMissionOrigin origin;
  final int reward;
  final String idempotencyKey;
  final String? guardianId;
  final DateTime? validatedAt;
  final String? validatedBy;
  final DateTime? announcementDeliveredAt;
  final bool announcementPending;

  bool get isExpired => expiresAt.isBefore(DateTime.now());
  bool get isPending => status == SecretMissionStatus.awaitingParentValidation;
  bool get hasPendingAnnouncement =>
      announcementPending &&
      status == SecretMissionStatus.validated &&
      announcementDeliveredAt == null;

  Map<String, dynamic> toMap() => {
    'id': id,
    'childId': childId,
    'catalogId': catalogId,
    'title': title,
    'description': description,
    'category': category.name,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'expiresAt': Timestamp.fromDate(expiresAt),
    'origin': origin.name,
    'reward': reward,
    'idempotencyKey': idempotencyKey,
    'guardianId': guardianId,
    'validatedAt': validatedAt == null
        ? null
        : Timestamp.fromDate(validatedAt!),
    'validatedBy': validatedBy,
    'announcementDeliveredAt': announcementDeliveredAt == null
        ? null
        : Timestamp.fromDate(announcementDeliveredAt!),
    'announcementPending': announcementPending,
  };

  factory SecretMission.fromMap(String id, Map<String, dynamic> map) {
    DateTime date(String key, DateTime fallback) =>
        map[key] is Timestamp ? (map[key] as Timestamp).toDate() : fallback;
    final now = DateTime.now();
    return SecretMission(
      id: id,
      childId: map['childId'] as String? ?? '',
      catalogId: map['catalogId'] as String? ?? '',
      title: map['title'] as String? ?? 'Mission Secrète',
      description: map['description'] as String? ?? '',
      category: SecretMissionCategory.values.firstWhere(
        (v) => v.name == map['category'],
        orElse: () => SecretMissionCategory.family,
      ),
      status: SecretMissionStatus.values.firstWhere(
        (v) => v.name == map['status'],
        orElse: () => SecretMissionStatus.available,
      ),
      createdAt: date('createdAt', now),
      expiresAt: date('expiresAt', now),
      origin: SecretMissionOrigin.values.firstWhere(
        (v) => v.name == map['origin'],
        orElse: () => SecretMissionOrigin.automatic,
      ),
      reward: ((map['reward'] as num?) ?? 1).toInt().clamp(0, 1),
      idempotencyKey: map['idempotencyKey'] as String? ?? 'mission_$id',
      guardianId: map['guardianId'] as String?,
      validatedAt: map['validatedAt'] is Timestamp
          ? (map['validatedAt'] as Timestamp).toDate()
          : null,
      validatedBy: map['validatedBy'] as String?,
      announcementDeliveredAt: map['announcementDeliveredAt'] is Timestamp
          ? (map['announcementDeliveredAt'] as Timestamp).toDate()
          : null,
      announcementPending: map['announcementPending'] as bool? ?? false,
    );
  }
}
