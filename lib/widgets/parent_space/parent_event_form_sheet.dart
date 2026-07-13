import 'package:flutter/material.dart';

import '../../core/app_text_styles.dart';
import '../../models/parent_personal_event_model.dart';
import '../boussole_button.dart';

class ParentEventFormSheet extends StatefulWidget {
  const ParentEventFormSheet({
    super.key,
    this.event,
    this.initialTitle,
    this.initialDescription,
    this.initialDate,
    this.initialTime,
    required this.isSaving,
    required this.onSave,
  });

  final ParentPersonalEventModel? event;
  final String? initialTitle;
  final String? initialDescription;
  final DateTime? initialDate;
  final String? initialTime;
  final bool isSaving;
  final Future<void> Function({
    required String title,
    required String? description,
    required String type,
    required DateTime date,
    required String? time,
    required bool isAllDay,
    required String recurrenceType,
    required bool shareWithFamily,
  })
  onSave;

  @override
  State<ParentEventFormSheet> createState() => _ParentEventFormSheetState();
}

class _ParentEventFormSheetState extends State<ParentEventFormSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime _date = DateTime.now();
  String _type = 'personnel';
  bool _isAllDay = true;
  bool _shareWithFamily = false;
  String _recurrenceType = 'none';

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;

    if (event != null) {
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _timeController.text = event.time ?? '';
      _type = event.type;
      _date = event.date;
      _isAllDay = event.isAllDay;
      _shareWithFamily = event.shareWithFamily;
      _recurrenceType = event.recurrenceType;
    } else {
      _titleController.text = widget.initialTitle ?? '';
      _descriptionController.text = widget.initialDescription ?? '';
      if (widget.initialDate != null) {
        _date = widget.initialDate!;
      }
      _timeController.text = widget.initialTime ?? '';
      _isAllDay = _timeController.text.isEmpty;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showMessage('Merci d’indiquer un titre.');
      return;
    }

    final today = DateTime.now();
    final firstAllowedDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(_date.year, _date.month, _date.day);

    if (selectedDate.isBefore(firstAllowedDate)) {
      _showMessage('Merci de choisir une date à partir d’aujourd’hui.');
      return;
    }

    await widget.onSave(
      title: title,
      description: _descriptionController.text,
      type: _type,
      date: _date,
      time: _isAllDay ? null : _timeController.text,
      isAllDay: _isAllDay,
      recurrenceType: _recurrenceType,
      shareWithFamily: _shareWithFamily,
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final firstAllowedDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(_date.year, _date.month, _date.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(firstAllowedDate)
          ? firstAllowedDate
          : selectedDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(today.year + 5, today.month, today.day),
      locale: const Locale('fr', 'FR'),
    );

    if (picked == null) {
      return;
    }

    setState(() => _date = DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(_timeController.text) ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() => _timeController.text = _formatTime(picked));
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
                      _isEditing ? 'Modifier l’événement' : 'Nouvel événement',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Un repère personnel, visible seulement par vous.',
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
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: _inputDecoration(
                        label: 'Type',
                        icon: Icons.category_rounded,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'personnel',
                          child: Text('Personnel'),
                        ),
                        DropdownMenuItem(
                          value: 'travail',
                          child: Text('Travail'),
                        ),
                        DropdownMenuItem(value: 'sante', child: Text('Santé')),
                        DropdownMenuItem(
                          value: 'famille',
                          child: Text('Famille'),
                        ),
                        DropdownMenuItem(
                          value: 'rendezVous',
                          child: Text('Rendez-vous'),
                        ),
                        DropdownMenuItem(value: 'autre', child: Text('Autre')),
                      ],
                      onChanged: widget.isSaving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _type = value);
                            },
                    ),
                    const SizedBox(height: 14),
                    _DateSelector(date: _date, onTap: _pickDate),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isAllDay,
                      title: const Text('Toute la journée'),
                      onChanged: widget.isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _isAllDay = value;
                                if (value) {
                                  _timeController.clear();
                                }
                              });
                            },
                    ),
                    if (!_isAllDay) ...[
                      const SizedBox(height: 8),
                      _TimeSelector(
                        time: _timeController.text,
                        onTap: widget.isSaving ? null : _pickTime,
                      ),
                    ],
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
                      initialValue: _recurrenceType,
                      decoration: _inputDecoration(
                        label: 'Récurrence',
                        icon: Icons.repeat_rounded,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('Jamais')),
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text('Tous les jours'),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('Toutes les semaines'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('Tous les mois'),
                        ),
                        DropdownMenuItem(
                          value: 'yearly',
                          child: Text('Tous les ans'),
                        ),
                      ],
                      onChanged: widget.isSaving
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _recurrenceType = value);
                            },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _shareWithFamily,
                      title: const Text('Partager avec l’agenda familial'),
                      subtitle: const Text('Désactivé par défaut'),
                      onChanged: widget.isSaving
                          ? null
                          : (value) {
                              setState(() => _shareWithFamily = value);
                            },
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
                        text: _isEditing
                            ? 'Enregistrer'
                            : 'Enregistrer l’événement',
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

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(_formatDate(date), style: AppTextStyles.body),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({required this.time, required this.onTap});

  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Heure',
          prefixIcon: const Icon(Icons.schedule_rounded),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          time.isEmpty ? 'Choisir une heure' : time,
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

TimeOfDay? _parseTime(String value) {
  final normalized = value.trim().replaceAll('h', ':');
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

  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}
