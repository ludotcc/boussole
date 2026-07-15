import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/rewards_provider.dart';

class ChildRewardsPanel extends ConsumerWidget {
  const ChildRewardsPanel({
    super.key,
    required this.childId,
    required this.onClose,
  });

  final String childId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(parentRewardsProvider(childId));
    final balance =
        ref.watch(shardWalletProvider(childId)).valueOrNull?.balance ?? 0;
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(24),
      color: const Color(0xFFFFFBF4),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mes récompenses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            rewards.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, _) =>
                  const Text('Impossible de voir les récompenses.'),
              data: (items) => items.isEmpty
                  ? const Text(
                      'Tes parents pourront préparer des récompenses ici.',
                    )
                  : Column(
                      children: [
                        for (final reward in items.take(5))
                          ListTile(
                            leading: Icon(
                              balance >= reward.cost
                                  ? Icons.auto_awesome_rounded
                                  : Icons.lock_outline_rounded,
                              color: balance >= reward.cost
                                  ? const Color(0xFFFFB743)
                                  : Colors.grey,
                            ),
                            title: Text(
                              reward.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text('${reward.cost} Éclats'),
                            trailing: Text(
                              balance >= reward.cost ? 'Assez' : 'Plus tard',
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: onClose, child: const Text('Fermer')),
          ],
        ),
      ),
    );
  }
}
