import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/moment_model.dart';
import '../models/routine_model.dart';
import '../providers/routines_provider.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/boussole_app_bar.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/info_tile.dart';
import '../widgets/common/loading_card.dart';

class MomentRoutinesPage extends ConsumerWidget {
  const MomentRoutinesPage({super.key, required this.moment});

  final MomentModel moment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routinesForMomentProvider(moment));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BoussoleAppBar(title: moment.name),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text("Routines du moment", style: AppTextStyles.h3),
            const SizedBox(height: 16),
            routinesAsync.when(
              loading: () => const LoadingCard(),
              error: (error, stackTrace) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: "Impossible de charger les routines.",
                message: error.toString(),
              ),
              data: (routines) {
                if (routines.isEmpty) {
                  return AppCard(
                    child: Column(
                      children: [
                        const EmptyState(
                          icon: Icons.checklist_rounded,
                          title: "Aucune routine",
                          message:
                              "Ajoutez une routine pour guider ce moment pas à pas.",
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _showRoutineDialog(context, ref),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text("Ajouter une routine"),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: routines.length,
                      onReorderItem: (oldIndex, newIndex) {
                        final reorderedRoutines = [...routines];
                        final movedRoutine = reorderedRoutines.removeAt(
                          oldIndex,
                        );

                        reorderedRoutines.insert(newIndex, movedRoutine);

                        ref
                            .read(routineOrderProvider.notifier)
                            .reorderRoutines(
                              moment: moment,
                              routines: reorderedRoutines,
                            );
                      },
                      itemBuilder: (context, index) {
                        final routine = routines[index];

                        return AppCard(
                          key: ValueKey(routine.id),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: InfoTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.checklist_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            title: routine.name,
                            subtitle: routine.active
                                ? "Routine active"
                                : "Routine inactive",
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: "Étapes",
                                  icon: const Icon(
                                    Icons.format_list_numbered_rounded,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () {
                                    context.push(
                                      '/routine-steps',
                                      extra: routine,
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: "Modifier",
                                  icon: const Icon(Icons.edit_rounded),
                                  onPressed: () => _showRoutineDialog(
                                    context,
                                    ref,
                                    routine: routine,
                                  ),
                                ),
                                IconButton(
                                  tooltip: "Dupliquer",
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () =>
                                      _duplicateRoutine(context, ref, routine),
                                ),
                                IconButton(
                                  tooltip: "Supprimer",
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _confirmDeleteRoutine(
                                    context,
                                    ref,
                                    routine,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _showRoutineDialog(context, ref),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text("Ajouter une routine"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRoutineDialog(
    BuildContext context,
    WidgetRef ref, {
    RoutineModel? routine,
  }) async {
    final nameController = TextEditingController(text: routine?.name ?? '');
    var icon = routine?.icon ?? 'checklist';
    var active = routine?.active ?? true;

    final result = await showDialog<_RoutineFormResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                routine == null ? "Ajouter une routine" : "Modifier la routine",
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nom de la routine",
                        prefixIcon: Icon(Icons.edit_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: icon,
                      decoration: const InputDecoration(
                        labelText: "Icône",
                        prefixIcon: Icon(Icons.image_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'checklist',
                          child: Text("Liste"),
                        ),
                        DropdownMenuItem(
                          value: 'morning',
                          child: Text("Matin"),
                        ),
                        DropdownMenuItem(value: 'meal', child: Text("Repas")),
                        DropdownMenuItem(
                          value: 'homework',
                          child: Text("Devoirs"),
                        ),
                        DropdownMenuItem(value: 'sleep', child: Text("Soir")),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          icon = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Routine active"),
                      value: active,
                      onChanged: (value) {
                        setState(() {
                          active = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Annuler"),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      return;
                    }

                    Navigator.of(context).pop(
                      _RoutineFormResult(
                        name: name,
                        icon: icon,
                        active: active,
                      ),
                    );
                  },
                  child: const Text("Enregistrer"),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();

    if (result == null || !context.mounted) {
      return;
    }

    if (routine == null) {
      await ref
          .read(routineCreationProvider.notifier)
          .createRoutine(moment: moment, name: result.name, icon: result.icon);
    } else {
      await ref
          .read(routineUpdateProvider.notifier)
          .updateRoutine(
            moment: moment,
            routine: routine.copyWith(
              name: result.name,
              icon: result.icon,
              active: result.active,
            ),
          );
    }

    if (!context.mounted) {
      return;
    }

    final actionState = routine == null
        ? ref.read(routineCreationProvider)
        : ref.read(routineUpdateProvider);

    if (actionState.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(actionState.error.toString())));
    }
  }

  Future<void> _duplicateRoutine(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
  ) async {
    await ref
        .read(routineDuplicationProvider.notifier)
        .duplicateRoutine(moment: moment, routine: routine);

    if (!context.mounted) {
      return;
    }

    final duplicationState = ref.read(routineDuplicationProvider);

    if (duplicationState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(duplicationState.error.toString())),
      );
    }
  }

  Future<void> _confirmDeleteRoutine(
    BuildContext context,
    WidgetRef ref,
    RoutineModel routine,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer cette routine ?"),
          content: Text(
            "La routine \"${routine.name}\" sera retirée de ce moment.",
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
        .read(routineDeletionProvider.notifier)
        .deleteRoutine(moment: moment, routineId: routine.id);

    if (!context.mounted) {
      return;
    }

    final deletionState = ref.read(routineDeletionProvider);

    if (deletionState.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(deletionState.error.toString())));
    }
  }
}

class _RoutineFormResult {
  const _RoutineFormResult({
    required this.name,
    required this.icon,
    required this.active,
  });

  final String name;
  final String icon;
  final bool active;
}
