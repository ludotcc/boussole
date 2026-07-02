import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../providers/children_provider.dart';
import '../common/avatar_circle.dart';
import '../common/empty_state.dart';
import '../common/info_tile.dart';
import '../common/loading_card.dart';
import '../common/section_card.dart';

class ChildrenCard extends ConsumerWidget {
  const ChildrenCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider);

    return children.when(
      loading: () => const LoadingCard(),

      error: (error, stack) => SectionCard(
        title: 'Mes enfants',
        icon: Icons.child_care,
        accentColor: AppColors.turquoise,
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Une erreur est survenue',
          message: error.toString(),
        ),
      ),

      data: (list) {
        return SectionCard(
          title: 'Mes enfants',
          icon: Icons.child_care,
          accentColor: AppColors.turquoise,
          child: list.isEmpty
              ? const EmptyState(
                  icon: Icons.child_care,
                  title: 'Aucun enfant',
                  message: 'Ajoutez votre premier enfant.',
                )
              : Column(
                  children: [
                    ...list.map(
                      (child) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InfoTile(
                          leading: AvatarCircle(
                            imagePath: child.avatar,
                            radius: 22,
                          ),
                          title: child.firstName,
                          subtitle: '${child.age} ans',
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    const Divider(height: 28),

                    TextButton.icon(
                      onPressed: () {
                        // À connecter plus tard
                        // vers CreateChildPage.
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un enfant'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
