import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../models/child_model.dart';
import '../models/guardian_model.dart';
import '../models/guardian_experience_state.dart';
import '../models/secret_mission.dart';
import '../providers/active_child_provider.dart';
import '../providers/children_provider.dart';
import '../providers/device_mode_provider.dart';
import '../providers/guardian_provider.dart';
import '../providers/guardian_experience_provider.dart';
import '../providers/parent_access_provider.dart';
import '../providers/mission_provider.dart';
import '../providers/progress_light_provider.dart';
import '../widgets/child/house_guardian.dart';
import '../widgets/child/guardian_choices_panel.dart';
import '../widgets/child/house_navigation.dart';
import '../widgets/child/parent_access_gesture.dart';
import '../widgets/child/shards_balance_badge.dart';
import '../widgets/child/progress_light_bar.dart';
import '../widgets/child/daily_settlement_card.dart';
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

class _HouseContent extends ConsumerWidget {
  const _HouseContent({required this.child});

  final ChildModel child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardian =
        ref.watch(childGuardianProvider(child.id)).valueOrNull ??
        GuardianModel.all.first;
    final experience = ref.watch(guardianExperienceProvider(child.id));
    final mission = ref.watch(childSecretMissionProvider(child.id)).valueOrNull;
    final light = ref.watch(dailyLightSummaryProvider(child.id)).valueOrNull;
    final settlementState = ref.watch(dailySettlementProvider(child.id));
    final settlements = settlementState.valueOrNull ?? const [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailySettlementProvider(child.id).notifier).settlePending();
      if (settlements.isNotEmpty &&
          ref
              .read(dailySettlementProvider(child.id).notifier)
              .takeRecapAnnouncement()) {
        final latest = settlements.last;
        final message = latest.totalReward > 0
            ? 'Ta Lumière a grandi grâce à tous tes petits pas.'
            : 'Chaque petit pas compte. On avance tranquillement.';
        ref
            .read(guardianExperienceProvider(child.id).notifier)
            .showDailyRecap(message, celebrate: latest.totalReward > 0);
      }
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.houseBackground,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final board = _boardPlacement(
              constraints.biggest,
              MediaQuery.paddingOf(context).top,
            );
            return SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 52, 14, 76),
                      child: Column(
                        children: [
                          Expanded(
                            child: HouseGuardian(
                              guardian: guardian,
                              pose: experience.pose,
                              onTap: () => ref
                                  .read(
                                    guardianExperienceProvider(
                                      child.id,
                                    ).notifier,
                                  )
                                  .talk(),
                            ),
                          ),
                          if (experience.showChoices) ...[
                            GuardianChoicesPanel(
                              secretMission:
                                  experience.choiceKind ==
                                  GuardianChoiceKind.secretMission,
                              onFirstChoice: () {
                                ref
                                    .read(
                                      guardianExperienceProvider(
                                        child.id,
                                      ).notifier,
                                    )
                                    .closeChoices();
                                if (experience.choiceKind ==
                                        GuardianChoiceKind.secretMission &&
                                    mission != null) {
                                  context.push(
                                    '/child/${child.id}/secret-mission/${mission.id}',
                                  );
                                } else {
                                  context.push('/child/${child.id}/today');
                                }
                              },
                              onSecondChoice: () {
                                ref
                                    .read(
                                      guardianExperienceProvider(
                                        child.id,
                                      ).notifier,
                                    )
                                    .closeChoices();
                                if (experience.choiceKind ==
                                    GuardianChoiceKind.navigation) {
                                  context.push('/child/${child.id}/findings');
                                }
                              },
                              onClose: () => ref
                                  .read(
                                    guardianExperienceProvider(
                                      child.id,
                                    ).notifier,
                                  )
                                  .closeChoices(),
                            ),
                            const SizedBox(height: 6),
                          ],
                          _GuardianDialogueBubble(
                            message: experience.message,
                            onChoices: experience.isSleeping
                                ? null
                                : () => ref
                                      .read(
                                        guardianExperienceProvider(
                                          child.id,
                                        ).notifier,
                                      )
                                      .showChoices(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 2,
                    child: Center(
                      child: ParentAccessGesture(
                        child: SizedBox(
                          width: 210,
                          height: 80,
                          child: Center(
                            child: Image.asset(
                              AppAssets.logo,
                              width: 176,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: board.left,
                    top: board.top,
                    width: board.width,
                    height: board.height,
                    child: HouseTodayAction(
                      onTap: () => context.push('/child/${child.id}/today'),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: ShardsBalanceBadge(childId: child.id),
                  ),
                  if (light != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 120,
                      child: Center(child: ProgressLightBar(summary: light)),
                    ),
                  if (mission != null &&
                      mission.status == SecretMissionStatus.available &&
                      !experience.isSleeping)
                    Positioned(
                      left: 8,
                      top: 112,
                      child: ActionChip(
                        avatar: const Icon(Icons.lock_rounded, size: 17),
                        label: const Text('Mission Secrète'),
                        onPressed: () => ref
                            .read(guardianExperienceProvider(child.id).notifier)
                            .showSecretMission(),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 4,
                    child: HouseNavigation(
                      onOpenFindings: () =>
                          context.push('/child/${child.id}/findings'),
                      onOpenSharedMoments: () =>
                          context.push('/child/${child.id}/shared-moments'),
                      onChangeGuardian: () =>
                          context.push('/child/${child.id}/guardian'),
                    ),
                  ),
                  if (settlements.isNotEmpty)
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 82,
                      child: Center(
                        child: DailySettlementCard(
                          settlement: settlements.last,
                          onClose: () => ref
                              .read(dailySettlementProvider(child.id).notifier)
                              .consumeRecap(),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  _BoardPlacement _boardPlacement(Size viewport, double safeAreaTop) {
    const sourceSize = Size(853, 1843);
    final scale = math.max(
      viewport.width / sourceSize.width,
      viewport.height / sourceSize.height,
    );
    final renderedWidth = sourceSize.width * scale;
    final renderedHeight = sourceSize.height * scale;
    final cropX = (renderedWidth - viewport.width) / 2;
    final cropY = (renderedHeight - viewport.height) / 2;
    final width = (130 * scale).clamp(58.0, 150.0).toDouble();
    final height = (390 * scale).clamp(152.0, 390.0).toDouble();

    return _BoardPlacement(
      left: (705 * scale - cropX).clamp(8.0, viewport.width - width - 8),
      top: (445 * scale - cropY - safeAreaTop).clamp(
        60.0,
        viewport.height - height - 90,
      ),
      width: width,
      height: height,
    );
  }
}

class _GuardianDialogueBubble extends StatelessWidget {
  const _GuardianDialogueBubble({
    required this.message,
    required this.onChoices,
  });

  final String message;
  final VoidCallback? onChoices;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: -5,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F1FF).withValues(alpha: .94),
                border: Border.all(color: const Color(0xFFD6C9E8), width: .7),
              ),
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 350),
          padding: const EdgeInsets.fromLTRB(15, 7, 7, 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F1FF).withValues(alpha: .94),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6C9E8), width: .8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3E4660),
                    fontSize: 12,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onChoices != null) ...[
                const SizedBox(width: 3),
                IconButton(
                  tooltip: 'Que souhaites-tu faire ?',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 17,
                    color: Color(0xFF76679B),
                  ),
                  onPressed: onChoices,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BoardPlacement {
  const _BoardPlacement({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}
