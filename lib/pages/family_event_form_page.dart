import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/family_event_model.dart';
import '../models/family_member_model.dart';
import '../providers/family_events_provider.dart';
import '../providers/family_members_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/avatar_circle.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';

class FamilyEventFormPage extends ConsumerStatefulWidget {
  const FamilyEventFormPage({super.key, this.event});

  final FamilyEventModel? event;

  @override
  ConsumerState<FamilyEventFormPage> createState() =>
      _FamilyEventFormPageState();
}

class _FamilyEventFormPageState extends ConsumerState<FamilyEventFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  String _type = 'famille';
  DateTime _date = DateTime.now();
  bool _isAllDay = true;
  bool _isSensitiveMoment = false;
  String _recurrenceType = 'none';
  String _childTimeDisplayType = 'none';
  Set<String> _memberIds = {};

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
      _isSensitiveMoment = event.isSensitiveMoment;
      _recurrenceType = event.recurrenceType;
      _childTimeDisplayType = event.childTimeDisplayType;
      _durationController.text =
          (event.timerMinutes ?? event.maxDurationMinutes)?.toString() ?? '';
      _memberIds = event.memberIds.toSet();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showMessage('Merci d’indiquer un titre.');
      return;
    }

    if (_memberIds.isEmpty) {
      _showMessage('Choisissez au moins un membre.');
      return;
    }

    final today = DateTime.now();
    final firstAllowedDate = DateTime(today.year, today.month, today.day);

    final selectedDate = DateTime(_date.year, _date.month, _date.day);

    if (selectedDate.isBefore(firstAllowedDate)) {
      _showMessage('Merci de choisir une date à partir d’aujourd’hui.');
      return;
    }

    final durationMinutes = int.tryParse(_durationController.text.trim());
    if (_childTimeDisplayType == 'timer' &&
        (durationMinutes == null || durationMinutes <= 0)) {
      _showMessage('Indiquez une durée en minutes.');
      return;
    }

    if (_childTimeDisplayType == 'maxDuration' &&
        (durationMinutes == null || durationMinutes <= 0)) {
      _showMessage('Indiquez une durée maximum en minutes.');
      return;
    }

    if (_isEditing) {
      await ref
          .read(familyEventActionProvider.notifier)
          .updateEvent(
            widget.event!.copyWith(
              title: title,
              description: _descriptionController.text,
              type: _type,
              date: _date,
              time: _isAllDay ? null : _timeController.text,
              isAllDay: _isAllDay,
              isSensitiveMoment: _isSensitiveMoment,
              memberIds: _memberIds.toList(),
              recurrenceType: _recurrenceType,
              childTimeDisplayType: _childTimeDisplayType,
              timerMinutes: _childTimeDisplayType == 'timer'
                  ? durationMinutes
                  : null,
              maxDurationMinutes: _childTimeDisplayType == 'maxDuration'
                  ? durationMinutes
                  : null,
              endTime: null,
            ),
          );
    } else {
      await ref
          .read(familyEventActionProvider.notifier)
          .createEvent(
            title: title,
            description: _descriptionController.text,
            type: _type,
            date: _date,
            time: _isAllDay ? null : _timeController.text,
            isAllDay: _isAllDay,
            isSensitiveMoment: _isSensitiveMoment,
            memberIds: _memberIds.toList(),
            recurrenceType: _recurrenceType,
            childTimeDisplayType: _childTimeDisplayType,
            timerMinutes: _childTimeDisplayType == 'timer'
                ? durationMinutes
                : null,
            maxDurationMinutes: _childTimeDisplayType == 'maxDuration'
                ? durationMinutes
                : null,
          );
    }

    if (!mounted) {
      return;
    }

    final state = ref.read(familyEventActionProvider);

    if (state.hasError) {
      _showMessage(state.error.toString());
      return;
    }

    context.pop();
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

    setState(() {
      _date = DateTime(picked.year, picked.month, picked.day);
    });
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

    setState(() {
      _timeController.text = _formatTime(picked);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(familyMembersProvider);
    final actionState = ref.watch(familyEventActionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier l’événement' : 'Créer un événement'),
        elevation: 0,
      ),
      body: SafeArea(
        child: membersAsync.when(
          loading: () =>
              const Padding(padding: EdgeInsets.all(24), child: LoadingCard()),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(24),
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Oups',
              message: error.toString(),
            ),
          ),
          data: (members) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                Text(
                  _isEditing ? 'Un moment à ajuster' : 'Un nouveau moment',
                  style: AppTextStyles.h2.copyWith(
                    color: const Color.fromARGB(255, 52, 72, 97),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajoutez un repère doux pour la famille.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                AppCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: _inputDecoration(
                          label: 'Titre',
                          icon: Icons.edit_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: _inputDecoration(
                          label: 'Type',
                          icon: Icons.category_rounded,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'sante',
                            child: Text('Santé'),
                          ),
                          DropdownMenuItem(
                            value: 'ecole',
                            child: Text('École'),
                          ),
                          DropdownMenuItem(
                            value: 'activite',
                            child: Text('Activité'),
                          ),
                          DropdownMenuItem(
                            value: 'famille',
                            child: Text('Famille'),
                          ),
                          DropdownMenuItem(
                            value: 'anniversaire',
                            child: Text('Anniversaire'),
                          ),
                          DropdownMenuItem(
                            value: 'rendezVous',
                            child: Text('Rendez-vous'),
                          ),
                          DropdownMenuItem(
                            value: 'autre',
                            child: Text('Autre'),
                          ),
                        ],
                        onChanged: actionState.isLoading
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() => _type = value);
                              },
                      ),
                      const SizedBox(height: 16),
                      _DateSelector(date: _date, onTap: _pickDate),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isAllDay,
                        title: const Text('Toute la journée'),
                        onChanged: actionState.isLoading
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
                          onTap: actionState.isLoading ? null : _pickTime,
                        ),
                      ],
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isSensitiveMoment,
                        title: const Text('À accompagner doucement'),
                        subtitle: const Text(
                          'Affichage plus rassurant côté enfant',
                        ),
                        onChanged: actionState.isLoading
                            ? null
                            : (value) {
                                setState(() => _isSensitiveMoment = value);
                              },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _childTimeDisplayType,
                        decoration: _inputDecoration(
                          label: 'Repère enfant',
                          icon: Icons.hourglass_bottom_rounded,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'none', child: Text('Aucun')),
                          DropdownMenuItem(
                            value: 'timer',
                            child: Text('Timer'),
                          ),
                          DropdownMenuItem(
                            value: 'maxDuration',
                            child: Text('Durée maximum'),
                          ),
                        ],
                        onChanged: actionState.isLoading
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() {
                                  _childTimeDisplayType = value;
                                  if (value == 'none') {
                                    _durationController.clear();
                                  }
                                });
                              },
                      ),
                      if (_childTimeDisplayType == 'timer' ||
                          _childTimeDisplayType == 'maxDuration') ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: _childTimeDisplayType == 'timer'
                                ? 'Durée en minutes'
                                : 'Durée maximum en minutes',
                            icon: Icons.timer_outlined,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          label: 'Description',
                          icon: Icons.notes_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _recurrenceType,
                        decoration: _inputDecoration(
                          label: 'Récurrence',
                          icon: Icons.repeat_rounded,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'none',
                            child: Text('Jamais'),
                          ),
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
                        onChanged: actionState.isLoading
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() => _recurrenceType = value);
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Membres concernés', style: AppTextStyles.cardTitle),
                const SizedBox(height: 12),
                _MembersSelector(
                  members: members,
                  selectedIds: _memberIds,
                  onChanged: (ids) {
                    setState(() => _memberIds = ids);
                  },
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: membersAsync.when(
        loading: () => null,
        error: (error, stackTrace) => null,
        data: (members) => AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.background,
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
                child: actionState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : BoussoleButton(
                        text: 'Enregistrer l’événement',
                        icon: Icons.check_rounded,
                        onPressed: _save,
                      ),
              ),
            ),
          ),
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
        child: Text(_formatDate(date)),
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
        child: Text(time.isEmpty ? 'Choisir une heure' : time),
      ),
    );
  }
}

class _MembersSelector extends StatelessWidget {
  const _MembersSelector({
    required this.members,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<FamilyMemberModel> members;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const EmptyState(
        icon: Icons.family_restroom_rounded,
        title: 'Aucun membre',
        message: 'Ajoutez un membre avant de créer un événement.',
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (final member in members)
            CheckboxListTile(
              value: selectedIds.contains(member.id),
              onChanged: (value) {
                final nextIds = {...selectedIds};

                if (value == true) {
                  nextIds.add(member.id);
                } else {
                  nextIds.remove(member.id);
                }

                onChanged(nextIds);
              },
              secondary: AvatarCircle(imagePath: member.avatar, radius: 20),
              title: Text(member.firstName),
              subtitle: Text(_roleLabel(member.profileType)),
            ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'papa' => 'Papa',
      'maman' => 'Maman',
      'frere' => 'Frère',
      'soeur' => 'Sœur',
      'baby' => 'Bébé',
      _ => 'Enfant',
    };
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
