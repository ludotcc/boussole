import 'package:flutter/material.dart';

import '../../core/app_text_styles.dart';
import '../../models/parent_task_model.dart';
import '../boussole_button.dart';
import 'parent_tasks_matrix.dart';

class ParentTaskFormSheet extends StatefulWidget {
  const ParentTaskFormSheet({
    super.key,
    this.task,
    required this.initialCategory,
    required this.isSaving,
    required this.onSave,
  });

  final ParentTaskModel? task;
  final String initialCategory;
  final bool isSaving;
  final Future<void> Function({
    required String title,
    required String? description,
    required String category,
    required ParentTaskImportance importance,
    required ParentTaskStatus status,
    required List<ParentTaskStepModel> steps,
    required DateTime? dueDate,
    required List<ParentTaskReminderModel> reminders,
  })
  onSave;

  @override
  State<ParentTaskFormSheet> createState() => _ParentTaskFormSheetState();
}

class _ParentTaskFormSheetState extends State<ParentTaskFormSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newStepController = TextEditingController();
  late String _category;
  late ParentTaskImportance _importance;
  late ParentTaskStatus _status;
  DateTime? _dueDate;
  late List<ParentTaskReminderModel> _reminders;
  late List<ParentTaskStepModel> _steps;
  int _stepSequence = 0;

  bool get _isEditing => widget.task != null;
  bool get _canEditSteps =>
      !widget.isSaving &&
      _status != ParentTaskStatus.done &&
      _status != ParentTaskStatus.abandoned;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _category = task?.category ?? widget.initialCategory;
    _importance = task?.importance ?? ParentTaskImportance.normal;
    _status = task?.status ?? ParentTaskStatus.todo;
    _steps = [...?task?.steps];
    _reminders = [...?task?.reminders];

    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _dueDate = task.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newStepController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showMessage('Merci d’indiquer un titre.');
      return;
    }

    await widget.onSave(
      title: title,
      description: _descriptionController.text,
      category: _category,
      importance: _importance,
      status: _status,
      steps: [
        for (var index = 0; index < _steps.length; index++)
          _steps[index].copyWith(
            title: _steps[index].title.trim(),
            order: index,
          ),
      ].where((step) => step.title.isNotEmpty).toList(),
      dueDate: _dueDate,
      reminders: _reminders,
    );
  }

  void _addStep() {
    final title = _newStepController.text.trim();
    if (title.isEmpty) {
      _showMessage('Indiquez une sous-étape à ajouter.');
      return;
    }

    setState(() {
      _steps.add(
        ParentTaskStepModel(
          id: '${DateTime.now().microsecondsSinceEpoch}_${_stepSequence++}',
          title: title,
          isDone: false,
          order: _steps.length,
        ),
      );
      _newStepController.clear();
    });
  }

  void _moveStep(int index, int offset) {
    final target = index + offset;
    if (target < 0 || target >= _steps.length) return;
    setState(() {
      final step = _steps.removeAt(index);
      _steps.insert(target, step);
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await _pickDate(_dueDate ?? DateTime.now());

    if (picked == null) {
      return;
    }

    setState(() => _dueDate = picked);
  }

  Future<void> _pickReminder({int? index}) async {
    if (index == null && _reminders.length >= 5) {
      _showMessage('Tu peux ajouter jusqu’à 5 rappels pour cette tâche.');
      return;
    }
    final initial = index == null ? DateTime.now() : _reminders[index].remindAt;
    final date = await _pickDate(initial);
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (time == null) return;

    final remindAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (_reminders.any(
      (reminder) =>
          reminder.remindAt == remindAt &&
          (index == null || reminder.id != _reminders[index].id),
    )) {
      _showMessage('Ce rappel existe déjà.');
      return;
    }
    setState(() {
      if (index == null) {
        _reminders.add(
          ParentTaskReminderModel(
            id: 'reminder_${DateTime.now().microsecondsSinceEpoch}',
            remindAt: remindAt,
          ),
        );
      } else {
        _reminders[index] = _reminders[index].copyWith(remindAt: remindAt);
      }
      _reminders.sort((a, b) => a.remindAt.compareTo(b.remindAt));
    });
  }

  Future<DateTime?> _pickDate(DateTime initialDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
      locale: const Locale('fr', 'FR'),
    );

    if (picked == null) {
      return null;
    }

    return DateTime(picked.year, picked.month, picked.day);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isEditing ? 'Modifier la tâche' : 'Nouvelle tâche',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Classez-la simplement selon votre priorité du moment.',
                      style: AppTextStyles.small,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: _inputDecoration(
                        label: 'Titre',
                        icon: Icons.edit_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        label: 'Description',
                        icon: Icons.notes_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: _inputDecoration(
                        label: 'Catégorie',
                        icon: Icons.grid_view_rounded,
                      ),
                      items: [
                        for (final category in parentTaskCategories)
                          DropdownMenuItem(
                            value: category.id,
                            child: Text(category.label),
                          ),
                      ],
                      onChanged: widget.isSaving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _category = value);
                            },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<ParentTaskImportance>(
                      initialValue: _importance,
                      decoration: _inputDecoration(
                        label: 'Importance',
                        icon: Icons.flag_outlined,
                      ),
                      items: [
                        for (final importance in ParentTaskImportance.values)
                          DropdownMenuItem(
                            value: importance,
                            child: Text(importance.label),
                          ),
                      ],
                      onChanged: widget.isSaving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _importance = value);
                            },
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<ParentTaskStatus>(
                        initialValue: _status,
                        decoration: _inputDecoration(
                          label: 'État',
                          icon: Icons.track_changes_rounded,
                        ),
                        items: [
                          for (final status in ParentTaskStatus.values)
                            DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                        ],
                        onChanged: widget.isSaving
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() => _status = value);
                              },
                      ),
                    ],
                    const SizedBox(height: 14),
                    _DateField(
                      label: 'Échéance',
                      date: _dueDate,
                      onTap: widget.isSaving ? null : _pickDueDate,
                      onClear: widget.isSaving
                          ? null
                          : () => setState(() => _dueDate = null),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: _reminders.isNotEmpty,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        leading: const Icon(Icons.notifications_none_rounded),
                        title: Text('Me le rappeler · ${_reminders.length}'),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          8,
                          12,
                        ),
                        children: [
                          for (
                            var index = 0;
                            index < _reminders.length;
                            index++
                          )
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                _formatDateTime(_reminders[index].remindAt),
                              ),
                              trailing: Wrap(
                                children: [
                                  IconButton(
                                    tooltip: 'Modifier',
                                    onPressed: widget.isSaving
                                        ? null
                                        : () => _pickReminder(index: index),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Supprimer',
                                    onPressed: widget.isSaving
                                        ? null
                                        : () => setState(
                                            () => _reminders.removeAt(index),
                                          ),
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                ],
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: widget.isSaving ? null : _pickReminder,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Ajouter un rappel'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: _steps.isNotEmpty,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text('Sous-étapes · ${_steps.length}'),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        children: [
                          for (var index = 0; index < _steps.length; index++)
                            Row(
                              key: ValueKey(_steps[index].id),
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _steps[index].title,
                                    enabled: _canEditSteps,
                                    decoration: const InputDecoration(
                                      hintText: 'Sous-étape',
                                    ),
                                    onChanged: (value) => _steps[index] =
                                        _steps[index].copyWith(title: value),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Monter',
                                  onPressed: !_canEditSteps || index == 0
                                      ? null
                                      : () => _moveStep(index, -1),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Descendre',
                                  onPressed:
                                      !_canEditSteps ||
                                          index == _steps.length - 1
                                      ? null
                                      : () => _moveStep(index, 1),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  onPressed: !_canEditSteps
                                      ? null
                                      : () => setState(
                                          () => _steps.removeAt(index),
                                        ),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newStepController,
                                  enabled: _canEditSteps,
                                  onSubmitted: (_) => _addStep(),
                                  decoration: const InputDecoration(
                                    hintText: 'Ajouter une sous-étape',
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Ajouter',
                                onPressed: _canEditSteps ? _addStep : null,
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .07),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 62,
                child: widget.isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : BoussoleButton(
                        text: 'Enregistrer',
                        icon: Icons.check_rounded,
                        onPressed: _save,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? date;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          suffixIcon: date == null
              ? null
              : IconButton(
                  tooltip: 'Effacer',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          date == null ? 'Optionnel' : _formatDate(date!),
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

String _formatDateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${_formatDate(date)} à $hour:$minute';
}
