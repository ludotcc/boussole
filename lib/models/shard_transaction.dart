import 'package:cloud_firestore/cloud_firestore.dart';

enum ShardTransactionType { credit, debit }

enum ShardTransactionSource {
  dayCompletion,
  findingPurchase,
  secretMissionValidation,
}

class ShardTransaction {
  const ShardTransaction({
    required this.id,
    required this.childId,
    required this.type,
    required this.source,
    required this.amount,
    required this.sourceKey,
    required this.createdAt,
  });

  final String id;
  final String childId;
  final ShardTransactionType type;
  final ShardTransactionSource source;
  final int amount;
  final String sourceKey;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'childId': childId,
    'type': type.name,
    'source': source.name,
    'amount': amount,
    'sourceKey': sourceKey,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ShardTransaction.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return ShardTransaction(
      id: id,
      childId: map['childId'] as String? ?? '',
      type: ShardTransactionType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => ShardTransactionType.credit,
      ),
      source: ShardTransactionSource.values.firstWhere(
        (value) => value.name == map['source'],
        orElse: () => ShardTransactionSource.dayCompletion,
      ),
      amount: ((map['amount'] as num?) ?? 0).toInt().abs(),
      sourceKey: map['sourceKey'] as String? ?? id,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
