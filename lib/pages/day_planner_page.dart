import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../models/moment_model.dart';
import '../providers/moments_provider.dart';
import '../widgets/common/boussole_app_bar.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';
import '../widgets/common/moment_card.dart';

class DayPlannerPage extends ConsumerWidget {
  const DayPlannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momentsAsync = ref.watch(momentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BoussoleAppBar(title: "Planning familial"),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
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
                  onReorderItem: (oldIndex, newIndex) {
                    final reorderedMoments = [...activeMoments];
                    final movedMoment = reorderedMoments.removeAt(oldIndex);

                    reorderedMoments.insert(newIndex, movedMoment);

                    ref
                        .read(momentOrderProvider.notifier)
                        .reorderMoments(reorderedMoments);
                  },
                  itemBuilder: (context, index) {
                    final moment = activeMoments[index];

                    return Padding(
                      key: ValueKey(moment.id),
                      padding: const EdgeInsets.only(bottom: 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final useCompactActions = constraints.maxWidth < 360;
                          final actions = [
                            _MomentActionButton(
                              tooltip: "Routine",
                              icon: Icons.checklist_rounded,
                              color: AppColors.primary,
                              onPressed: () {
                                context.push('/moment-routines', extra: moment);
                              },
                            ),
                            _MomentActionButton(
                              tooltip: "Dupliquer",
                              icon: Icons.copy_rounded,
                              color: AppColors.primary,
                              onPressed: () {
                                _duplicateMoment(context, ref, moment);
                              },
                            ),
                            _MomentActionButton(
                              tooltip: "Supprimer",
                              icon: Icons.delete_outline_rounded,
                              color: AppColors.error,
                              onPressed: () {
                                _confirmDeleteMoment(context, ref, moment);
                              },
                            ),
                          ];

                          return Row(
                            crossAxisAlignment: useCompactActions
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: MomentCard(
                                  title: moment.name,
                                  subtitle: _momentSubtitle(moment),
                                  image: _momentImage(moment.iconKey),
                                  color: _momentColor(moment.colorKey),
                                  onTap: () {
                                    context.push('/edit-moment', extra: moment);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (useCompactActions)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    actions[0],
                                    const SizedBox(height: 10),
                                    actions[1],
                                    const SizedBox(height: 10),
                                    actions[2],
                                  ],
                                )
                              else
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    actions[0],
                                    const SizedBox(width: 10),
                                    actions[1],
                                    const SizedBox(width: 10),
                                    actions[2],
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 8),

            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () {
                  context.push('/select-moment');
                },
                child: Ink(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: .20),
                      width: 2,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 30,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Ajouter un moment",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MomentActionButton extends StatelessWidget {
  const _MomentActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          tooltip: tooltip,
          icon: Icon(icon, color: color),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

Future<void> _duplicateMoment(
  BuildContext context,
  WidgetRef ref,
  MomentModel moment,
) async {
  await ref.read(momentDuplicationProvider.notifier).duplicateMoment(moment);

  if (!context.mounted) {
    return;
  }

  final duplicationState = ref.read(momentDuplicationProvider);

  if (duplicationState.hasError) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(duplicationState.error.toString())));
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

String _momentSubtitle(MomentModel moment) {
  if (moment.hasRoutine) {
    return "Routine quotidienne";
  }

  switch (moment.type) {
    case 'meal':
      return "Repas";
    case 'school':
      return "Travail scolaire";
    case 'leisure':
      return "Moment détente";
    case 'routine':
      return "Routine quotidienne";
    default:
      return "Moment";
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
    case 'meal':
      return AppAssets.meal;
    case 'homework':
      return AppAssets.homework;
    case 'householdTasks':
      return AppAssets.householdTasks;
    case 'videoGames':
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

Color _momentColor(String colorKey) {
  switch (colorKey) {
    case 'momentMorning':
      return AppColors.momentMorning;
    case 'momentMeal':
      return AppColors.momentMeal;
    case 'momentSchool':
      return AppColors.momentSchool;
    case 'momentLeisure':
      return AppColors.momentLeisure;
    case 'momentEvening':
      return AppColors.momentEvening;
    case 'momentHygiene':
      return AppColors.momentHygiene;
    default:
      return AppColors.primary;
  }
}
