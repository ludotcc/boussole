import 'package:cloud_firestore/cloud_firestore.dart';

enum CelebrationStatus { pending, delivered }

enum CelebrationType {
  courage,
  patience,
  autonomy,
  respect,
  politeness,
  emotionManagement,
  perseverance,
  helping,
  initiative,
  positiveBehavior,
}

class Celebration {
  const Celebration({
    required this.id,
    required this.childId,
    required this.type,
    required this.createdByParentId,
    required this.createdAt,
    this.status = CelebrationStatus.pending,
    this.shardReward = 0,
    this.deliveredAt,
    this.rewardDeliveredAt,
  });

  final String id;
  final String childId;
  final CelebrationType type;
  final String createdByParentId;
  final DateTime createdAt;
  final CelebrationStatus status;
  final int shardReward;
  final DateTime? deliveredAt;
  final DateTime? rewardDeliveredAt;

  bool shouldCreditReward({required bool ledgerExists}) =>
      status == CelebrationStatus.pending && shardReward > 0 && !ledgerExists;

  factory Celebration.parentCreated({
    required String id,
    required String childId,
    required CelebrationType type,
    required String parentId,
    required DateTime createdAt,
    required int shardReward,
  }) => Celebration(
    id: id,
    childId: childId,
    type: type,
    createdByParentId: parentId,
    createdAt: createdAt,
    shardReward: shardReward.clamp(0, 5),
  );

  Map<String, dynamic> toMap() => {
    'childId': childId,
    'type': type.name,
    'createdByParentId': createdByParentId,
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status.name,
    'shardReward': shardReward,
    'deliveredAt': deliveredAt == null
        ? null
        : Timestamp.fromDate(deliveredAt!),
    'rewardDeliveredAt': rewardDeliveredAt == null
        ? null
        : Timestamp.fromDate(rewardDeliveredAt!),
  };

  factory Celebration.fromMap(String id, Map<String, dynamic> map) {
    final now = DateTime.now();
    return Celebration(
      id: id,
      childId: map['childId'] as String? ?? '',
      type: CelebrationType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => CelebrationType.positiveBehavior,
      ),
      createdByParentId: map['createdByParentId'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : now,
      status: CelebrationStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => CelebrationStatus.pending,
      ),
      shardReward: ((map['shardReward'] as num?) ?? 0).toInt().clamp(0, 5),
      deliveredAt: map['deliveredAt'] is Timestamp
          ? (map['deliveredAt'] as Timestamp).toDate()
          : null,
      rewardDeliveredAt: map['rewardDeliveredAt'] is Timestamp
          ? (map['rewardDeliveredAt'] as Timestamp).toDate()
          : null,
    );
  }
}
