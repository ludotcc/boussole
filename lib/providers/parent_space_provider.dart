import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/parent_personal_event_model.dart';
import '../models/parent_task_model.dart';
import '../repositories/parent_space_repository.dart';
import 'family_action_notifier.dart';
import 'family_events_provider.dart';
import 'session_provider.dart';

final parentSpaceRepositoryProvider = Provider<ParentSpaceRepository>((ref) {
  return ParentSpaceRepository();
});

final parentPersonalEventsProvider =
    FutureProvider.family<List<ParentPersonalEventModel>, String>((
      ref,
      parentId,
    ) async {
      final session = ref.watch(sessionProvider);

      if (session == null || session.familyId.isEmpty || parentId.isEmpty) {
        return [];
      }

      return ref
          .watch(parentSpaceRepositoryProvider)
          .getPersonalEvents(familyId: session.familyId, parentId: parentId);
    });

final parentTasksProvider =
    FutureProvider.family<List<ParentTaskModel>, String>((ref, parentId) async {
      final session = ref.watch(sessionProvider);

      if (session == null || session.familyId.isEmpty || parentId.isEmpty) {
        return [];
      }

      return ref
          .watch(parentSpaceRepositoryProvider)
          .getTasks(familyId: session.familyId, parentId: parentId);
    });

class ParentSpaceActionNotifier extends FamilyActionNotifier {
  ParentSpaceActionNotifier(super.ref);

  Future<void> createPersonalEvent({
    required String parentId,
    required String title,
    required String? description,
    required String type,
    required DateTime date,
    required String? time,
    required bool isAllDay,
    required String recurrenceType,
    required bool shareWithFamily,
  }) {
    return runFamilyAction((familyId) async {
      if (parentId.isEmpty) {
        state = AsyncError(
          Exception("Parent introuvable."),
          StackTrace.current,
        );
        return;
      }

      await ref
          .read(parentSpaceRepositoryProvider)
          .createPersonalEvent(
            familyId: familyId,
            parentId: parentId,
            title: title,
            description: description,
            type: type,
            date: date,
            time: time,
            isAllDay: isAllDay,
            recurrenceType: recurrenceType,
            shareWithFamily: shareWithFamily,
          );

      _refreshEvents(parentId);
    });
  }

  Future<void> updatePersonalEvent(ParentPersonalEventModel event) {
    return runFamilyAction((familyId) async {
      await ref.read(parentSpaceRepositoryProvider).updatePersonalEvent(event);
      _refreshEvents(event.parentId);
    });
  }

  Future<void> deletePersonalEvent(ParentPersonalEventModel event) {
    return runFamilyAction((familyId) async {
      await ref.read(parentSpaceRepositoryProvider).deletePersonalEvent(event);
      _refreshEvents(event.parentId);
    });
  }

  Future<void> planTask({
    required ParentTaskModel task,
    required ParentPersonalEventModel? existingEvent,
    required String title,
    required String? description,
    required String type,
    required DateTime date,
    required String? time,
    required bool isAllDay,
    required String recurrenceType,
    required bool shareWithFamily,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(parentSpaceRepositoryProvider)
          .planTask(
            task: task,
            existingEvent: existingEvent,
            title: title,
            description: description,
            type: type,
            date: date,
            time: time,
            isAllDay: isAllDay,
            recurrenceType: recurrenceType,
            shareWithFamily: shareWithFamily,
          );
      ref.invalidate(parentTasksProvider(task.parentId));
      _refreshEvents(task.parentId);
    });
  }

  Future<void> removeTaskPlanning({
    required ParentTaskModel task,
    required ParentPersonalEventModel event,
    bool deleteTask = false,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(parentSpaceRepositoryProvider)
          .removeTaskPlanning(task: task, event: event, deleteTask: deleteTask);
      ref.invalidate(parentTasksProvider(task.parentId));
      _refreshEvents(task.parentId);
    });
  }

  Future<void> createTask({
    required String parentId,
    required String title,
    required String? description,
    required String category,
    required ParentTaskImportance importance,
    required List<ParentTaskStepModel> steps,
    required DateTime? dueDate,
    required List<ParentTaskReminderModel> reminders,
  }) {
    return runFamilyAction((familyId) async {
      if (parentId.isEmpty) {
        state = AsyncError(
          Exception("Parent introuvable."),
          StackTrace.current,
        );
        return;
      }

      await ref
          .read(parentSpaceRepositoryProvider)
          .createTask(
            familyId: familyId,
            parentId: parentId,
            title: title,
            description: description,
            category: category,
            importance: importance,
            steps: steps,
            dueDate: dueDate,
            reminders: reminders,
          );

      ref.invalidate(parentTasksProvider(parentId));
    });
  }

  Future<void> updateTask(
    ParentTaskModel task, {
    ParentTaskStatus? previousStatus,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(parentSpaceRepositoryProvider)
          .updateTask(task, previousStatus: previousStatus);
      ref.invalidate(parentTasksProvider(task.parentId));
    });
  }

  Future<void> deleteTask(ParentTaskModel task) {
    return runFamilyAction((familyId) async {
      await ref.read(parentSpaceRepositoryProvider).deleteTask(task);
      ref.invalidate(parentTasksProvider(task.parentId));
    });
  }

  Future<void> toggleTaskDone(ParentTaskModel task) {
    return runFamilyAction((familyId) async {
      await ref.read(parentSpaceRepositoryProvider).toggleTaskDone(task);
      ref.invalidate(parentTasksProvider(task.parentId));
    });
  }

  Future<void> updateTaskStatus({
    required ParentTaskModel task,
    required ParentTaskStatus status,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(parentSpaceRepositoryProvider)
          .updateTaskStatus(task: task, status: status);
      ref.invalidate(parentTasksProvider(task.parentId));
    });
  }

  Future<void> toggleTaskStep({
    required ParentTaskModel task,
    required String stepId,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(parentSpaceRepositoryProvider)
          .toggleTaskStep(task: task, stepId: stepId);
      ref.invalidate(parentTasksProvider(task.parentId));
    });
  }

  Future<void> moveTask({
    required ParentTaskModel task,
    required String category,
  }) {
    return runFamilyAction((familyId) async {
      await ref
          .read(parentSpaceRepositoryProvider)
          .moveTask(task: task, category: category);
      ref.invalidate(parentTasksProvider(task.parentId));
    });
  }

  void _refreshEvents(String parentId) {
    ref.invalidate(parentPersonalEventsProvider(parentId));
    ref.invalidate(familyEventsProvider);
    ref.invalidate(upcomingFamilyEventsProvider);
  }
}

final parentSpaceActionProvider =
    StateNotifierProvider<ParentSpaceActionNotifier, AsyncValue<void>>(
      (ref) => ParentSpaceActionNotifier(ref),
    );
