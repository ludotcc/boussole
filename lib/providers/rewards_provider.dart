import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shard_transaction.dart';
import '../models/shard_wallet.dart';
import '../models/parent_reward.dart';
import '../models/reward_announcement.dart';
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

final parentRewardsProvider = FutureProvider.family<List<ParentReward>, String>(
  (ref, childId) async {
    final session = ref.watch(sessionProvider);
    if (session == null || childId.isEmpty) throw StateError('Enfant invalide');
    return ref
        .read(rewardsRepositoryProvider)
        .getParentRewards(familyId: session.familyId, childId: childId);
  },
);

final pendingRewardAnnouncementsProvider =
    FutureProvider.family<List<RewardAnnouncement>, String>((
      ref,
      childId,
    ) async {
      final session = ref.watch(sessionProvider);
      if (session == null || childId.isEmpty) {
        throw StateError('Enfant invalide');
      }
      return ref
          .read(rewardsRepositoryProvider)
          .getPendingRewardAnnouncements(
            familyId: session.familyId,
            childId: childId,
          );
    });

class ParentRewardActionNotifier extends StateNotifier<AsyncValue<void>> {
  ParentRewardActionNotifier(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> save({
    required String childId,
    ParentReward? current,
    required String name,
    required int cost,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(rewardsRepositoryProvider);
      await repository.saveParentReward(
        familyId: session.familyId,
        reward: ParentReward(
          id:
              current?.id ??
              repository.generateParentRewardId(session.familyId, childId),
          childId: childId,
          name: name,
          cost: cost,
          isActive: current?.isActive ?? true,
          createdAt: current?.createdAt ?? DateTime.now(),
        ),
      );
      ref.invalidate(parentRewardsProvider(childId));
    });
  }

  Future<void> delete(ParentReward reward) async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(rewardsRepositoryProvider)
          .deleteParentReward(
            familyId: session.familyId,
            childId: reward.childId,
            rewardId: reward.id,
          );
      ref.invalidate(parentRewardsProvider(reward.childId));
    });
  }

  Future<ParentRewardRedemptionResult?> redeem(ParentReward reward) async {
    final session = ref.read(sessionProvider);
    if (session == null || state.isLoading) return null;
    ParentRewardRedemptionResult? result;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(rewardsRepositoryProvider);
      result = await repository.redeemParentReward(
        familyId: session.familyId,
        childId: reward.childId,
        rewardId: reward.id,
        redemptionId: repository.generateRedemptionId(
          session.familyId,
          reward.childId,
        ),
      );
      ref.invalidate(shardWalletProvider(reward.childId));
      ref.invalidate(recentShardTransactionsProvider(reward.childId));
      ref.invalidate(pendingRewardAnnouncementsProvider(reward.childId));
    });
    return result;
  }

  Future<void> markAnnouncementDelivered(
    RewardAnnouncement announcement,
  ) async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    await ref
        .read(rewardsRepositoryProvider)
        .markRewardAnnouncementDelivered(
          familyId: session.familyId,
          childId: announcement.childId,
          announcementId: announcement.id,
        );
    ref.invalidate(pendingRewardAnnouncementsProvider(announcement.childId));
  }
}

final parentRewardActionProvider =
    StateNotifierProvider<ParentRewardActionNotifier, AsyncValue<void>>(
      (ref) => ParentRewardActionNotifier(ref),
    );

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
