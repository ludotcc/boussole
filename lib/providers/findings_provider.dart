import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/findings_catalog.dart';
import '../models/finding_catalog_item.dart';
import '../models/inventory_entry.dart';
import '../services/rewards_service.dart';
import 'rewards_provider.dart';
import 'session_provider.dart';

final findingsCatalogProvider = Provider<List<FindingCatalogItem>>(
  (_) => findingsCatalog,
);

final childInventoryProvider =
    FutureProvider.family<List<InventoryEntry>, String>((ref, childId) async {
      final session = ref.watch(sessionProvider);
      if (session == null || childId.isEmpty) {
        throw StateError('Enfant invalide');
      }
      return ref
          .read(rewardsRepositoryProvider)
          .getInventory(familyId: session.familyId, childId: childId);
    });

class FindingPurchaseNotifier
    extends StateNotifier<AsyncValue<PurchaseResult?>> {
  FindingPurchaseNotifier(this.ref, this.childId)
    : super(const AsyncData(null));
  final Ref ref;
  final String childId;

  Future<PurchaseResult?> purchase(String findingId) async {
    if (state.isLoading) return null;
    final session = ref.read(sessionProvider);
    if (session == null || childId.isEmpty) return null;
    PurchaseResult? result;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(rewardsRepositoryProvider)
          .purchaseFinding(
            familyId: session.familyId,
            childId: childId,
            findingId: findingId,
          );
      if (result == PurchaseResult.purchased) {
        ref.invalidate(shardWalletProvider(childId));
        ref.invalidate(childInventoryProvider(childId));
        ref.invalidate(recentShardTransactionsProvider(childId));
      }
      return result;
    });
    return result;
  }
}

final findingPurchaseProvider =
    StateNotifierProvider.family<
      FindingPurchaseNotifier,
      AsyncValue<PurchaseResult?>,
      String
    >((ref, childId) => FindingPurchaseNotifier(ref, childId));
