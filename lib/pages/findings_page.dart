import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/findings_catalog.dart';
import '../models/finding_catalog_item.dart';
import '../providers/findings_provider.dart';
import '../providers/rewards_provider.dart';
import '../services/rewards_service.dart';
import '../widgets/child/finding_card.dart';
import '../widgets/child/shards_balance_badge.dart';
import '../widgets/common/empty_state.dart';

class FindingsPage extends ConsumerStatefulWidget {
  const FindingsPage({super.key, required this.childId});
  final String childId;
  @override
  ConsumerState<FindingsPage> createState() => _FindingsPageState();
}

class _FindingsPageState extends ConsumerState<FindingsPage> {
  FindingCategory? _category;

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(shardWalletProvider(widget.childId));
    final inventory = ref.watch(childInventoryProvider(widget.childId));
    final purchase = ref.watch(findingPurchaseProvider(widget.childId));
    final catalog = ref.watch(findingsCatalogProvider);
    final visible = _category == null
        ? catalog
        : catalog.where((item) => item.category == _category).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/child/${widget.childId}/house'),
        ),
        title: const Text(
          'Les Trouvailles',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ShardsBalanceBadge(childId: widget.childId),
          ),
        ],
      ),
      body: wallet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Oups',
          message: 'Impossible de retrouver tes Éclats.',
        ),
        data: (walletValue) => inventory.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Oups',
            message: 'Impossible de charger tes Trouvailles.',
          ),
          data: (entries) {
            final owned = entries.map((entry) => entry.findingId).toSet();
            final ownedItems = entries
                .map((entry) => findingById(entry.findingId))
                .whereType<FindingCatalogItem>()
                .toList();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ownedItems.isNotEmpty) ...[
                          const Text(
                            'Mes Trouvailles',
                            style: TextStyle(
                              color: Color(0xFF33465C),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 54,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: ownedItems.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, index) {
                                final item = ownedItems[index];
                                return Chip(
                                  avatar: Icon(
                                    findingIcon(item.iconId),
                                    size: 18,
                                  ),
                                  label: Text(item.name),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ChoiceChip(
                                label: const Text('Toutes'),
                                selected: _category == null,
                                onSelected: (_) =>
                                    setState(() => _category = null),
                              ),
                              ...FindingCategory.values.map(
                                (category) => Padding(
                                  padding: const EdgeInsets.only(left: 7),
                                  child: ChoiceChip(
                                    label: Text(_categoryLabel(category)),
                                    selected: _category == category,
                                    onSelected: (_) =>
                                        setState(() => _category = category),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisExtent: 230,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: visible.length,
                    itemBuilder: (_, index) {
                      final item = visible[index];
                      return FindingCard(
                        item: item,
                        owned: owned.contains(item.id),
                        canAfford: walletValue.balance >= item.price,
                        busy: purchase.isLoading,
                        onPurchase: () async {
                          final result = await ref
                              .read(
                                findingPurchaseProvider(
                                  widget.childId,
                                ).notifier,
                              )
                              .purchase(item.id);
                          if (!context.mounted || result == null) return;
                          final message = switch (result) {
                            PurchaseResult.purchased =>
                              '${item.name} rejoint tes Trouvailles.',
                            PurchaseResult.alreadyOwned =>
                              'Cette Trouvaille est déjà à toi.',
                            PurchaseResult.insufficientBalance =>
                              'Il te manque encore quelques Éclats.',
                          };
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _categoryLabel(FindingCategory category) => switch (category) {
    FindingCategory.furniture => 'Mobilier',
    FindingCategory.plant => 'Plantes',
    FindingCategory.light => 'Lumières',
    FindingCategory.decoration => 'Décoration',
    FindingCategory.accessory => 'Accessoires',
    FindingCategory.souvenir => 'Souvenirs',
  };
}
