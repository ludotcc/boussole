import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryEntry {
  const InventoryEntry({required this.findingId, required this.acquiredAt});

  final String findingId;
  final DateTime acquiredAt;

  Map<String, dynamic> toMap() => {
    'findingId': findingId,
    'acquiredAt': Timestamp.fromDate(acquiredAt),
  };

  factory InventoryEntry.fromMap(String id, Map<String, dynamic> map) {
    final acquiredAt = map['acquiredAt'];
    return InventoryEntry(
      findingId: map['findingId'] as String? ?? id,
      acquiredAt: acquiredAt is Timestamp
          ? acquiredAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
