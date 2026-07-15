import 'package:cloud_firestore/cloud_firestore.dart';

class ParentReward {
  const ParentReward({
    required this.id,
    required this.childId,
    required this.name,
    required this.cost,
    required this.createdAt,
    this.isActive = true,
  });

  final String id;
  final String childId;
  final String name;
  final int cost;
  final bool isActive;
  final DateTime createdAt;

  bool get isValid => name.trim().isNotEmpty && cost > 0;

  Map<String, dynamic> toMap() => {
    'childId': childId,
    'name': name.trim(),
    'cost': cost,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ParentReward.fromMap(String id, Map<String, dynamic> map) =>
      ParentReward(
        id: id,
        childId: map['childId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        cost: ((map['cost'] as num?) ?? 0).toInt(),
        isActive: map['isActive'] as bool? ?? true,
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.fromMillisecondsSinceEpoch(0),
      );
}
