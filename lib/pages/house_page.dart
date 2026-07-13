import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../models/child_model.dart';
import '../providers/active_child_provider.dart';
import '../providers/children_provider.dart';
import '../providers/device_mode_provider.dart';
import '../providers/parent_access_provider.dart';
import '../widgets/child/house_navigation.dart';
import '../widgets/child/house_scene_placeholder.dart';
import '../widgets/child/parent_access_gesture.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';

class HousePage extends ConsumerWidget {
  const HousePage({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider);
    final configuration = ref.watch(deviceConfigurationProvider).valueOrNull;
    final parentAccess = ref.watch(parentAccessProvider);

    if (configuration?.isChildMode == true && !parentAccess.isLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(parentAccessProvider.notifier).lock();
      });
    }

    return Scaffold(
      body: childrenAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(24), child: LoadingCard()),
        error: (error, stackTrace) => const Padding(
          padding: EdgeInsets.all(24),
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Oups',
            message: 'Impossible d’ouvrir ta Maison pour le moment.',
          ),
        ),
        data: (children) {
          final child = _findChild(children);
          if (child == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                icon: Icons.child_care_rounded,
                title: 'Profil introuvable',
                message: 'Demande à un parent de vérifier cet appareil.',
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ref.read(activeChildProvider) != child.id) {
              ref.read(activeChildProvider.notifier).state = child.id;
            }
          });

          return _HouseContent(child: child);
        },
      ),
    );
  }

  ChildModel? _findChild(List<ChildModel> children) {
    for (final child in children) {
      if (child.id == childId) return child;
    }
    return null;
  }
}

class _HouseContent extends StatelessWidget {
  const _HouseContent({required this.child});

  final ChildModel child;

  String get _background {
    final hour = DateTime.now().hour;
    if (hour < 8) return AppAssets.backgroundSunrise;
    if (hour < 18) return AppAssets.backgroundMorning;
    return AppAssets.backgroundEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(_background, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: .12),
                const Color(0xFF22304A).withValues(alpha: .16),
              ],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ParentAccessGesture(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .88),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Image.asset(AppAssets.logo, width: 94, height: 42),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                HouseScenePlaceholder(childName: child.firstName),
                const SizedBox(height: 24),
                HouseNavigation(
                  onOpenToday: () => context.push('/child/${child.id}/today'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
