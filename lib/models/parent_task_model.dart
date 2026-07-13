const _unset = Object();

enum ParentTaskImportance {
  low('low', 'Faible'),
  normal('normal', 'Normale'),
  high('high', 'Forte');

  const ParentTaskImportance(this.value, this.label);

  final String value;
  final String label;

  static ParentTaskImportance fromValue(String? value) {
    return values.firstWhere(
      (importance) => importance.value == value,
      orElse: () => ParentTaskImportance.normal,
    );
  }
}

enum ParentTaskStatus {
  todo('todo', 'À faire'),
  started('started', 'Commencée'),
  done('done', 'Terminée'),
  abandoned('abandoned', 'Abandonnée');

  const ParentTaskStatus(this.value, this.label);

  final String value;
  final String label;

  static ParentTaskStatus fromValue(String? value, {required bool isDone}) {
    if (value == null) {
      return isDone ? ParentTaskStatus.done : ParentTaskStatus.todo;
    }

    return values.firstWhere(
      (status) => status.value == value,
      orElse: () => isDone ? ParentTaskStatus.done : ParentTaskStatus.todo,
    );
  }
}

class ParentTaskStepModel {
  const ParentTaskStepModel({
    required this.id,
    required this.title,
    required this.isDone,
    required this.order,
  });

  final String id;
  final String title;
  final bool isDone;
  final int order;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'isDone': isDone,
    'order': order,
  };

  ParentTaskStepModel copyWith({String? title, bool? isDone, int? order}) {
    return ParentTaskStepModel(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      order: order ?? this.order,
    );
  }
}

class ParentTaskReminderModel {
  const ParentTaskReminderModel({
    required this.id,
    required this.remindAt,
    this.label,
  });

  final String id;
  final DateTime remindAt;
  final String? label;

  Map<String, dynamic> toMap() => {
    'id': id,
    'remindAt': remindAt.toIso8601String(),
    'label': label,
  };

  ParentTaskReminderModel copyWith({
    DateTime? remindAt,
    Object? label = _unset,
  }) {
    return ParentTaskReminderModel(
      id: id,
      remindAt: remindAt ?? this.remindAt,
      label: label == _unset ? this.label : label as String?,
    );
  }
}

class ParentTaskModel {
  final String id;
  final String familyId;
  final String parentId;
  final String title;
  final String? description;
  final String category;
  final ParentTaskImportance importance;
  final ParentTaskStatus status;
  final List<ParentTaskStepModel> steps;
  final String? plannedEventId;
  final String? planningDestination;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final List<ParentTaskReminderModel> reminders;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? abandonedAt;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParentTaskModel({
    required this.id,
    required this.familyId,
    required this.parentId,
    required this.title,
    this.description,
    required this.category,
    this.importance = ParentTaskImportance.normal,
    ParentTaskStatus? status,
    this.steps = const [],
    this.plannedEventId,
    this.planningDestination,
    this.dueDate,
    this.reminderAt,
    this.reminders = const [],
    this.startedAt,
    this.completedAt,
    this.abandonedAt,
    bool isDone = false,
    required this.createdAt,
    required this.updatedAt,
  }) : status =
           status ?? (isDone ? ParentTaskStatus.done : ParentTaskStatus.todo),
       isDone =
           (status ??
               (isDone ? ParentTaskStatus.done : ParentTaskStatus.todo)) ==
           ParentTaskStatus.done;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'parentId': parentId,
      'title': title,
      'description': description,
      'category': category,
      'importance': importance.value,
      'status': status.value,
      'steps': steps.map((step) => step.toMap()).toList(),
      'plannedEventId': plannedEventId,
      'planningDestination': planningDestination,
      'dueDate': dueDate?.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'reminders': reminders.map((reminder) => reminder.toMap()).toList(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'abandonedAt': abandonedAt?.toIso8601String(),
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ParentTaskModel.fromMap(Map<String, dynamic> map) {
    final isDone = map['isDone'] as bool? ?? false;

    return ParentTaskModel(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      parentId: map['parentId'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      category: map['category'] as String? ?? 'urgent_important',
      importance: ParentTaskImportance.fromValue(map['importance'] as String?),
      status: ParentTaskStatus.fromValue(
        map['status'] as String?,
        isDone: isDone,
      ),
      steps: _parseSteps(map['steps']),
      plannedEventId: _parseOptionalString(map['plannedEventId']),
      planningDestination: _parsePlanningDestination(
        map['planningDestination'],
      ),
      dueDate: _parseOptionalDate(map['dueDate']),
      reminderAt: _parseOptionalDate(map['reminderAt']),
      reminders: _parseReminders(map),
      startedAt: _parseOptionalDate(map['startedAt']),
      completedAt: _parseOptionalDate(map['completedAt']),
      abandonedAt: _parseOptionalDate(map['abandonedAt']),
      isDone: isDone,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  ParentTaskModel copyWith({
    String? id,
    String? familyId,
    String? parentId,
    String? title,
    Object? description = _unset,
    String? category,
    ParentTaskImportance? importance,
    ParentTaskStatus? status,
    List<ParentTaskStepModel>? steps,
    Object? plannedEventId = _unset,
    Object? planningDestination = _unset,
    Object? dueDate = _unset,
    Object? reminderAt = _unset,
    List<ParentTaskReminderModel>? reminders,
    Object? startedAt = _unset,
    Object? completedAt = _unset,
    Object? abandonedAt = _unset,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final nextStatus =
        status ??
        (isDone == null
            ? this.status
            : isDone
            ? ParentTaskStatus.done
            : ParentTaskStatus.todo);

    return ParentTaskModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      description: description == _unset
          ? this.description
          : description as String?,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      status: nextStatus,
      steps: steps ?? this.steps,
      plannedEventId: plannedEventId == _unset
          ? this.plannedEventId
          : plannedEventId as String?,
      planningDestination: planningDestination == _unset
          ? this.planningDestination
          : planningDestination as String?,
      dueDate: dueDate == _unset ? this.dueDate : dueDate as DateTime?,
      reminderAt: reminderAt == _unset
          ? this.reminderAt
          : reminderAt as DateTime?,
      reminders: reminders ?? this.reminders,
      startedAt: startedAt == _unset ? this.startedAt : startedAt as DateTime?,
      completedAt: completedAt == _unset
          ? this.completedAt
          : completedAt as DateTime?,
      abandonedAt: abandonedAt == _unset
          ? this.abandonedAt
          : abandonedAt as DateTime?,
      isDone: nextStatus == ParentTaskStatus.done,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get completedStepCount => steps.where((step) => step.isDone).length;

  double get stepProgress =>
      steps.isEmpty ? 0 : completedStepCount / steps.length;

  bool get isPlanned => plannedEventId != null;
}

String? _parseOptionalString(dynamic value) {
  if (value is! String || value.trim().isEmpty) return null;
  return value.trim();
}

String? _parsePlanningDestination(dynamic value) {
  return value == 'personal' || value == 'personal_family' ? value : null;
}

List<ParentTaskStepModel> _parseSteps(dynamic value) {
  if (value is! List) return const [];

  final steps = <ParentTaskStepModel>[];
  for (final entry in value) {
    if (entry is! Map) continue;

    final id = entry['id'];
    final title = entry['title'];
    if (id is! String ||
        id.trim().isEmpty ||
        title is! String ||
        title.trim().isEmpty) {
      continue;
    }

    steps.add(
      ParentTaskStepModel(
        id: id,
        title: title.trim(),
        isDone: entry['isDone'] is bool ? entry['isDone'] as bool : false,
        order: entry['order'] is num
            ? (entry['order'] as num).toInt()
            : steps.length,
      ),
    );
  }
  steps.sort((a, b) => a.order.compareTo(b.order));
  return steps;
}

List<ParentTaskReminderModel> _parseReminders(Map<String, dynamic> map) {
  if (map.containsKey('reminders')) {
    final value = map['reminders'];
    if (value is! List) return const [];
    final reminders = <ParentTaskReminderModel>[];
    for (final entry in value) {
      if (entry is! Map) continue;
      final id = _parseOptionalString(entry['id']);
      final remindAt = _parseOptionalDate(entry['remindAt']);
      if (id == null || remindAt == null) continue;
      reminders.add(
        ParentTaskReminderModel(
          id: id,
          remindAt: remindAt,
          label: _parseOptionalString(entry['label']),
        ),
      );
    }
    reminders.sort((a, b) => a.remindAt.compareTo(b.remindAt));
    return reminders;
  }

  final legacy = _parseOptionalDate(map['reminderAt']);
  return legacy == null
      ? const []
      : [
          ParentTaskReminderModel(
            id: 'legacy_${legacy.microsecondsSinceEpoch}',
            remindAt: legacy,
          ),
        ];
}

DateTime? _parseOptionalDate(dynamic value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
