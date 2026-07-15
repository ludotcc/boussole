import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/guardian_model.dart';
import '../models/guardian_ownership.dart';
import '../repositories/guardian_repository.dart';
import '../services/guardian_service.dart';
import 'rewards_provider.dart';
import 'session_provider.dart';

final guardianRepositoryProvider = Provider<GuardianRepository>(
  (_) => GuardianRepository(),
);

final guardianOwnershipProvider =
    FutureProvider.family<GuardianOwnership, String>((ref, childId) async {
      final session = ref.watch(sessionProvider);
      if (session == null) {
        return GuardianOwnership(
          selectedId: GuardianId.wave,
          ownedIds: const {GuardianId.wave},
        );
      }
      return ref
          .read(guardianRepositoryProvider)
          .getOwnership(familyId: session.familyId, childId: childId);
    });

final childGuardianProvider = FutureProvider.family<GuardianModel, String>((
  ref,
  childId,
) async {
  final ownership = await ref.watch(guardianOwnershipProvider(childId).future);
  return GuardianModel.fromStorageId(
    ownership.selectedId.name,
    fallback: GuardianId.wave,
  );
});

class GuardianSelectionNotifier extends StateNotifier<AsyncValue<void>> {
  GuardianSelectionNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<GuardianSelectionResult?> select({
    required String childId,
    required GuardianModel guardian,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null || state.isLoading) return null;
    GuardianSelectionResult? result;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(guardianRepositoryProvider)
          .selectGuardian(
            familyId: session.familyId,
            childId: childId,
            guardian: guardian,
          );
      ref.invalidate(guardianOwnershipProvider(childId));
    });
    return result;
  }

  Future<GuardianPurchaseResult?> purchase({
    required String childId,
    required GuardianModel guardian,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null || state.isLoading) return null;
    GuardianPurchaseResult? result;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(guardianRepositoryProvider)
          .purchaseGuardian(
            familyId: session.familyId,
            childId: childId,
            guardian: guardian,
          );
      ref.invalidate(guardianOwnershipProvider(childId));
      ref.invalidate(shardWalletProvider(childId));
      ref.invalidate(recentShardTransactionsProvider(childId));
    });
    return result;
  }
}

final guardianSelectionProvider =
    StateNotifierProvider<GuardianSelectionNotifier, AsyncValue<void>>(
      GuardianSelectionNotifier.new,
    );
