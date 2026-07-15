import 'package:boussole/repositories/daily_settlement_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = DailyLightPolicy();

  test('calcule une progression bornée à partir des éléments pertinents', () {
    final empty = policy.summarize(
      childId: 'child',
      date: DateTime(2026, 7, 14),
      relevantItemIds: const [],
      completedItemIds: const {'orphan'},
    );
    expect(empty.ratio, 0);
    final summary = policy.summarize(
      childId: 'child',
      date: DateTime(2026, 7, 14),
      relevantItemIds: const ['a', 'b', 'c', 'd'],
      completedItemIds: const {'a', 'b', 'orphan'},
    );
    expect(summary.completedItems, 2);
    expect(summary.totalItems, 4);
    expect(summary.ratio, .5);
  });

  test('récompense uniquement une journée complète, au maximum à 5', () {
    expect(policy.calculateDailyShardReward(0), 0);
    expect(policy.calculateDailyShardReward(.99), 0);
    expect(policy.calculateDailyShardReward(1), 5);
    expect(policy.calculateDailyShardReward(2), 5);
  });

  test('plafonne le bonus exceptionnel à un Éclat', () {
    expect(policy.calculateGentleSupportBonus(0), 0);
    expect(policy.calculateGentleSupportBonus(1), 1);
    expect(policy.calculateGentleSupportBonus(4), 1);
  });
}
