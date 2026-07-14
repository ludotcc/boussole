import 'package:flutter_test/flutter_test.dart';
import 'package:boussole/repositories/daily_settlement_repository.dart';

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

  test('applique tous les seuils du barème', () {
    expect(policy.calculateDailyShardReward(0), 0);
    expect(policy.calculateDailyShardReward(.24), 0);
    expect(policy.calculateDailyShardReward(.25), 5);
    expect(policy.calculateDailyShardReward(.49), 5);
    expect(policy.calculateDailyShardReward(.50), 10);
    expect(policy.calculateDailyShardReward(.74), 10);
    expect(policy.calculateDailyShardReward(.75), 18);
    expect(policy.calculateDailyShardReward(.99), 18);
    expect(policy.calculateDailyShardReward(1), 25);
  });

  test('plafonne le bonus doux à six Éclats', () {
    expect(policy.calculateGentleSupportBonus(0), 0);
    expect(policy.calculateGentleSupportBonus(1), 3);
    expect(policy.calculateGentleSupportBonus(2), 6);
    expect(policy.calculateGentleSupportBonus(4), 6);
  });
}
