import '../models/family_event_model.dart';
import '../models/parent_personal_event_model.dart';
import '../models/parent_task_model.dart';
import '../services/parent_space_service.dart';

class ParentSpaceRepository {
  ParentSpaceRepository({ParentSpaceService? parentSpaceService})
    : _parentSpaceService = parentSpaceService ?? ParentSpaceService();

  final ParentSpaceService _parentSpaceService;

  Future<List<ParentPersonalEventModel>> getPersonalEvents({
    required String familyId,
    required String parentId,
  }) async {
    final events = await _parentSpaceService.getPersonalEvents(
      familyId: familyId,
      parentId: parentId,
    );

    events.sort(_compareEvents);
    return events;
  }

  Future<void> createPersonalEvent({
    required String familyId,
    required String parentId,
    required String title,
    required String? description,
    required String type,
    required DateTime date,
    required String? time,
    required bool isAllDay,
    required String recurrenceType,
    required bool shareWithFamily,
  }) async {
    final now = DateTime.now();
    final eventId = _parentSpaceService.generatePersonalEventId(
      familyId: familyId,
      parentId: parentId,
    );
    final familyEventId = shareWithFamily
        ? _parentSpaceService.generateFamilyEventId(familyId: familyId)
        : null;

    final event = ParentPersonalEventModel(
      id: eventId,
      familyId: familyId,
      parentId: parentId,
      title: title.trim(),
      description: _cleanOptional(description),
      type: _normalizePersonalEventType(type),
      date: _dateOnly(date),
      time: isAllDay ? null : _cleanOptional(time),
      isAllDay: isAllDay,
      recurrenceType: recurrenceType,
      shareWithFamily: shareWithFamily,
      familyEventId: familyEventId,
      createdAt: now,
      updatedAt: now,
    );

    _validatePersonalEvent(event);

    if (shareWithFamily && familyEventId != null) {
      await _parentSpaceService.createFamilyEvent(
        _buildFamilyEventFromPersonalEvent(event, familyEventId, now),
      );
    }

    return _parentSpaceService.createPersonalEvent(event);
  }

  Future<void> updatePersonalEvent(ParentPersonalEventModel event) async {
    final updatedAt = DateTime.now();
    var updatedEvent = event.copyWith(
      title: event.title.trim(),
      description: _cleanOptional(event.description),
      type: _normalizePersonalEventType(event.type),
      date: _dateOnly(event.date),
      time: event.isAllDay ? null : _cleanOptional(event.time),
      updatedAt: updatedAt,
    );

    _validatePersonalEvent(updatedEvent);

    if (updatedEvent.shareWithFamily) {
      final familyEventId =
          updatedEvent.familyEventId ??
          _parentSpaceService.generateFamilyEventId(familyId: event.familyId);
      updatedEvent = updatedEvent.copyWith(familyEventId: familyEventId);

      final familyEvent = _buildFamilyEventFromPersonalEvent(
        updatedEvent,
        familyEventId,
        updatedEvent.createdAt,
      );

      if (event.familyEventId == null) {
        await _parentSpaceService.createFamilyEvent(familyEvent);
      } else {
        await _parentSpaceService.updateFamilyEvent(familyEvent);
      }
    } else if (event.familyEventId != null) {
      await _parentSpaceService.deleteFamilyEvent(
        familyId: event.familyId,
        eventId: event.familyEventId!,
      );
      updatedEvent = updatedEvent.copyWith(familyEventId: null);
    }

    return _parentSpaceService.updatePersonalEvent(updatedEvent);
  }

  Future<void> deletePersonalEvent(ParentPersonalEventModel event) async {
    if (event.familyEventId != null) {
      await _parentSpaceService.deleteFamilyEvent(
        familyId: event.familyId,
        eventId: event.familyEventId!,
      );
    }

    return _parentSpaceService.deletePersonalEvent(
      familyId: event.familyId,
      parentId: event.parentId,
      eventId: event.id,
    );
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
  }) async {
    if (task.isPlanned && existingEvent?.id != task.plannedEventId) {
      throw Exception('La planification liée est introuvable.');
    }

    final now = DateTime.now();
    final eventId =
        existingEvent?.id ??
        _parentSpaceService.generatePersonalEventId(
          familyId: task.familyId,
          parentId: task.parentId,
        );
    final familyEventId = shareWithFamily
        ? existingEvent?.familyEventId ??
              _parentSpaceService.generateFamilyEventId(familyId: task.familyId)
        : null;
    final event = ParentPersonalEventModel(
      id: eventId,
      familyId: task.familyId,
      parentId: task.parentId,
      title: title.trim(),
      description: _cleanOptional(description),
      type: _normalizePersonalEventType(type),
      date: _dateOnly(date),
      time: isAllDay ? null : _cleanOptional(time),
      isAllDay: isAllDay,
      recurrenceType: recurrenceType,
      shareWithFamily: shareWithFamily,
      familyEventId: familyEventId,
      createdAt: existingEvent?.createdAt ?? now,
      updatedAt: now,
    );
    _validatePersonalEvent(event);

    final plannedTask = task.copyWith(
      plannedEventId: event.id,
      planningDestination: shareWithFamily ? 'personal_family' : 'personal',
      updatedAt: now,
    );
    final familyEvent = familyEventId == null
        ? null
        : _buildFamilyEventFromPersonalEvent(
            event,
            familyEventId,
            existingEvent?.createdAt ?? now,
          );

    await _parentSpaceService.saveTaskPlanning(
      task: plannedTask,
      event: event,
      familyEvent: familyEvent,
      previousFamilyEventId: existingEvent?.familyEventId,
    );
  }

  Future<void> removeTaskPlanning({
    required ParentTaskModel task,
    required ParentPersonalEventModel event,
    bool deleteTask = false,
  }) {
    if (event.id != task.plannedEventId) {
      throw Exception('La planification liée est introuvable.');
    }
    return _parentSpaceService.removeTaskPlanning(
      task: task.copyWith(
        plannedEventId: null,
        planningDestination: null,
        updatedAt: DateTime.now(),
      ),
      event: event,
      deleteTask: deleteTask,
    );
  }

  Future<List<ParentTaskModel>> getTasks({
    required String familyId,
    required String parentId,
  }) async {
    final tasks = await _parentSpaceService.getTasks(
      familyId: familyId,
      parentId: parentId,
    );

    tasks.sort(_compareTasks);
    return tasks;
  }

  Future<void> createTask({
    required String familyId,
    required String parentId,
    required String title,
    required String? description,
    required String category,
    required ParentTaskImportance importance,
    required List<ParentTaskStepModel> steps,
    required DateTime? dueDate,
    required List<ParentTaskReminderModel> reminders,
  }) {
    final now = DateTime.now();
    final normalizedReminders = _normalizeReminders(reminders);
    final task = ParentTaskModel(
      id: _parentSpaceService.generateParentTaskId(
        familyId: familyId,
        parentId: parentId,
      ),
      familyId: familyId,
      parentId: parentId,
      title: title.trim(),
      description: _cleanOptional(description),
      category: category,
      importance: importance,
      status: ParentTaskStatus.todo,
      steps: _normalizeSteps(steps),
      dueDate: dueDate == null ? null : _dateOnly(dueDate),
      reminderAt: normalizedReminders.isEmpty
          ? null
          : normalizedReminders.first.remindAt,
      reminders: normalizedReminders,
      isDone: false,
      createdAt: now,
      updatedAt: now,
    );

    _validateTask(task);
    return _parentSpaceService.createTask(task);
  }

  Future<void> updateTask(
    ParentTaskModel task, {
    ParentTaskStatus? previousStatus,
  }) {
    if (previousStatus != null && previousStatus != task.status) {
      task = _taskWithLifecycleDates(task);
    }
    final normalizedReminders = _normalizeReminders(task.reminders);
    final updatedTask = task.copyWith(
      title: task.title.trim(),
      description: _cleanOptional(task.description),
      steps: _normalizeSteps(task.steps),
      dueDate: task.dueDate == null ? null : _dateOnly(task.dueDate!),
      reminderAt: normalizedReminders.isEmpty
          ? null
          : normalizedReminders.first.remindAt,
      reminders: normalizedReminders,
      updatedAt: DateTime.now(),
    );

    _validateTask(updatedTask);
    return _parentSpaceService.updateTask(updatedTask);
  }

  ParentTaskModel _taskWithLifecycleDates(ParentTaskModel task) {
    final now = DateTime.now();
    return task.copyWith(
      startedAt: task.status == ParentTaskStatus.started
          ? task.startedAt ?? now
          : task.status == ParentTaskStatus.todo
          ? null
          : task.startedAt,
      completedAt: task.status == ParentTaskStatus.done ? now : null,
      abandonedAt: task.status == ParentTaskStatus.abandoned ? now : null,
    );
  }

  Future<void> deleteTask(ParentTaskModel task) {
    return _parentSpaceService.deleteTask(
      familyId: task.familyId,
      parentId: task.parentId,
      taskId: task.id,
    );
  }

  Future<void> toggleTaskDone(ParentTaskModel task) {
    return updateTaskStatus(
      task: task,
      status: task.isDone ? ParentTaskStatus.todo : ParentTaskStatus.done,
    );
  }

  Future<void> updateTaskStatus({
    required ParentTaskModel task,
    required ParentTaskStatus status,
  }) {
    final now = DateTime.now();
    return updateTask(
      task.copyWith(
        status: status,
        startedAt: status == ParentTaskStatus.started
            ? task.startedAt ?? now
            : status == ParentTaskStatus.todo
            ? null
            : task.startedAt,
        completedAt: status == ParentTaskStatus.done ? now : null,
        abandonedAt: status == ParentTaskStatus.abandoned ? now : null,
      ),
    );
  }

  Future<void> toggleTaskStep({
    required ParentTaskModel task,
    required String stepId,
  }) {
    if (task.status == ParentTaskStatus.done ||
        task.status == ParentTaskStatus.abandoned) {
      return Future.value();
    }

    var found = false;
    var checked = false;
    final steps = task.steps.map((step) {
      if (step.id != stepId) return step;
      found = true;
      checked = !step.isDone;
      return step.copyWith(isDone: checked);
    }).toList();
    if (!found) return Future.value();

    final status = checked && task.status == ParentTaskStatus.todo
        ? ParentTaskStatus.started
        : task.status;
    return updateTask(
      task.copyWith(
        steps: steps,
        status: status,
        startedAt: status == ParentTaskStatus.started
            ? task.startedAt ?? DateTime.now()
            : task.startedAt,
      ),
    );
  }

  Future<void> moveTask({
    required ParentTaskModel task,
    required String category,
  }) {
    return updateTask(task.copyWith(category: category));
  }

  FamilyEventModel _buildFamilyEventFromPersonalEvent(
    ParentPersonalEventModel event,
    String familyEventId,
    DateTime createdAt,
  ) {
    return FamilyEventModel(
      id: familyEventId,
      familyId: event.familyId,
      title: event.title,
      description: event.description,
      type: _familyTypeFromPersonalType(event.type),
      date: event.date,
      time: event.time,
      isAllDay: event.isAllDay,
      isSensitiveMoment: false,
      memberIds: [event.parentId],
      recurrenceType: event.recurrenceType,
      childTimeDisplayType: 'none',
      timerMinutes: null,
      maxDurationMinutes: null,
      endTime: null,
      createdAt: createdAt,
      updatedAt: event.updatedAt,
    );
  }

  int _compareEvents(ParentPersonalEventModel a, ParentPersonalEventModel b) {
    final dateComparison = a.date.compareTo(b.date);
    if (dateComparison != 0) {
      return dateComparison;
    }

    final timeComparison = _eventOrderMinutes(
      a,
    ).compareTo(_eventOrderMinutes(b));
    if (timeComparison != 0) {
      return timeComparison;
    }

    return a.title.compareTo(b.title);
  }

  int _compareTasks(ParentTaskModel a, ParentTaskModel b) {
    if (a.isDone != b.isDone) {
      return a.isDone ? 1 : -1;
    }

    final aDueDate = a.dueDate;
    final bDueDate = b.dueDate;

    if (aDueDate != null && bDueDate != null) {
      final dueComparison = aDueDate.compareTo(bDueDate);
      if (dueComparison != 0) {
        return dueComparison;
      }
    } else if (aDueDate != null) {
      return -1;
    } else if (bDueDate != null) {
      return 1;
    }

    return a.createdAt.compareTo(b.createdAt);
  }

  int _eventOrderMinutes(ParentPersonalEventModel event) {
    if (event.isAllDay) {
      return 0;
    }

    return _parseOrderMinutes(event.time) ?? 8 * 60;
  }

  int? _parseOrderMinutes(String? value) {
    final normalized = value?.trim().replaceAll('h', ':');
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    final parts = normalized.split(':');
    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return hour * 60 + minute;
  }

  String? _cleanOptional(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<ParentTaskStepModel> _normalizeSteps(List<ParentTaskStepModel> steps) {
    final normalized = <ParentTaskStepModel>[];
    for (final step in steps) {
      final title = step.title.trim();
      if (title.isEmpty) continue;
      normalized.add(step.copyWith(title: title, order: normalized.length));
    }
    return normalized;
  }

  List<ParentTaskReminderModel> _normalizeReminders(
    List<ParentTaskReminderModel> reminders,
  ) {
    final unique = <String, ParentTaskReminderModel>{};
    for (final reminder in reminders) {
      final key = reminder.remindAt.toIso8601String();
      unique.putIfAbsent(
        key,
        () => reminder.copyWith(label: _cleanOptional(reminder.label)),
      );
    }
    final normalized = unique.values.toList()
      ..sort((a, b) => a.remindAt.compareTo(b.remindAt));
    return normalized.take(5).toList();
  }

  void _validatePersonalEvent(ParentPersonalEventModel event) {
    if (event.title.trim().isEmpty) {
      throw Exception("Merci d'indiquer un titre.");
    }

    if (![
      'personnel',
      'travail',
      'sante',
      'famille',
      'rendezVous',
      'autre',
    ].contains(event.type)) {
      throw Exception("Choisissez un type valide.");
    }

    if (![
      'none',
      'daily',
      'weekly',
      'monthly',
      'yearly',
    ].contains(event.recurrenceType)) {
      throw Exception("Choisissez une récurrence valide.");
    }
  }

  String _normalizePersonalEventType(String type) {
    if ([
      'personnel',
      'travail',
      'sante',
      'famille',
      'rendezVous',
      'autre',
    ].contains(type)) {
      return type;
    }

    return 'personnel';
  }

  String _familyTypeFromPersonalType(String type) {
    return switch (type) {
      'sante' => 'sante',
      'famille' => 'famille',
      'rendezVous' => 'rendezVous',
      _ => 'autre',
    };
  }

  void _validateTask(ParentTaskModel task) {
    if (task.title.trim().isEmpty) {
      throw Exception("Merci d'indiquer un titre.");
    }

    if (![
      'urgent_important',
      'important_not_urgent',
      'urgent_not_important',
      'not_urgent_not_important',
    ].contains(task.category)) {
      throw Exception("Choisissez une catégorie valide.");
    }
  }
}
