import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/rewards_provider.dart';

class RewardAnnouncementCard extends ConsumerWidget {
  const RewardAnnouncementCard({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(
      pendingRewardAnnouncementsProvider(childId),
    );
    final announcement = announcements.valueOrNull?.firstOrNull;
    if (announcement == null) return const SizedBox.shrink();
    return Material(
      elevation: 16,
      borderRadius: BorderRadius.circular(24),
      color: const Color(0xFFF7F1FF),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_rounded, size: 38),
            const SizedBox(height: 10),
            Text(
              'Bonne nouvelle ! Tes parents ont validé ta récompense : ${announcement.rewardName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Elle a coûté ${announcement.cost} Éclats. Il te reste maintenant ${announcement.remainingBalance} Éclats.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref
                  .read(parentRewardActionProvider.notifier)
                  .markAnnouncementDelivered(announcement),
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}
