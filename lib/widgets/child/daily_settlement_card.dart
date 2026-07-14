import 'package:flutter/material.dart';

import '../../models/daily_settlement.dart';

class DailySettlementCard extends StatelessWidget {
  const DailySettlementCard({
    super.key,
    required this.settlement,
    required this.onClose,
  });

  final DailySettlement settlement;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final rewarded = settlement.totalReward > 0;
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .96),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 18),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rewarded
                        ? 'Hier, ta Lumière a grandi grâce à tes petits pas.'
                        : 'Chaque petit pas compte. Aujourd’hui, on recommence tranquillement.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF33465C),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Fermer',
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Text('Progression : +${settlement.progressReward} Éclats'),
            if (settlement.gentleSupportBonus > 0)
              Text(
                'Moments de courage : +${settlement.gentleSupportBonus} Éclats',
              ),
            const SizedBox(height: 4),
            Text(
              'Total : ${settlement.totalReward} Éclats',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
