import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/rewards_provider.dart';

class ShardsBalanceBadge extends ConsumerWidget {
  const ShardsBalanceBadge({
    super.key,
    required this.childId,
    this.dark = false,
  });
  final String childId;
  final bool dark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(shardWalletProvider(childId));
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: (dark ? const Color(0xFF26384D) : Colors.white).withValues(
          alpha: .88,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFFFC85C),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            wallet.when(
              data: (value) => '${value.balance}',
              loading: () => '…',
              error: (_, _) => '—',
            ),
            style: TextStyle(
              color: dark ? Colors.white : const Color(0xFF33465C),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Éclats',
            style: TextStyle(
              color: dark ? Colors.white70 : const Color(0xFF5D6B7B),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
