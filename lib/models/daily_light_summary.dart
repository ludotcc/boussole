class DailyLightSummary {
  const DailyLightSummary({
    required this.childId,
    required this.date,
    required this.completedItems,
    required this.totalItems,
  });

  final String childId;
  final DateTime date;
  final int completedItems;
  final int totalItems;

  double get ratio =>
      totalItems == 0 ? 0 : (completedItems / totalItems).clamp(0.0, 1.0);

  Map<String, dynamic> toMap() => {
    'childId': childId,
    'date': _dateKey(date),
    'completedItems': completedItems,
    'totalItems': totalItems,
    'progressRatio': ratio,
  };

  static String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
