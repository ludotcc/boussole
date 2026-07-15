import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/guardian_model.dart';
import '../providers/guardian_provider.dart';
import '../providers/rewards_provider.dart';
import '../services/guardian_service.dart';

class GuardianSelectionPage extends ConsumerWidget {
  const GuardianSelectionPage({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(childGuardianProvider(childId)).valueOrNull;
    final ownership = ref.watch(guardianOwnershipProvider(childId)).valueOrNull;
    final balance =
        ref.watch(shardWalletProvider(childId)).valueOrNull?.balance ?? 0;
    final selection = ref.watch(guardianSelectionProvider);

    ref.listen(guardianSelectionProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de changer de Gardien.')),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0E8),
      appBar: AppBar(
        title: const Text(
          'Choisis ton Gardien',
          style: TextStyle(
            color: Color(0xFF26384D),
            fontWeight: FontWeight.w900,
          ),
        ),
        foregroundColor: const Color(0xFF26384D),
        backgroundColor: const Color(0xFFF3F0E8),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisExtent: 206,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: GuardianModel.all.length,
          itemBuilder: (context, index) {
            final guardian = GuardianModel.all[index];
            final isOwned =
                ownership?.owns(guardian.id) ?? guardian.id == GuardianId.wave;
            return _GuardianCard(
              guardian: guardian,
              isSelected: selected?.id == guardian.id,
              isOwned: isOwned,
              hasEnoughShards: balance >= guardian.price,
              isBusy: selection.isLoading,
              onTap: () async {
                final notifier = ref.read(guardianSelectionProvider.notifier);
                if (isOwned) {
                  final result = await notifier.select(
                    childId: childId,
                    guardian: guardian,
                  );
                  if (context.mounted &&
                      result == GuardianSelectionResult.selected) {
                    context.pop();
                  }
                  return;
                }
                if (balance < guardian.price) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tu n’as pas encore assez d’Éclats.'),
                    ),
                  );
                  return;
                }
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text('Accueillir ${guardian.name} ?'),
                    content: Text(
                      '${guardian.name} coûte ${guardian.price} Éclats.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Annuler'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Acheter'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
                final result = await notifier.purchase(
                  childId: childId,
                  guardian: guardian,
                );
                if (!context.mounted) return;
                final message = switch (result) {
                  GuardianPurchaseResult.purchased =>
                    '${guardian.name} fait maintenant partie de tes Compagnons.',
                  GuardianPurchaseResult.alreadyOwned =>
                    '${guardian.name} est déjà à toi.',
                  GuardianPurchaseResult.insufficientBalance =>
                    'Tu n’as pas encore assez d’Éclats.',
                  null => 'Impossible de réaliser cet achat.',
                };
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              },
            );
          },
        ),
      ),
    );
  }
}

class _GuardianCard extends StatelessWidget {
  const _GuardianCard({
    required this.guardian,
    required this.isSelected,
    required this.isOwned,
    required this.hasEnoughShards,
    required this.isBusy,
    required this.onTap,
  });

  final GuardianModel guardian;
  final bool isSelected;
  final bool isOwned;
  final bool hasEnoughShards;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(guardian.color);
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${guardian.name}, ${guardian.personality}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        elevation: isSelected ? 4 : 1,
        child: InkWell(
          onTap: isBusy ? null : onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(7, 5, 7, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    guardian.idleAsset,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Text(
                  guardian.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  guardian.personality,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF526174),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isSelected
                      ? 'Sélectionné'
                      : isOwned
                      ? 'Possédé · Choisir'
                      : hasEnoughShards
                      ? '${guardian.price} Éclats · À acheter'
                      : '${guardian.price} Éclats · Solde insuffisant',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
