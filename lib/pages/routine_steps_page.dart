import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/routine_model.dart';
import '../models/step_model.dart';
import '../providers/steps_provider.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/boussole_app_bar.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/info_tile.dart';
import '../widgets/common/loading_card.dart';

class RoutineStepsPage extends ConsumerWidget {
  const RoutineStepsPage({super.key, required this.routine});

  final RoutineModel routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsAsync = ref.watch(stepsForRoutineProvider(routine));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BoussoleAppBar(title: routine.name),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text("Étapes de la routine", style: AppTextStyles.h3),
            const SizedBox(height: 16),
            stepsAsync.when(
              loading: () => const LoadingCard(),
              error: (error, stackTrace) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: "Impossible de charger les étapes.",
                message: error.toString(),
              ),
              data: (steps) {
                if (steps.isEmpty) {
                  return AppCard(
                    child: Column(
                      children: [
                        const EmptyState(
                          icon: Icons.format_list_numbered_rounded,
                          title: "Aucune étape",
                          message:
                              "Ajoutez une première étape pour construire cette routine.",
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _showStepDialog(context, ref),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text("Ajouter une étape"),
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
                      itemCount: steps.length,
                      onReorderItem: (oldIndex, newIndex) {
                        final reorderedSteps = [...steps];
                        final movedStep = reorderedSteps.removeAt(oldIndex);

                        reorderedSteps.insert(newIndex, movedStep);

                        ref
                            .read(stepOrderProvider.notifier)
                            .reorderSteps(
                              routine: routine,
                              steps: reorderedSteps,
                            );
                      },
                      itemBuilder: (context, index) {
                        final step = steps[index];

                        return AppCard(
                          key: ValueKey(step.id),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: InfoTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: .10,
                              ),
                              child: Text(
                                '${step.order + 1}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: step.title,
                            subtitle: step.description,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: "Modifier",
                                  icon: const Icon(Icons.edit_rounded),
                                  onPressed: () =>
                                      _showStepDialog(context, ref, step: step),
                                ),
                                IconButton(
                                  tooltip: "Supprimer",
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () =>
                                      _confirmDeleteStep(context, ref, step),
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
                        onPressed: () => _showStepDialog(context, ref),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text("Ajouter une étape"),
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

  Future<void> _showStepDialog(
    BuildContext context,
    WidgetRef ref, {
    StepModel? step,
  }) async {
    final titleController = TextEditingController(text: step?.title ?? '');
    final descriptionController = TextEditingController(
      text: step?.description ?? '',
    );
    var icon = step?.icon ?? 'check';
    var active = step?.active ?? true;

    final result = await showDialog<_StepFormResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                step == null ? "Ajouter une étape" : "Modifier l'étape",
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Titre",
                        prefixIcon: Icon(Icons.edit_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        prefixIcon: Icon(Icons.notes_rounded),
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
                        DropdownMenuItem(value: 'check', child: Text("Étape")),
                        DropdownMenuItem(value: 'bath', child: Text("Bain")),
                        DropdownMenuItem(
                          value: 'breakfast',
                          child: Text("breakfast"),
                        ),
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
                      title: const Text("Étape active"),
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
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty) {
                      return;
                    }

                    Navigator.of(context).pop(
                      _StepFormResult(
                        title: title,
                        description: description,
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

    titleController.dispose();
    descriptionController.dispose();

    if (result == null || !context.mounted) {
      return;
    }

    if (step == null) {
      await ref
          .read(stepCreationProvider.notifier)
          .createStep(
            routine: routine,
            title: result.title,
            description: result.description,
            icon: result.icon,
          );
    } else {
      await ref
          .read(stepUpdateProvider.notifier)
          .updateStep(
            routine: routine,
            step: step.copyWith(
              title: result.title,
              description: result.description,
              icon: result.icon,
              active: result.active,
            ),
          );
    }

    if (!context.mounted) {
      return;
    }

    final actionState = step == null
        ? ref.read(stepCreationProvider)
        : ref.read(stepUpdateProvider);

    if (actionState.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(actionState.error.toString())));
    }
  }

  Future<void> _confirmDeleteStep(
    BuildContext context,
    WidgetRef ref,
    StepModel step,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer cette étape ?"),
          content: Text(
            "L'étape \"${step.title}\" sera retirée de la routine.",
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
        .read(stepDeletionProvider.notifier)
        .deleteStep(routine: routine, stepId: step.id);

    if (!context.mounted) {
      return;
    }

    final deletionState = ref.read(stepDeletionProvider);

    if (deletionState.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(deletionState.error.toString())));
    }
  }
}

class _StepFormResult {
  const _StepFormResult({
    required this.title,
    required this.description,
    required this.icon,
    required this.active,
  });

  final String title;
  final String description;
  final String icon;
  final bool active;
}
