import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/session_provider.dart';
import '../common/app_card.dart';
import 'parent_avatar.dart';

class GreetingCard extends ConsumerWidget {
  const GreetingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    final firstName = session?.firstName ?? 'Parent';

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour 👋', style: AppTextStyles.small),
                const SizedBox(height: 8),
                Text(firstName, style: AppTextStyles.h2),
                const SizedBox(height: 12),
                Text(
                  'Ton Gardien t’attend.\nAujourd’hui est une nouvelle aventure.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          ParentAvatar(avatar: session?.avatar),
        ],
      ),
    );
  }
}
