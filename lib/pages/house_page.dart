import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../models/child_model.dart';
import '../models/companion_moment.dart';
import '../models/companion_observation.dart';
import '../models/guardian_model.dart';
import '../models/guardian_experience_state.dart';
import '../models/secret_mission.dart';
import '../providers/active_child_provider.dart';
import '../providers/companion_provider.dart';
import '../providers/children_provider.dart';
import '../providers/device_mode_provider.dart';
import '../providers/guardian_provider.dart';
import '../providers/guardian_experience_provider.dart';
import '../providers/parent_access_provider.dart';
import '../providers/mission_provider.dart';
import '../providers/progress_light_provider.dart';
import '../widgets/child/house_guardian.dart';
import '../widgets/child/companion_ideas_panel.dart';
import '../widgets/child/guardian_choices_panel.dart';
import '../widgets/child/house_navigation.dart';
import '../widgets/child/parent_access_gesture.dart';
import '../widgets/child/shards_balance_badge.dart';
import '../widgets/child/progress_light_bar.dart';
import '../widgets/child/daily_settlement_card.dart';
import '../widgets/child/child_rewards_panel.dart';
import '../widgets/child/reward_announcement_card.dart';
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

final _childRewardsPanelProvider = StateProvider.family<bool, String>(
  (ref, childId) => false,
);

class _HouseContent extends ConsumerWidget {
  const _HouseContent({required this.child});

  final ChildModel child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardian =
        ref.watch(childGuardianProvider(child.id)).valueOrNull ??
        GuardianModel.fromStorageId('wave', fallback: GuardianId.wave);
    final experience = ref.watch(guardianExperienceProvider(child.id));
    final mission = ref.watch(childSecretMissionProvider(child.id)).valueOrNull;
    final light = ref.watch(dailyLightSummaryProvider(child.id)).valueOrNull;
    final settlementState = ref.watch(dailySettlementProvider(child.id));
    final settlements = settlementState.valueOrNull ?? const [];
    final companionAsync = ref.watch(
      childCompanionExperienceProvider(child.id),
    );
    final showRewards = ref.watch(_childRewardsPanelProvider(child.id));

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

    return PopScope(
      canPop: !experience.showChoices,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !experience.showChoices) return;
        if (experience.choiceKind == GuardianChoiceKind.navigation) {
          _closeCompanion(
            ref,
            child.id,
            companionAsync.valueOrNull?.suggestions.ideas ?? const [],
          );
        } else {
          ref
              .read(guardianExperienceProvider(child.id).notifier)
              .closeChoices();
        }
      },
      child: Stack(
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
              return SafeArea(
                child: Stack(
                  children: [
                    if (light != null)
                      Positioned(
                        right: 8,
                        top: 78,
                        child: FractionalTranslation(
                          translation: const Offset(0, .5),
                          child: IgnorePointer(
                            child: ProgressLightBar(summary: light),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 52, 14, 76),
                        child: Column(
                          children: [
                            Expanded(
                              flex: experience.showChoices ? 1 : 3,
                              child: HouseGuardian(
                                guardian: guardian,
                                pose: experience.pose,
                                onTap: () => ref
                                    .read(
                                      guardianExperienceProvider(
                                        child.id,
                                      ).notifier,
                                    )
                                    .openCompanion(),
                              ),
                            ),
                            if (experience.showChoices) ...[
                              if (experience.choiceKind ==
                                  GuardianChoiceKind.secretMission)
                                GuardianChoicesPanel(
                                  secretMission: true,
                                  onFirstChoice: () {
                                    ref
                                        .read(
                                          guardianExperienceProvider(
                                            child.id,
                                          ).notifier,
                                        )
                                        .closeChoices();
                                    if (mission != null) {
                                      context.push(
                                        '/child/${child.id}/secret-mission/${mission.id}',
                                      );
                                    }
                                  },
                                  onSecondChoice: () => ref
                                      .read(
                                        guardianExperienceProvider(
                                          child.id,
                                        ).notifier,
                                      )
                                      .closeChoices(),
                                  onClose: () => ref
                                      .read(
                                        guardianExperienceProvider(
                                          child.id,
                                        ).notifier,
                                      )
                                      .closeChoices(),
                                )
                              else
                                Flexible(
                                  flex: 3,
                                  child: companionAsync.when(
                                    loading: () => const LoadingCard(),
                                    error: (error, _) => const EmptyState(
                                      icon: Icons.error_outline_rounded,
                                      title: 'Oups',
                                      message:
                                          'Je n’arrive pas à préparer mes idées.',
                                    ),
                                    data: (companion) => CompanionIdeasPanel(
                                      experience: companion,
                                      onIdeasShown: (ideas) => _recordDisplayed(
                                        ref,
                                        child.id,
                                        ideas,
                                      ),
                                      onCelebrationDismissed: (celebration) =>
                                          ref
                                              .read(
                                                celebrationDeliveryProvider
                                                    .notifier,
                                              )
                                              .markDelivered(celebration),
                                      onMissionAnnouncementDismissed:
                                          (mission) => ref
                                              .read(
                                                missionAnnouncementDeliveryProvider
                                                    .notifier,
                                              )
                                              .markDelivered(mission),
                                      onIdeaConfirmed: (idea) => _confirmIdea(
                                        ref,
                                        child.id,
                                        idea,
                                        companion.suggestions.ideas,
                                      ),
                                      onNewIdeas: () => _requestMoreIdeas(
                                        ref,
                                        child.id,
                                        companion.suggestions.ideas,
                                      ),
                                      onMyDay: () {
                                        _ignoreIdeas(
                                          ref,
                                          child.id,
                                          companion.suggestions.ideas,
                                        );
                                        context.push(
                                          '/child/${child.id}/today',
                                        );
                                      },
                                      onClose: () => _closeCompanion(
                                        ref,
                                        child.id,
                                        companion.suggestions.ideas,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 6),
                            ],
                            if (!experience.showChoices)
                              _GuardianDialogueBubble(
                                message: experience.message,
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
                      right: 8,
                      top: 8,
                      child: ShardsBalanceBadge(
                        childId: child.id,
                        onTap: () =>
                            ref
                                    .read(
                                      _childRewardsPanelProvider(
                                        child.id,
                                      ).notifier,
                                    )
                                    .state =
                                true,
                      ),
                    ),
                    if (mission != null &&
                        mission.status == SecretMissionStatus.available &&
                        !experience.isSleeping)
                      Positioned(
                        left: 8,
                        top: 88,
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          avatar: const Icon(Icons.lock_rounded, size: 17),
                          label: const Text('Mission Secrète'),
                          onPressed: () => ref
                              .read(
                                guardianExperienceProvider(child.id).notifier,
                              )
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
                                .read(
                                  dailySettlementProvider(child.id).notifier,
                                )
                                .consumeRecap(),
                          ),
                        ),
                      ),
                    if (showRewards)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black26,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 420,
                                ),
                                child: ChildRewardsPanel(
                                  childId: child.id,
                                  onClose: () =>
                                      ref
                                              .read(
                                                _childRewardsPanelProvider(
                                                  child.id,
                                                ).notifier,
                                              )
                                              .state =
                                          false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 92,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: RewardAnnouncementCard(childId: child.id),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _interactionSessionId(String childId) {
    final now = DateTime.now();
    return 'house_${childId}_${now.year}-${now.month}-${now.day}-${now.hour}';
  }

  void _recordDisplayed(
    WidgetRef ref,
    String childId,
    List<CompanionMoment> ideas,
  ) {
    ref
        .read(companionIdeaSessionProvider(childId).notifier)
        .recordDisplayed(ideas.map((idea) => idea.id).toList());
    unawaited(() async {
      for (final idea in ideas) {
        await ref
            .read(companionObservationNotifierProvider.notifier)
            .record(
              childId: childId,
              interactionSessionId: _interactionSessionId(childId),
              type: CompanionObservationType.displayed,
              momentId: idea.id,
            );
      }
    }());
  }

  void _confirmIdea(
    WidgetRef ref,
    String childId,
    CompanionMoment selected,
    List<CompanionMoment> displayed,
  ) {
    ref
        .read(companionIdeaSessionProvider(childId).notifier)
        .choose(selected.id, displayed.map((idea) => idea.id).toList());
    unawaited(() async {
      await ref
          .read(companionObservationNotifierProvider.notifier)
          .record(
            childId: childId,
            interactionSessionId: _interactionSessionId(childId),
            type: CompanionObservationType.chosen,
            momentId: selected.id,
          );
      await _recordRefused(
        ref,
        childId,
        displayed.where((idea) => idea.id != selected.id),
      );
    }());
    ref.read(guardianExperienceProvider(childId).notifier).closeChoices();
  }

  void _requestMoreIdeas(
    WidgetRef ref,
    String childId,
    List<CompanionMoment> ideas,
  ) {
    ref
        .read(companionIdeaSessionProvider(childId).notifier)
        .requestMore(ideas.map((idea) => idea.id).toList());
    unawaited(() async {
      await _recordRefused(ref, childId, ideas);
      await ref
          .read(companionObservationNotifierProvider.notifier)
          .record(
            childId: childId,
            interactionSessionId: _interactionSessionId(childId),
            type: CompanionObservationType.requestedMore,
            refreshSuggestions: true,
          );
    }());
  }

  void _ignoreIdeas(
    WidgetRef ref,
    String childId,
    List<CompanionMoment> ideas,
  ) {
    unawaited(_recordRefused(ref, childId, ideas));
  }

  void _closeCompanion(
    WidgetRef ref,
    String childId,
    List<CompanionMoment> ideas,
  ) {
    unawaited(() async {
      await _recordRefused(ref, childId, ideas);
      await ref
          .read(companionObservationNotifierProvider.notifier)
          .record(
            childId: childId,
            interactionSessionId: _interactionSessionId(childId),
            type: CompanionObservationType.closedWithoutChoice,
          );
    }());
    ref.read(guardianExperienceProvider(childId).notifier).closeChoices();
  }

  Future<void> _recordRefused(
    WidgetRef ref,
    String childId,
    Iterable<CompanionMoment> ideas,
  ) async {
    for (final idea in ideas) {
      await ref
          .read(companionObservationNotifierProvider.notifier)
          .record(
            childId: childId,
            interactionSessionId: _interactionSessionId(childId),
            type: CompanionObservationType.refused,
            momentId: idea.id,
          );
    }
  }
}

class _GuardianDialogueBubble extends StatelessWidget {
  const _GuardianDialogueBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        _HeightFactor(
          factor: 1.02,
          child: Container(
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeightFactor extends SingleChildRenderObjectWidget {
  const _HeightFactor({required this.factor, required super.child});

  final double factor;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeightFactor(factor);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderHeightFactor renderObject,
  ) {
    renderObject.factor = factor;
  }
}

class _RenderHeightFactor extends RenderShiftedBox {
  _RenderHeightFactor(this._factor) : super(null);

  double _factor;

  set factor(double value) {
    if (_factor == value) return;
    _factor = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(
      Size(child.size.width, child.size.height * _factor),
    );
    final childParentData = child.parentData! as BoxParentData;
    childParentData.offset = Offset(0, (size.height - child.size.height) / 2);
  }
}
