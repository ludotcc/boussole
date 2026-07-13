import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants/avatar_constants.dart';
import '../models/child_model.dart';
import '../models/moment_model.dart';
import '../models/planning_day_kind.dart';
import '../providers/children_provider.dart';
import '../providers/moments_provider.dart';
import '../widgets/common/boussole_app_bar.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';
import '../widgets/common/moment_card.dart';

class DayPlannerPage extends ConsumerWidget {
  const DayPlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momentsAsync = ref.watch(selectedPlanningMomentsProvider);
    final childrenAsync = ref.watch(childrenProvider);
    final planningTarget = ref.watch(planningTargetProvider);
    final resetState = ref.watch(planningResetProvider);
    final hasSelectedChild = planningTarget.childId != null;

    childrenAsync.whenData((children) {
      final selectedChildExists = children.any(
        (child) => child.id == planningTarget.childId,
      );
      if (children.isEmpty && planningTarget.childId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(planningTargetProvider.notifier).state = PlanningTarget(
            dayKind: planningTarget.dayKind,
          );
        });
        return;
      }
      if (!selectedChildExists && children.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(planningTargetProvider.notifier).state = PlanningTarget(
            childId: children.first.id,
            dayKind: planningTarget.dayKind,
          );
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BoussoleAppBar(
        title: "Planning familial",
        actions: [
          TextButton(
            onPressed: resetState.isLoading || !hasSelectedChild
                ? null
                : () => _confirmResetPlanning(context, ref),
            child: const Text(
              'Réinitialiser',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.backgroundBase01, fit: BoxFit.cover),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                childrenAsync.maybeWhen(
                  data: (children) => _PlanningTargetSelector(
                    children: children,
                    target: planningTarget,
                    onChanged: (target) {
                      ref.read(planningTargetProvider.notifier).state = target;
                    },
                    onDayKindChanged: (dayKind) {
                      ref.read(planningTargetProvider.notifier).state =
                          planningTarget.copyWith(dayKind: dayKind);
                    },
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),

                const SizedBox(height: 16),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: hasSelectedChild
                        ? () {
                            context.push('/select-moment');
                          }
                        : null,
                    child: Ink(
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEAF6FF), Color(0xFFD3ECFF)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: const Color(0xFFB8DFFF),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF90CAF9).withValues(alpha: .20),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: Color(0xFF1976D2),
                            size: 30,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Ajouter un moment",
                            style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                momentsAsync.when(
                  loading: () => const LoadingCard(),
                  error: (error, stackTrace) => EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: "Impossible de charger les moments.",
                    message: error.toString(),
                  ),
                  data: (moments) {
                    final activeMoments = moments
                        .where((moment) => moment.active)
                        .toList();

                    if (activeMoments.isEmpty) {
                      return const EmptyState(
                        icon: Icons.calendar_today_rounded,
                        title: "Aucun moment",
                        message:
                            "Ajoutez un premier moment pour préparer le planning.",
                      );
                    }

                    return ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeMoments.length,
                      onReorderItem: hasSelectedChild
                          ? (oldIndex, newIndex) {
                              final reorderedMoments = [...activeMoments];
                              final movedMoment = reorderedMoments.removeAt(
                                oldIndex,
                              );

                              reorderedMoments.insert(newIndex, movedMoment);

                              ref
                                  .read(momentOrderProvider.notifier)
                                  .reorderMoments(reorderedMoments);
                            }
                          : null,
                      itemBuilder: (context, index) {
                        final moment = activeMoments[index];

                        return Padding(
                          key: ValueKey(moment.id),
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Stack(
                            children: [
                              MomentCard(
                                title: moment.name,
                                subtitle: _momentSubtitle(moment),
                                image: _momentImage(moment.iconKey),
                                color: AppColors.primary,
                                onTap: hasSelectedChild
                                    ? () {
                                        context.push(
                                          '/edit-moment',
                                          extra: moment,
                                        );
                                      }
                                    : null,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: _DeleteMomentButton(
                                  onPressed: hasSelectedChild
                                      ? () {
                                          _confirmDeleteMoment(
                                            context,
                                            ref,
                                            moment,
                                          );
                                        }
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteMomentButton extends StatelessWidget {
  const _DeleteMomentButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .92),
      shape: const CircleBorder(),
      child: SizedBox(
        width: 38,
        height: 38,
        child: IconButton(
          tooltip: "Supprimer",
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.error,
            size: 20,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _PlanningTargetSelector extends StatelessWidget {
  const _PlanningTargetSelector({
    required this.children,
    required this.target,
    required this.onChanged,
    required this.onDayKindChanged,
  });

  final List<ChildModel> children;
  final PlanningTarget target;
  final ValueChanged<PlanningTarget> onChanged;
  final ValueChanged<PlanningDayKind> onDayKindChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sélectionne ton enfant', style: AppTextStyles.cardTitle),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final child in children)
                _MemberAvatarChoice(
                  label: child.firstName,
                  avatarId: child.avatar,
                  selected: target.childId == child.id,
                  onTap: () => onChanged(
                    PlanningTarget(childId: child.id, dayKind: target.dayKind),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Quelle période souhaite tu modifier ?',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final dayKind in PlanningDayKind.values)
                ChoiceChip(
                  showCheckmark: false,
                  label: Text(dayKind.label),
                  selected: target.dayKind == dayKind,
                  onSelected: (_) => onDayKindChanged(dayKind),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberAvatarChoice extends StatelessWidget {
  const _MemberAvatarChoice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.avatarId,
  });

  final String label;
  final String? avatarId;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: .14)
                  : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : Colors.white,
                width: selected ? 3 : 1,
              ),
            ),
            child: avatarId == null
                ? const Icon(Icons.family_restroom_rounded, size: 34)
                : ClipOval(
                    child: Image.asset(
                      _avatarAsset(avatarId!),
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 76,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _avatarAsset(String avatarId) {
  try {
    return AvatarConstants.assetFromId(avatarId);
  } catch (_) {
    return AppAssets.brother;
  }
}

Future<void> _confirmDeleteMoment(
  BuildContext context,
  WidgetRef ref,
  MomentModel moment,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Supprimer ce moment ?"),
        content: Text(
          "Le moment \"${moment.name}\" sera retiré de l'organisation.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Supprimer"),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  await ref
      .read(momentDeletionProvider.notifier)
      .deleteMoment(momentId: moment.id);

  if (!context.mounted) {
    return;
  }

  final deletionState = ref.read(momentDeletionProvider);

  if (deletionState.hasError) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(deletionState.error.toString())));
  }
}

Future<void> _confirmResetPlanning(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Réinitialiser ce planning ?'),
      content: const Text('Seul le planning actuellement affiché sera vidé.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Réinitialiser'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  await ref.read(planningResetProvider.notifier).reset();
  final state = ref.read(planningResetProvider);

  if (state.hasError && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Le planning n’a pas été modifié.')),
    );
  }
}

String _momentSubtitle(MomentModel moment) {
  final orderTime = _formatOrderTime(moment.orderMinutes);
  final prefix = orderTime == null ? '' : '$orderTime · ';

  if (moment.hasRoutine) {
    return "${prefix}Routine quotidienne";
  }

  return orderTime ?? '';
}

String? _formatOrderTime(int? minutes) {
  if (minutes == null) {
    return null;
  }

  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');

  return '$hour:$minute';
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
