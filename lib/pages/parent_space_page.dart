import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/parent_personal_event_model.dart';
import '../models/parent_task_model.dart';
import '../providers/parent_space_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';
import '../widgets/parent_space/parent_agenda_section.dart';
import '../widgets/parent_space/parent_event_form_sheet.dart';
import '../widgets/parent_space/parent_task_form_sheet.dart';
import '../widgets/parent_space/parent_tasks_matrix.dart';

enum _ParentSpaceView { agenda, tasks }

class ParentSpacePage extends ConsumerStatefulWidget {
  const ParentSpacePage({
    super.key,
    required this.parentId,
    required this.parentName,
  });

  final String parentId;
  final String parentName;

  @override
  ConsumerState<ParentSpacePage> createState() => _ParentSpacePageState();
}

class _ParentSpacePageState extends ConsumerState<ParentSpacePage> {
  _ParentSpaceView _view = _ParentSpaceView.agenda;

  Future<void> _refresh() async {
    ref.invalidate(parentPersonalEventsProvider(widget.parentId));
    ref.invalidate(parentTasksProvider(widget.parentId));
  }

  Future<void> _openEventForm({
    ParentPersonalEventModel? event,
    ParentTaskModel? taskToPlan,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final actionState = ref.watch(parentSpaceActionProvider);

            return ParentEventFormSheet(
              event: event,
              initialTitle: taskToPlan?.title,
              initialDescription: taskToPlan?.description,
              initialDate: taskToPlan == null
                  ? null
                  : _planningDate(taskToPlan),
              initialTime: taskToPlan == null
                  ? null
                  : _planningTime(taskToPlan),
              isSaving: actionState.isLoading,
              onSave:
                  ({
                    required title,
                    required description,
                    required type,
                    required date,
                    required time,
                    required isAllDay,
                    required recurrenceType,
                    required shareWithFamily,
                  }) async {
                    if (taskToPlan != null) {
                      await ref
                          .read(parentSpaceActionProvider.notifier)
                          .planTask(
                            task: taskToPlan,
                            existingEvent: event,
                            title: title,
                            description: description,
                            type: type,
                            date: date,
                            time: time,
                            isAllDay: isAllDay,
                            recurrenceType: recurrenceType,
                            shareWithFamily: shareWithFamily,
                          );
                    } else if (event == null) {
                      await ref
                          .read(parentSpaceActionProvider.notifier)
                          .createPersonalEvent(
                            parentId: widget.parentId,
                            title: title,
                            description: description,
                            type: type,
                            date: date,
                            time: time,
                            isAllDay: isAllDay,
                            recurrenceType: recurrenceType,
                            shareWithFamily: shareWithFamily,
                          );
                    } else {
                      await ref
                          .read(parentSpaceActionProvider.notifier)
                          .updatePersonalEvent(
                            event.copyWith(
                              title: title,
                              description: description,
                              type: type,
                              date: date,
                              time: time,
                              isAllDay: isAllDay,
                              recurrenceType: recurrenceType,
                              shareWithFamily: shareWithFamily,
                            ),
                          );
                    }

                    if (!context.mounted) {
                      return;
                    }

                    final state = ref.read(parentSpaceActionProvider);
                    if (state.hasError) {
                      _showMessage(state.error.toString());
                      return;
                    }

                    Navigator.of(context).pop();
                    if (taskToPlan != null) {
                      _showMessage(
                        'Parfait, tu n\u2019as plus besoin d\u2019y penser pour le moment.',
                      );
                    }
                  },
            );
          },
        );
      },
    );
  }

  DateTime _planningDate(ParentTaskModel task) {
    final candidate = task.dueDate ?? task.reminderAt;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (candidate == null || candidate.isBefore(today)) return today;
    return candidate;
  }

  String? _planningTime(ParentTaskModel task) {
    final reminder = task.reminderAt;
    if (reminder == null || (reminder.hour == 0 && reminder.minute == 0)) {
      return null;
    }
    return '${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}';
  }

  Future<ParentPersonalEventModel?> _linkedEvent(ParentTaskModel task) async {
    if (!task.isPlanned) return null;
    final events = await ref.read(
      parentPersonalEventsProvider(widget.parentId).future,
    );
    for (final event in events) {
      if (event.id == task.plannedEventId) return event;
    }
    throw Exception('La planification liée est introuvable.');
  }

  Future<void> _planTask(ParentTaskModel task) async {
    try {
      final event = await _linkedEvent(task);
      if (!mounted) return;
      await _openEventForm(event: event, taskToPlan: task);
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _removeTaskPlanning(ParentTaskModel task) async {
    final confirmed = await _confirm(
      title: 'Retirer cette planification ?',
      message: 'La tâche restera disponible dans votre organisation.',
    );
    if (confirmed != true) return;

    try {
      final event = await _linkedEvent(task);
      if (event == null) return;
      await ref
          .read(parentSpaceActionProvider.notifier)
          .removeTaskPlanning(task: task, event: event);
      final state = ref.read(parentSpaceActionProvider);
      if (state.hasError) {
        _showActionErrorIfNeeded();
      } else {
        _showMessage(
          'La tâche reste disponible. Tu pourras la planifier à nouveau quand tu veux.',
        );
      }
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _openTaskForm({
    ParentTaskModel? task,
    String initialCategory = 'urgent_important',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final actionState = ref.watch(parentSpaceActionProvider);

            return ParentTaskFormSheet(
              task: task,
              initialCategory: initialCategory,
              isSaving: actionState.isLoading,
              onSave:
                  ({
                    required title,
                    required description,
                    required category,
                    required importance,
                    required status,
                    required steps,
                    required dueDate,
                    required reminders,
                  }) async {
                    if (task == null) {
                      await ref
                          .read(parentSpaceActionProvider.notifier)
                          .createTask(
                            parentId: widget.parentId,
                            title: title,
                            description: description,
                            category: category,
                            importance: importance,
                            steps: steps,
                            dueDate: dueDate,
                            reminders: reminders,
                          );
                    } else {
                      await ref
                          .read(parentSpaceActionProvider.notifier)
                          .updateTask(
                            task.copyWith(
                              title: title,
                              description: description,
                              category: category,
                              importance: importance,
                              status: status,
                              steps: steps,
                              dueDate: dueDate,
                              reminders: reminders,
                            ),
                            previousStatus: task.status,
                          );
                    }

                    if (!context.mounted) {
                      return;
                    }

                    final state = ref.read(parentSpaceActionProvider);
                    if (state.hasError) {
                      _showMessage(state.error.toString());
                      return;
                    }

                    Navigator.of(context).pop();
                    if (task != null && task.status != status) {
                      _showMessage(_statusEncouragement(status));
                    }
                  },
            );
          },
        );
      },
    );
  }

  Future<void> _deleteEvent(ParentPersonalEventModel event) async {
    ParentTaskModel? linkedTask;
    try {
      linkedTask = await _taskLinkedToEvent(event.id);
    } catch (error) {
      _showMessage(error.toString());
      return;
    }
    final confirmed = await _confirm(
      title: 'Supprimer cet événement ?',
      message: linkedTask != null
          ? 'La tâche restera disponible, mais ne sera plus planifiée.'
          : event.shareWithFamily
          ? 'Il disparaîtra aussi de l’agenda familial.'
          : 'Il disparaîtra de votre agenda personnel.',
    );

    if (confirmed != true) {
      return;
    }

    if (linkedTask != null) {
      await ref
          .read(parentSpaceActionProvider.notifier)
          .removeTaskPlanning(task: linkedTask, event: event);
    } else {
      await ref
          .read(parentSpaceActionProvider.notifier)
          .deletePersonalEvent(event);
    }
    _showActionErrorIfNeeded();
  }

  Future<ParentTaskModel?> _taskLinkedToEvent(String eventId) async {
    final tasks = await ref.read(parentTasksProvider(widget.parentId).future);
    for (final task in tasks) {
      if (task.plannedEventId == eventId) return task;
    }
    return null;
  }

  Future<void> _editEvent(ParentPersonalEventModel event) async {
    try {
      final linkedTask = await _taskLinkedToEvent(event.id);
      if (!mounted) return;
      await _openEventForm(event: event, taskToPlan: linkedTask);
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _deleteTask(ParentTaskModel task) async {
    if (task.isPlanned) {
      final deleteEvent = await _confirmPlannedTaskDeletion();
      if (deleteEvent == null) return;
      if (deleteEvent) {
        try {
          final event = await _linkedEvent(task);
          if (event == null) return;
          await ref
              .read(parentSpaceActionProvider.notifier)
              .removeTaskPlanning(task: task, event: event, deleteTask: true);
          _showActionErrorIfNeeded();
        } catch (error) {
          _showMessage(error.toString());
        }
        return;
      }
      await ref.read(parentSpaceActionProvider.notifier).deleteTask(task);
      _showActionErrorIfNeeded();
      return;
    }

    final confirmed = await _confirm(
      title: 'Supprimer cette tâche ?',
      message: 'Elle disparaîtra de votre organisation personnelle.',
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(parentSpaceActionProvider.notifier).deleteTask(task);
    _showActionErrorIfNeeded();
  }

  Future<bool?> _confirmPlannedTaskDeletion() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette tâche ?'),
        content: const Text(
          'Elle possède aussi un événement dans votre agenda. Que souhaitez-vous conserver ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Garder l’événement'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirm({required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showActionErrorIfNeeded() {
    final state = ref.read(parentSpaceActionProvider);

    if (state.hasError) {
      _showMessage(state.error.toString());
    }
  }

  void _showStatusResult(ParentTaskStatus status) {
    final state = ref.read(parentSpaceActionProvider);
    if (state.hasError) {
      _showActionErrorIfNeeded();
      return;
    }
    _showMessage(_statusEncouragement(status));
  }

  String _statusEncouragement(ParentTaskStatus status) {
    return switch (status) {
      ParentTaskStatus.started =>
        'La tâche est lancée. Tu peux avancer à ton rythme.',
      ParentTaskStatus.done => 'Une chose de moins à garder en tête.',
      ParentTaskStatus.abandoned =>
        'Bonne décision. Tu libères de la place pour ce qui compte.',
      ParentTaskStatus.todo => 'Tu peux reprendre cette tâche à ton rythme.',
    };
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(parentSpaceActionProvider);
    final eventsAsync = ref.watch(
      parentPersonalEventsProvider(widget.parentId),
    );
    final tasksAsync = ref.watch(parentTasksProvider(widget.parentId));
    final parentName = widget.parentName.trim().isEmpty
        ? 'Parent'
        : widget.parentName.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Espace parent'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Rafraîchir',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.backgroundBase02, fit: BoxFit.cover),
          Container(color: Colors.white.withValues(alpha: .40)),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
                children: [
                  _ParentHeader(
                    parentName: parentName,
                    isLoading: actionState.isLoading,
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<_ParentSpaceView>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: _ParentSpaceView.agenda,
                        icon: Icon(Icons.event_note_rounded),
                        label: Text('Agenda'),
                      ),
                      ButtonSegment(
                        value: _ParentSpaceView.tasks,
                        icon: Icon(Icons.grid_view_rounded),
                        label: Text('Organisation'),
                      ),
                    ],
                    selected: {_view},
                    onSelectionChanged: (selection) {
                      setState(() => _view = selection.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_view == _ParentSpaceView.agenda)
                    eventsAsync.when(
                      loading: () => const LoadingCard(),
                      error: (error, stackTrace) => EmptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'Oups',
                        message: error.toString(),
                      ),
                      data: (events) => ParentAgendaSection(
                        events: events,
                        onCreate: () => _openEventForm(),
                        onEdit: _editEvent,
                        onDelete: _deleteEvent,
                      ),
                    )
                  else
                    tasksAsync.when(
                      loading: () => const LoadingCard(),
                      error: (error, stackTrace) => EmptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'Oups',
                        message: error.toString(),
                      ),
                      data: (tasks) => ParentTasksMatrix(
                        tasks: tasks,
                        onCreate: (category) {
                          _openTaskForm(initialCategory: category);
                        },
                        onToggleDone: (task) async {
                          final nextStatus = task.isDone
                              ? ParentTaskStatus.todo
                              : ParentTaskStatus.done;
                          await ref
                              .read(parentSpaceActionProvider.notifier)
                              .toggleTaskDone(task);
                          _showStatusResult(nextStatus);
                        },
                        onStatusChanged: (task, status) async {
                          await ref
                              .read(parentSpaceActionProvider.notifier)
                              .updateTaskStatus(task: task, status: status);
                          _showStatusResult(status);
                        },
                        onStepToggle: (task, step) async {
                          await ref
                              .read(parentSpaceActionProvider.notifier)
                              .toggleTaskStep(task: task, stepId: step.id);
                          final state = ref.read(parentSpaceActionProvider);
                          if (state.hasError) {
                            _showActionErrorIfNeeded();
                          } else if (!step.isDone) {
                            _showMessage('Une étape de faite. Tu avances.');
                          }
                        },
                        onPlan: _planTask,
                        onRemovePlanning: _removeTaskPlanning,
                        onEdit: (task) => _openTaskForm(task: task),
                        onDelete: _deleteTask,
                        onMove: (task, category) async {
                          if (task.category == category) {
                            return;
                          }

                          await ref
                              .read(parentSpaceActionProvider.notifier)
                              .moveTask(task: task, category: category);
                          _showActionErrorIfNeeded();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_view == _ParentSpaceView.agenda) {
            _openEventForm();
          } else {
            _openTaskForm();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(_view == _ParentSpaceView.agenda ? 'Créer' : 'Ajouter'),
      ),
    );
  }
}

class _ParentHeader extends StatelessWidget {
  const _ParentHeader({required this.parentName, required this.isLoading});

  final String parentName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 47, 57, 78).withValues(alpha: 0.0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.0)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(34, 48, 74, 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bonjour $parentName',
              textAlign: TextAlign.center,
              style: AppTextStyles.h2.copyWith(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: const Color.fromARGB(255, 68, 93, 117),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Un espace calme pour votre agenda et vos priorités.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 68, 93, 117),
                height: 1.35,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(minHeight: 3),
            ],
          ],
        ),
      ),
    );
  }
}
