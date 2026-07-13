import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../core/constants/avatar_constants.dart';
import '../models/child_model.dart';
import '../providers/active_child_provider.dart';
import '../providers/children_provider.dart';
import '../providers/device_mode_provider.dart';
import '../providers/parent_access_provider.dart';
import '../widgets/child/parent_access_gesture.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';

class ChildSelectorPage extends ConsumerWidget {
  const ChildSelectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(deviceConfigurationProvider).valueOrNull;
    final childrenAsync = ref.watch(childrenProvider);
    final parentAccess = ref.watch(parentAccessProvider);

    if (configuration?.isChildMode == true && !parentAccess.isLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(parentAccessProvider.notifier).lock();
      });
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.backgroundBase02, fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ParentAccessGesture(
                    child: Image.asset(AppAssets.logo, width: 150, height: 64),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Qui rejoint sa Maison ?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF22304A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: childrenAsync.when(
                      loading: () => const LoadingCard(),
                      error: (error, stackTrace) => const EmptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'Oups',
                        message: 'Impossible de charger les profils.',
                      ),
                      data: (children) {
                        final allowed = configuration == null
                            ? const <ChildModel>[]
                            : children
                                  .where(
                                    (child) =>
                                        configuration.canOpenChild(child.id),
                                  )
                                  .toList();
                        if (allowed.isEmpty) {
                          return const EmptyState(
                            icon: Icons.child_care_rounded,
                            title: 'Aucun profil autorisé',
                            message:
                                'Un parent peut configurer cet appareil depuis les paramètres.',
                          );
                        }

                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisExtent: 190,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: allowed.length,
                          itemBuilder: (context, index) {
                            final child = allowed[index];
                            return _ChildProfileCard(
                              child: child,
                              onTap: () {
                                ref.read(activeChildProvider.notifier).state =
                                    child.id;
                                context.go('/child/${child.id}/house');
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildProfileCard extends StatelessWidget {
  const _ChildProfileCard({required this.child, required this.onTap});

  final ChildModel child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String avatar;
    try {
      avatar = AvatarConstants.assetFromId(child.avatar);
    } catch (_) {
      avatar = AppAssets.brother;
    }

    return Material(
      color: Colors.white.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Expanded(child: Image.asset(avatar, fit: BoxFit.contain)),
              const SizedBox(height: 10),
              Text(
                child.firstName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF22304A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
