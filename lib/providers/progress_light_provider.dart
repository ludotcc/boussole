import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_light_summary.dart';
import '../models/daily_settlement.dart';
import '../repositories/daily_settlement_repository.dart';
import 'child_day_progress_provider.dart';
import 'moments_provider.dart';
import 'rewards_provider.dart';
import 'session_provider.dart';

final dailySettlementRepositoryProvider = Provider<DailySettlementRepository>(
  (_) => DailySettlementRepository(),
);

final dailyLightSummaryProvider =
    FutureProvider.family<DailyLightSummary, String>((ref, childId) async {
      final session = ref.watch(sessionProvider);
      if (session == null) throw StateError('Session absente');
      final items = await ref.watch(childDayItemsProvider(childId).future);
      final active = items
          .where((item) => item.moment?.active ?? true)
          .toList();
      final allIds = active.map((item) => item.id).toList();
      var progress = ref.watch(childDayProgressProvider);
      final now = DateTime.now();
      final todayKey =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      if (progress.childId != childId || progress.dateKey != todayKey) {
        await ref
            .read(childDayProgressProvider.notifier)
            .loadForToday(childId: childId, momentIds: allIds);
        progress = ref.read(childDayProgressProvider);
      }
      final relevantIds = active
          .where(
            (item) =>
                !(item.moment?.isMultiUse ?? false) &&
                !progress.isDismissed(item.id),
          )
          .map((item) => item.id);
      final summary = const DailyLightPolicy().summarize(
        childId: childId,
        date: now,
        relevantItemIds: relevantIds,
        completedItemIds: progress.completedMomentIds,
      );
      await ref
          .read(dailySettlementRepositoryProvider)
          .saveCurrentLight(familyId: session.familyId, summary: summary);
      return summary;
    });

class DailySettlementNotifier
    extends StateNotifier<AsyncValue<List<DailySettlement>>> {
  DailySettlementNotifier(this.ref, this.childId) : super(const AsyncData([]));

  final Ref ref;
  final String childId;
  bool _started = false;
  bool _announced = false;

  Future<void> settlePending() async {
    if (_started) return;
    _started = true;
    final session = ref.read(sessionProvider);
    if (session == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final results = await ref
          .read(dailySettlementRepositoryProvider)
          .settlePendingDays(familyId: session.familyId, childId: childId);
      if (results.isNotEmpty) {
        ref.invalidate(shardWalletProvider(childId));
        ref.invalidate(recentShardTransactionsProvider(childId));
      }
      return results;
    });
  }

  void consumeRecap() => state = const AsyncData([]);

  bool takeRecapAnnouncement() {
    if (_announced || (state.valueOrNull?.isEmpty ?? true)) return false;
    _announced = true;
    return true;
  }
}

final dailySettlementProvider =
    StateNotifierProvider.family<
      DailySettlementNotifier,
      AsyncValue<List<DailySettlement>>,
      String
    >((ref, childId) => DailySettlementNotifier(ref, childId));
