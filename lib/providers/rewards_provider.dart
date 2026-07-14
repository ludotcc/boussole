import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shard_transaction.dart';
import '../models/shard_wallet.dart';
import '../repositories/rewards_repository.dart';
import '../services/rewards_service.dart';
import 'session_provider.dart';

final rewardsRepositoryProvider = Provider<RewardsRepository>(
  (_) => RewardsRepository(),
);

final shardWalletProvider = FutureProvider.family<ShardWallet, String>((
  ref,
  childId,
) async {
  final session = ref.watch(sessionProvider);
  if (session == null || childId.isEmpty) throw StateError('Enfant invalide');
  return ref
      .read(rewardsRepositoryProvider)
      .getWallet(familyId: session.familyId, childId: childId);
});

final recentShardTransactionsProvider =
    FutureProvider.family<List<ShardTransaction>, String>((ref, childId) async {
      final session = ref.watch(sessionProvider);
      if (session == null || childId.isEmpty) {
        throw StateError('Enfant invalide');
      }
      return ref
          .read(rewardsRepositoryProvider)
          .getRecentTransactions(familyId: session.familyId, childId: childId);
    });

class DayCompletionRewardNotifier
    extends StateNotifier<AsyncValue<CreditResult?>> {
  DayCompletionRewardNotifier(this.ref, this.childId)
    : super(const AsyncData(null));
  final Ref ref;
  final String childId;

  Future<CreditResult?> award(DateTime date) async {
    final session = ref.read(sessionProvider);
    if (session == null || childId.isEmpty) return null;
    state = const AsyncLoading();
    CreditResult? result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(rewardsRepositoryProvider)
          .rewardDayCompletion(
            familyId: session.familyId,
            childId: childId,
            date: date,
          );
      ref.invalidate(shardWalletProvider(childId));
      ref.invalidate(recentShardTransactionsProvider(childId));
      return result;
    });
    return result;
  }
}

final dayCompletionRewardProvider =
    StateNotifierProvider.family<
      DayCompletionRewardNotifier,
      AsyncValue<CreditResult?>,
      String
    >((ref, childId) => DayCompletionRewardNotifier(ref, childId));
