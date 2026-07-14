import 'package:flutter/material.dart';

import '../../models/finding_catalog_item.dart';

class FindingCard extends StatelessWidget {
  const FindingCard({
    super.key,
    required this.item,
    required this.owned,
    required this.canAfford,
    required this.busy,
    required this.onPurchase,
  });
  final FindingCatalogItem item;
  final bool owned;
  final bool canAfford;
  final bool busy;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final color = Color(item.colorValue);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(findingIcon(item.iconId), color: color, size: 27),
              ),
              const Spacer(),
              _RarityLabel(item.rarity),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2F4054),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7888),
              fontSize: 11,
              height: 1.2,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: owned || !canAfford || busy ? null : onPurchase,
              icon: Icon(
                owned ? Icons.check_rounded : Icons.auto_awesome_rounded,
                size: 16,
              ),
              label: Text(
                owned
                    ? 'Possédée'
                    : canAfford
                    ? '${item.price} Éclats'
                    : 'Solde insuffisant',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RarityLabel extends StatelessWidget {
  const _RarityLabel(this.rarity);
  final FindingRarity rarity;
  @override
  Widget build(BuildContext context) {
    final label = switch (rarity) {
      FindingRarity.common => 'Douce',
      FindingRarity.uncommon => 'Jolie',
      FindingRarity.rare => 'Rare',
    };
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF738091),
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

IconData findingIcon(String id) => switch (id) {
  'plant' => Icons.local_florist_rounded,
  'lamp' => Icons.light_rounded,
  'star' => Icons.star_rounded,
  'rug' => Icons.texture_rounded,
  'book' => Icons.auto_stories_rounded,
  'clock' => Icons.schedule_rounded,
  'mobile' => Icons.flare_rounded,
  'box' => Icons.inventory_2_rounded,
  'shelf' => Icons.shelves,
  'lantern' => Icons.emoji_objects_rounded,
  _ => Icons.auto_awesome_rounded,
};
