import 'package:cloud_firestore/cloud_firestore.dart';

class RewardAnnouncement {
  const RewardAnnouncement({
    required this.id,
    required this.childId,
    required this.rewardName,
    required this.cost,
    required this.remainingBalance,
    required this.createdAt,
    this.deliveredAt,
  });

  final String id;
  final String childId;
  final String rewardName;
  final int cost;
  final int remainingBalance;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  bool get isPending => deliveredAt == null;

  Map<String, dynamic> toMap() => {
    'childId': childId,
    'rewardName': rewardName,
    'cost': cost,
    'remainingBalance': remainingBalance,
    'createdAt': Timestamp.fromDate(createdAt),
    'deliveredAt': deliveredAt == null
        ? null
        : Timestamp.fromDate(deliveredAt!),
  };

  factory RewardAnnouncement.fromMap(String id, Map<String, dynamic> map) =>
      RewardAnnouncement(
        id: id,
        childId: map['childId'] as String? ?? '',
        rewardName: map['rewardName'] as String? ?? '',
        cost: ((map['cost'] as num?) ?? 0).toInt(),
        remainingBalance: ((map['remainingBalance'] as num?) ?? 0).toInt(),
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.fromMillisecondsSinceEpoch(0),
        deliveredAt: map['deliveredAt'] is Timestamp
            ? (map['deliveredAt'] as Timestamp).toDate()
            : null,
      );
}
