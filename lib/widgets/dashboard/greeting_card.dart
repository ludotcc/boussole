import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/family_provider.dart';

class GreetingCard extends ConsumerWidget {
  const GreetingCard({super.key, this.actions = const []});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(currentFamilyProvider).valueOrNull;
    final familyName = family?.name.trim();

    return Container(
      constraints: const BoxConstraints(minHeight: 204),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .38),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: .72)),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: .10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour la famille',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color.fromARGB(255, 47, 57, 78),
                        height: 1.08,
                      ),
                    ),
                    if (familyName != null && familyName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        familyName,
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.08,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      'On prépare une belle journée.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'assets/images/backgrounds/background_accueil.png',
                    height: 192,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: Row(mainAxisSize: MainAxisSize.min, children: actions),
            ),
        ],
      ),
    );
  }
}
