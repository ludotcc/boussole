class DailySettlement {
  const DailySettlement({
    required this.childId,
    required this.date,
    required this.completedItems,
    required this.totalItems,
    required this.progressReward,
    required this.gentleSupportBonus,
    required this.totalReward,
    required this.settledAt,
    this.gentleEventIds = const [],
  });

  final String childId;
  final DateTime date;
  final int completedItems;
  final int totalItems;
  final int progressReward;
  final int gentleSupportBonus;
  final int totalReward;
  final DateTime settledAt;
  final List<String> gentleEventIds;

  double get ratio =>
      totalItems == 0 ? 0 : (completedItems / totalItems).clamp(0.0, 1.0);
}
