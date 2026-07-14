import 'package:cloud_firestore/cloud_firestore.dart';

class ShardWallet {
  const ShardWallet({
    required this.childId,
    required this.balance,
    required this.updatedAt,
  });

  final String childId;
  final int balance;
  final DateTime updatedAt;

  factory ShardWallet.empty(String childId) => ShardWallet(
    childId: childId,
    balance: 0,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  factory ShardWallet.fromMap(String childId, Map<String, dynamic>? map) {
    final updatedAt = map?['updatedAt'];
    return ShardWallet(
      childId: childId,
      balance: ((map?['balance'] as num?) ?? 0).toInt().clamp(0, 1 << 31),
      updatedAt: updatedAt is Timestamp
          ? updatedAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
