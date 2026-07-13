import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/common/boussole_app_bar.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants/avatar_constants.dart';
import '../models/child_model.dart';
import '../models/child_day_item_model.dart';
import '../models/family_member_model.dart';
import '../providers/child_day_progress_provider.dart';
import '../providers/children_provider.dart';
import '../providers/moments_provider.dart';
import '../providers/routines_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/child/child_moment_card.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';
import 'child_avatar_picker_page.dart';
import 'child_routine_page.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key, this.childId});

  final String? childId;

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  bool _showCompletedDay = false;

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenProvider);
    final progress = ref.watch(childDayProgressProvider);
    final children = childrenAsync.valueOrNull;
    final selectedChild = _resolveChild(children);
    final appBarItemsAsync = selectedChild == null
        ? null
        : ref.watch(childDayItemsProvider(selectedChild.id));
    final appBarItemIds =
        appBarItemsAsync?.valueOrNull
            ?.where((item) => item.moment?.active ?? true)
            .map((item) => item.id)
            .toList() ??
        const <String>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BoussoleAppBar(
        title: 'Ma journée',
        fallbackLocation: selectedChild == null
            ? '/child-select'
            : '/child/${selectedChild.id}/house',

        actions: [
          if (selectedChild != null && (appBarItemsAsync?.hasValue ?? false))
            IconButton(
              tooltip: 'Recommencer',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _confirmResetDay(
                childId: selectedChild.id,
                itemIds: appBarItemIds,
              ),
            ),
        ],
      ),
      body: _ChildBackground(
        child: SafeArea(
          child: childrenAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: LoadingCard(),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Oups',
                message: 'Impossible de charger ton profil.',
              ),
            ),
            data: (children) {
              if (children.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: EmptyState(
                    icon: Icons.child_care_rounded,
                    title: 'Pas encore pret',
                    message: 'Ton profil apparaitra ici.',
                  ),
                );
              }

              final child = _resolveChild(children);
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
              final itemsAsync = ref.watch(childDayItemsProvider(child.id));
              final rhythmLabelAsync = ref.watch(
                childDayRhythmLabelProvider(child.id),
              );

              return itemsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: LoadingCard(),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Oups',
                    message: 'Impossible de charger ta journee.',
                  ),
                ),
                data: (items) {
                  final activeItems = items
                      .where((item) => item.moment?.active ?? true)
                      .toList();
                  final itemIds = activeItems.map((item) => item.id).toList();
                  final privilegeItems = activeItems
                      .where(
                        (item) =>
                            (item.moment?.isMultiUse ?? false) &&
                            !progress.isDismissed(item.id),
                      )
                      .toList();
                  final planningItems = activeItems
                      .where(
                        (item) =>
                            !(item.moment?.isMultiUse ?? false) &&
                            !progress.isDismissed(item.id),
                      )
                      .toList();
                  final planningItemIds = planningItems
                      .map((item) => item.id)
                      .toList();
                  final orderedPlanningItemIds = progress.childId == child.id
                      ? progress.orderedItemIds(planningItemIds)
                      : planningItemIds;
                  final planningItemsById = {
                    for (final item in planningItems) item.id: item,
                  };
                  final orderedPlanningItems = [
                    for (final itemId in orderedPlanningItemIds)
                      if (planningItemsById[itemId] != null)
                        planningItemsById[itemId]!,
                  ];
                  final orderedActiveItems = [
                    ...privilegeItems,
                    ...orderedPlanningItems,
                  ];

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref
                        .read(childDayProgressProvider.notifier)
                        .loadForToday(childId: child.id, momentIds: itemIds);
                  });

                  if (activeItems.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: EmptyState(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Rien de prevu',
                        message: 'Ton planning apparaitra ici.',
                      ),
                    );
                  }

                  final isDayComplete = activeItems.every(
                    (item) =>
                        _statusForItem(progress, item) ==
                        ChildMomentStatus.done,
                  );

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: isDayComplete
                        ? _showCompletedDay
                              ? _CompletedDayReview(
                                  key: const ValueKey('complete-review'),
                                  items: orderedActiveItems,
                                  onBackToBravo: () {
                                    setState(() {
                                      _showCompletedDay = false;
                                    });
                                  },
                                )
                              : _DayCompleteView(
                                  key: const ValueKey('complete'),
                                  childId: child.id,
                                  onViewDay: () {
                                    setState(() {
                                      _showCompletedDay = true;
                                    });
                                  },
                                )
                        : CustomScrollView(
                            key: const ValueKey('moments'),
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.all(24),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate([
                                    _TodayHeader(
                                      firstName: child.firstName,
                                      avatarId: child.avatar,
                                      onAvatarTap: () async {
                                        final updated = await Navigator.of(
                                          context,
                                        ).push<bool>(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ChildAvatarPickerPage(
                                                  member:
                                                      FamilyMemberModel.fromChild(
                                                        child,
                                                      ),
                                                ),
                                          ),
                                        );

                                        if (updated == true) {
                                          ref.invalidate(childrenProvider);
                                        }
                                      },
                                      rhythmLabel:
                                          rhythmLabelAsync.valueOrNull ?? '',
                                    ),
                                    const SizedBox(height: 18),
                                    if (privilegeItems.isNotEmpty) ...[
                                      _PrivilegesSection(
                                        children: [
                                          for (final item in privilegeItems)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 14,
                                              ),
                                              child: _DismissibleDoneMoment(
                                                childId: child.id,
                                                item: item,
                                                itemIds: itemIds,
                                                status: _statusForItem(
                                                  progress,
                                                  item,
                                                ),
                                                child: _TodayDayItem(
                                                  childId: child.id,
                                                  item: item,
                                                  itemIds: itemIds,
                                                  status: _statusForItem(
                                                    progress,
                                                    item,
                                                  ),
                                                  startedAt: progress
                                                      .startedAtFor(item.id),
                                                  compact: true,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 22),
                                    ],
                                  ]),
                                ),
                              ),

                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                sliver: SliverReorderableList(
                                  itemCount: orderedPlanningItems.length,
                                  autoScrollerVelocityScalar: 80,
                                  onReorderItem: (oldIndex, newIndex) {
                                    final reorderedItems = [
                                      ...orderedPlanningItems,
                                    ];

                                    final movedItem = reorderedItems.removeAt(
                                      oldIndex,
                                    );
                                    reorderedItems.insert(newIndex, movedItem);

                                    ref
                                        .read(childDayProgressProvider.notifier)
                                        .reorderTodayItems(
                                          childId: child.id,
                                          itemIds: reorderedItems
                                              .map((item) => item.id)
                                              .toList(),
                                          momentIds: itemIds,
                                        );
                                  },
                                  itemBuilder: (context, index) {
                                    final item = orderedPlanningItems[index];
                                    final status = _statusForItem(
                                      progress,
                                      item,
                                    );

                                    return ReorderableDelayedDragStartListener(
                                      key: ValueKey(item.id),
                                      index: index,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 18,
                                        ),
                                        child: _DismissibleDoneMoment(
                                          childId: child.id,
                                          item: item,
                                          itemIds: itemIds,
                                          status: status,
                                          child: _TodayDayItem(
                                            childId: child.id,
                                            item: item,
                                            itemIds: itemIds,
                                            status: status,
                                            startedAt: progress.startedAtFor(
                                              item.id,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),
                            ],
                          ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  ChildModel? _resolveChild(List<ChildModel>? children) {
    if (children == null || children.isEmpty) return null;
    if (widget.childId == null) return children.first;
    for (final child in children) {
      if (child.id == widget.childId) return child;
    }
    return null;
  }

  Future<void> _confirmResetDay({
    required String childId,
    required List<String> itemIds,
  }) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recommencer la journee ?'),
          content: const Text(
            'Les moments de ta journee vont revenir au debut, tranquillement.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Recommencer'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return;
    }

    await ref
        .read(childDayProgressProvider.notifier)
        .resetToday(childId: childId, momentIds: itemIds);

    if (!mounted) {
      return;
    }

    setState(() {
      _showCompletedDay = false;
    });
  }
}

class _ChildBackground extends StatelessWidget {
  const _ChildBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(AppAssets.backgroundBase03, fit: BoxFit.cover),
        Container(color: Colors.white.withValues(alpha: .18)),
        child,
      ],
    );
  }
}

ChildMomentStatus _statusForItem(
  ChildDayProgressState progress,
  ChildDayItemModel item,
) {
  final moment = item.moment;

  return progress.statusFor(
    item.id,
    isMultiUse: moment?.isMultiUse ?? false,
    maxDailyUses: moment?.maxDailyUses,
  );
}

class _TodayDayItem extends ConsumerWidget {
  const _TodayDayItem({
    required this.childId,
    required this.item,
    required this.itemIds,
    required this.status,
    required this.startedAt,
    this.compact = false,
  });

  final String childId;
  final ChildDayItemModel item;
  final List<String> itemIds;
  final ChildMomentStatus status;
  final DateTime? startedAt;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moment = item.moment;
    if (moment == null) {
      Future<void> startEvent() {
        return ref
            .read(childDayProgressProvider.notifier)
            .startMoment(
              childId: childId,
              momentId: item.id,
              momentIds: itemIds,
            );
      }

      Future<void> completeEvent() {
        return ref
            .read(childDayProgressProvider.notifier)
            .completeMoment(
              childId: childId,
              momentId: item.id,
              momentIds: itemIds,
            );
      }

      return ChildMomentCard(
        title: item.title,
        icon: _eventIcon(item.iconKey),
        color: _eventColor(item.colorKey ?? ''),
        status: status,
        todoLabel: item.isSensitive ? 'On avance ensemble.' : null,
        inProgressLabel: item.isSensitive ? 'On continue doucement' : null,
        childTimeDisplayType: item.childTimeDisplayType,
        timerMinutes: item.timerMinutes,
        maxDurationMinutes: item.maxDurationMinutes,
        endTime: item.endTime,
        startedAt: startedAt,
        isSensitive: item.isSensitive,
        compact: compact,
        onTap: startEvent,
        onStart: startEvent,
        onComplete: completeEvent,
      );
    }

    final routinesAsync = ref.watch(routinesForMomentProvider(moment));
    final remainingUses = ref
        .watch(childDayProgressProvider)
        .remainingUsesFor(
          momentId: item.id,
          isMultiUse: moment.isMultiUse,
          maxDailyUses: moment.maxDailyUses,
        );

    Future<void> startMoment() async {
      final progress = ref.read(childDayProgressProvider);
      final currentMomentId = progress.currentMomentId;

      if (currentMomentId != null && currentMomentId != item.id) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Changer de moment ?'),
              content: const Text(
                "Un autre moment est déjà en cours.\n\n"
                "Souhaites-tu l'arrêter et commencer celui-ci ?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Oui'),
                ),
              ],
            );
          },
        );

        if (confirmed != true) {
          return;
        }
      }

      if (!progress.canStart(
        momentId: item.id,
        isMultiUse: moment.isMultiUse,
        maxDailyUses: moment.maxDailyUses,
      )) {
        return;
      }

      final routines = routinesAsync.valueOrNull ?? [];

      if (routines.isNotEmpty) {
        await ref
            .read(childDayProgressProvider.notifier)
            .startMoment(
              childId: childId,
              momentId: item.id,
              momentIds: itemIds,
              isMultiUse: moment.isMultiUse,
              maxDailyUses: moment.maxDailyUses,
            );

        if (!context.mounted) {
          return;
        }

        context.push(
          '/child/$childId/routine',
          extra: ChildRoutinePageArgs(
            childId: childId,
            moment: moment,
            routine: routines.first,
            momentIds: itemIds,
          ),
        );
        return;
      }

      await ref
          .read(childDayProgressProvider.notifier)
          .startMoment(
            childId: childId,
            momentId: item.id,
            momentIds: itemIds,
            isMultiUse: moment.isMultiUse,
            maxDailyUses: moment.maxDailyUses,
          );
    }

    Future<void> completeMoment() {
      return ref
          .read(childDayProgressProvider.notifier)
          .completeMoment(
            childId: childId,
            momentId: item.id,
            momentIds: itemIds,
            isMultiUse: moment.isMultiUse,
            maxDailyUses: moment.maxDailyUses,
          );
    }

    void showGuidance() {
      final guidance = moment.guidanceText?.trim();
      if (guidance == null || guidance.isEmpty) {
        return;
      }

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(moment.name),
          content: Text(guidance),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }

    return ChildMomentCard(
      title: item.title,
      image: _momentImage(item.iconKey),
      color: AppColors.primary,
      status: status,
      todoLabel: item.isSensitive ? 'On avance ensemble.' : null,
      childTimeDisplayType: item.childTimeDisplayType,
      timerMinutes: item.timerMinutes,
      maxDurationMinutes: item.maxDurationMinutes,
      startedAt: startedAt,
      remainingUses: remainingUses,
      isSensitive: item.isSensitive,
      compact: compact,
      onImageTap: moment.guidanceText?.trim().isNotEmpty == true
          ? showGuidance
          : null,

      onStart: () {
        startMoment();
      },
      onComplete: () {
        completeMoment();
      },
    );
  }
}

class _DismissibleDoneMoment extends ConsumerWidget {
  const _DismissibleDoneMoment({
    required this.childId,
    required this.item,
    required this.itemIds,
    required this.status,
    required this.child,
  });

  final String childId;
  final ChildDayItemModel item;
  final List<String> itemIds;
  final ChildMomentStatus status;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!item.isMoment) {
      return child;
    }

    if (status == ChildMomentStatus.todo ||
        status == ChildMomentStatus.inProgress ||
        status == ChildMomentStatus.done) {
      final removalState = ref.watch(todayMomentRemovalProvider);

      return Dismissible(
        key: ValueKey('remove-${item.id}'),
        direction: removalState.isLoading
            ? DismissDirection.none
            : DismissDirection.horizontal,
        background: const _RemoveBackground(alignment: Alignment.centerLeft),
        secondaryBackground: const _RemoveBackground(
          alignment: Alignment.centerRight,
        ),
        confirmDismiss: (_) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Retirer ce moment ?'),
              content: const Text(
                'Il sera retiré seulement de ta journée d’aujourd’hui.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Garder'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Retirer'),
                ),
              ],
            ),
          );

          if (confirmed != true || !context.mounted) {
            return false;
          }

          await ref
              .read(todayMomentRemovalProvider.notifier)
              .remove(childId: childId, momentId: item.id);
          final result = ref.read(todayMomentRemovalProvider);

          if (result.hasError && context.mounted) {
            debugPrint(
              'Suppression du moment ${item.id} impossible: '
              '${result.error}\n${result.stackTrace}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ce moment est resté dans ta journée.'),
              ),
            );
            return false;
          }

          try {
            await ref
                .read(childDayProgressProvider.notifier)
                .forgetMoment(
                  childId: childId,
                  momentId: item.id,
                  momentIds: itemIds,
                );
          } catch (error, stackTrace) {
            debugPrint(
              'Nettoyage de progression après suppression impossible: '
              '$error\n$stackTrace',
            );
          }

          return false;
        },
        child: child,
      );
    }

    return child;
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.softOrange.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Icon(
        Icons.remove_circle_outline_rounded,
        color: AppColors.softOrange,
        size: 30,
      ),
    );
  }
}

class _PrivilegesSection extends StatelessWidget {
  const _PrivilegesSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFD59E)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB86B).withValues(alpha: .13),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFD4862B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Privilèges',
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DayCompleteView extends StatelessWidget {
  const _DayCompleteView({
    super.key,
    required this.childId,
    required this.onViewDay,
  });

  final String childId;
  final VoidCallback onViewDay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF0F8), Color(0xFFF1E7FF), Color(0xFFE6F3FF)],
        ),
      ),
      child: SizedBox.expand(
        child: Stack(
          children: [
            const Positioned(
              top: 44,
              left: 34,
              child: _SoftCompleteStar(size: 16),
            ),
            const Positioned(
              top: 96,
              right: 42,
              child: _SoftCompleteStar(size: 12),
            ),
            const Positioned(
              bottom: 138,
              left: 54,
              child: _SoftCompleteStar(size: 10),
            ),
            const Positioned(
              bottom: 86,
              right: 58,
              child: _SoftCompleteStar(size: 18),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppAssets.mascotWinner, height: 230),
                      const SizedBox(height: 26),
                      Text(
                        'Bravo, tu as terminé\nta journée !',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tu peux être fier de toi.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 34),
                      BoussoleButton(
                        text: 'Retour à l’accueil',
                        icon: Icons.home_rounded,
                        onPressed: () {
                          context.go('/child/$childId/house');
                        },
                      ),
                      const SizedBox(height: 14),
                      BoussoleButton(
                        text: 'Voir ma journée',
                        icon: Icons.list_alt_rounded,
                        isPrimary: false,
                        onPressed: onViewDay,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedDayReview extends StatelessWidget {
  const _CompletedDayReview({
    super.key,
    required this.items,
    required this.onBackToBravo,
  });

  final List<ChildDayItemModel> items;
  final VoidCallback onBackToBravo;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: items.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              BoussoleButton(
                text: 'Retour au bravo',
                icon: Icons.arrow_back_rounded,
                isPrimary: false,
                onPressed: onBackToBravo,
              ),
              const SizedBox(height: 18),
            ],
          );
        }

        final item = items[index - 1];

        return ChildMomentCard(
          title: item.title,
          image: item.isMoment ? _momentImage(item.iconKey) : null,
          icon: item.isEvent ? _eventIcon(item.iconKey) : null,
          color: item.isMoment
              ? AppColors.primary
              : _eventColor(item.colorKey ?? ''),
          status: ChildMomentStatus.done,
          isSensitive: item.isSensitive,
          readOnly: true,
          onStart: () {},
          onComplete: () {},
        );
      },
    );
  }
}

class _SoftCompleteStar extends StatelessWidget {
  const _SoftCompleteStar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: size,
      color: const Color(0xFF8B5CF6).withValues(alpha: .22),
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({
    required this.firstName,
    required this.avatarId,
    required this.rhythmLabel,
    required this.onAvatarTap,
  });

  final String firstName;
  final String avatarId;
  final String rhythmLabel;
  final VoidCallback onAvatarTap;

  String get _dateLabel {
    final now = DateTime.now();

    const weekdays = <int, String>{
      DateTime.monday: 'Lundi',
      DateTime.tuesday: 'Mardi',
      DateTime.wednesday: 'Mercredi',
      DateTime.thursday: 'Jeudi',
      DateTime.friday: 'Vendredi',
      DateTime.saturday: 'Samedi',
      DateTime.sunday: 'Dimanche',
    };

    const months = <int, String>{
      DateTime.january: 'Janvier',
      DateTime.february: 'Février',
      DateTime.march: 'Mars',
      DateTime.april: 'Avril',
      DateTime.may: 'Mai',
      DateTime.june: 'Juin',
      DateTime.july: 'Juillet',
      DateTime.august: 'Août',
      DateTime.september: 'Septembre',
      DateTime.october: 'Octobre',
      DateTime.november: 'Novembre',
      DateTime.december: 'Décembre',
    };

    final weekday = weekdays[now.weekday] ?? '';
    final month = months[now.month] ?? '';

    return '$weekday ${now.day} $month';
  }

  String get _rhythmMessage {
    final rhythm = rhythmLabel.trim().toLowerCase();

    if (rhythm.contains('école') || rhythm.contains('ecole')) {
      return "C'est une journée d'école";
    }

    if (rhythm.contains('mercredi')) {
      return "C'est mercredi";
    }

    if (rhythm.contains('week')) {
      return "C'est le week-end";
    }

    if (rhythm.contains('vacance')) {
      return "C'est les vacances";
    }

    return rhythmLabel.trim();
  }

  String _avatarAsset(String avatarId) {
    try {
      return AvatarConstants.assetFromId(avatarId);
    } catch (_) {
      return AppAssets.brother;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8B5CF6), Color(0xFFFF8CCB), Color(0xFF7CC7FF)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withValues(alpha: .22),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Modifier mon avatar',
                child: InkWell(
                  onTap: onAvatarTap,
                  borderRadius: BorderRadius.circular(34),
                  child: Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .26),
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(
                        _avatarAsset(avatarId),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour $firstName',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _dateLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (_rhythmMessage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _rhythmMessage,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: .92),
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const Positioned(top: 14, right: 22, child: _SoftStar(size: 16)),
        const Positioned(top: 42, right: 76, child: _SoftStar(size: 9)),
        const Positioned(bottom: 20, left: 24, child: _SoftStar(size: 11)),
      ],
    );
  }
}

class _SoftStar extends StatelessWidget {
  const _SoftStar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: size,
      color: Colors.white.withValues(alpha: .78),
    );
  }
}

String _momentImage(String iconKey) {
  switch (iconKey) {
    case 'routineMorning':
      return AppAssets.routineMorning;
    case 'routineEvening':
      return AppAssets.routineEvening;
    case 'breakfast':
      return AppAssets.breakfast;
    case 'lunch':
      return AppAssets.lunch;
    case 'dinner':
      return AppAssets.dinner;
    case 'family_care':
      return AppAssets.familyCare;
    case 'brush_teeth':
      return AppAssets.brushTeeth;
    case 'shopping':
      return AppAssets.shopping;
    case 'medication':
      return AppAssets.medication;
    case 'swimming':
      return AppAssets.swimming;
    case 'screen_time':
      return AppAssets.screenTime;
    case 'wake_up':
      return AppAssets.wakeUp;
    case 'sleep':
      return AppAssets.sleep;
    case 'nap':
      return AppAssets.nap;
    case 'divers':
      return AppAssets.divers;
    case 'homework':
      return AppAssets.homework;
    case 'school_bag':
      return AppAssets.schoolBag;
    case 'householdTasks':
      return AppAssets.householdTasks;
    case 'videoGames':
      return AppAssets.freeTime;
    case 'video_games':
      return AppAssets.videoGames;
    case 'freeTime':
      return AppAssets.freeTime;
    case 'bike':
      return AppAssets.bike;
    case 'bath':
      return AppAssets.bath;
    default:
      return AppAssets.routineMorning;
  }
}

IconData _eventIcon(String iconKey) {
  return switch (iconKey) {
    'sensitiveEvent' => Icons.auto_awesome_rounded,
    'healthEvent' => Icons.favorite_rounded,
    'schoolEvent' => Icons.school_rounded,
    'activityEvent' => Icons.sports_soccer_rounded,
    'birthdayEvent' => Icons.cake_rounded,
    'appointmentEvent' => Icons.event_available_rounded,
    _ => Icons.auto_awesome_rounded,
  };
}

Color _eventColor(String colorKey) {
  return switch (colorKey) {
    'eventSensitive' => const Color(0xFF9B8CFF),
    'eventHealth' => const Color(0xFFE87393),
    'eventSchool' => AppColors.primary,
    'eventActivity' => AppColors.turquoise,
    'eventBirthday' => AppColors.gold,
    'eventAppointment' => AppColors.softOrange,
    'eventFamily' => AppColors.violet,
    _ => AppColors.textSecondary,
  };
}
