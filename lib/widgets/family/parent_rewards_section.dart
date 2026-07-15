import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/family_member_model.dart';
import '../../models/parent_reward.dart';
import '../../providers/rewards_provider.dart';
import '../../services/rewards_service.dart';
import '../common/app_card.dart';

class ParentRewardsSection extends ConsumerWidget {
  const ParentRewardsSection({
    super.key,
    required this.child,
    this.allowEditing = false,
    this.allowRedemption = false,
  });

  final FamilyMemberModel child;
  final bool allowEditing;
  final bool allowRedemption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(parentRewardsProvider(child.id));
    final wallet = ref.watch(shardWalletProvider(child.id));
    final action = ref.watch(parentRewardActionProvider);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Récompenses et privilèges',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              if (allowEditing && (rewards.valueOrNull?.length ?? 0) < 5)
                IconButton(
                  tooltip: 'Ajouter',
                  onPressed: action.isLoading
                      ? null
                      : () => _editReward(context, ref),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
            ],
          ),
          if (allowRedemption)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                wallet.when(
                  data: (value) =>
                      '${child.firstName} · ${value.balance} Éclats',
                  loading: () => '${child.firstName} · …',
                  error: (_, _) => '${child.firstName} · solde indisponible',
                ),
              ),
            ),
          rewards.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(error.toString()),
            data: (items) => items.isEmpty
                ? const Text('Aucune récompense pour le moment.')
                : Column(
                    children: [
                      for (final reward in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(reward.name),
                          subtitle: Text('${reward.cost} Éclats'),
                          trailing: allowEditing
                              ? Wrap(
                                  children: [
                                    IconButton(
                                      tooltip: 'Modifier',
                                      onPressed: action.isLoading
                                          ? null
                                          : () => _editReward(
                                              context,
                                              ref,
                                              reward: reward,
                                            ),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Supprimer',
                                      onPressed: action.isLoading
                                          ? null
                                          : () => ref
                                                .read(
                                                  parentRewardActionProvider
                                                      .notifier,
                                                )
                                                .delete(reward),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                )
                              : allowRedemption
                              ? FilledButton(
                                  onPressed: action.isLoading
                                      ? null
                                      : () => _confirmRedemption(
                                          context,
                                          ref,
                                          reward,
                                        ),
                                  child: const Text('Valider'),
                                )
                              : null,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _editReward(
    BuildContext context,
    WidgetRef ref, {
    ParentReward? reward,
  }) async {
    final name = TextEditingController(text: reward?.name);
    final cost = TextEditingController(text: reward?.cost.toString());
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reward == null ? 'Nouvelle récompense' : 'Modifier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: cost,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Coût en Éclats'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    final parsedCost = int.tryParse(cost.text.trim());
    if (saved == true &&
        name.text.trim().isNotEmpty &&
        parsedCost != null &&
        parsedCost > 0) {
      await ref
          .read(parentRewardActionProvider.notifier)
          .save(
            childId: child.id,
            current: reward,
            name: name.text,
            cost: parsedCost,
          );
    }
    name.dispose();
    cost.dispose();
  }

  Future<void> _confirmRedemption(
    BuildContext context,
    WidgetRef ref,
    ParentReward reward,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valider cette récompense ?'),
        content: Text(
          '${reward.name} coûtera exactement ${reward.cost} Éclats.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref
        .read(parentRewardActionProvider.notifier)
        .redeem(reward);
    if (!context.mounted) return;
    final message = result == ParentRewardRedemptionResult.insufficientBalance
        ? 'Le solde est insuffisant. Aucun Éclat n’a été débité.'
        : result == ParentRewardRedemptionResult.redeemed
        ? 'La récompense a été validée.'
        : 'Cette récompense a déjà été traitée ou n’est plus disponible.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
