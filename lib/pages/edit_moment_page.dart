import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../models/moment_model.dart';
import '../providers/moments_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/boussole_app_bar.dart';

class EditMomentPage extends ConsumerStatefulWidget {
  const EditMomentPage({super.key, required this.moment});

  final MomentModel moment;

  @override
  ConsumerState<EditMomentPage> createState() => _EditMomentPageState();
}

class _EditMomentPageState extends ConsumerState<EditMomentPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _guidanceController;
  late final TextEditingController _durationController;
  late final TextEditingController _maxDailyUsesController;
  TimeOfDay? _orderTime;
  late String _childTimeDisplayType;
  late bool _isMultiUse;
  late bool _hasRoutine;
  late bool _active;
  late String _scheduleMode;
  late List<int> _weekdays;
  DateTime? _singleDate;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.moment.name);
    _guidanceController = TextEditingController(
      text: widget.moment.guidanceText ?? '',
    );
    _durationController = TextEditingController(
      text:
          (widget.moment.timerMinutes ?? widget.moment.maxDurationMinutes)
              ?.toString() ??
          '',
    );
    _maxDailyUsesController = TextEditingController(
      text: widget.moment.maxDailyUses?.toString() ?? '2',
    );
    _orderTime = _timeFromMinutes(widget.moment.orderMinutes);
    _childTimeDisplayType = widget.moment.childTimeDisplayType;
    _isMultiUse = widget.moment.isMultiUse;
    _hasRoutine = widget.moment.hasRoutine;
    _active = widget.moment.active;
    _scheduleMode = widget.moment.scheduleMode;
    _weekdays = widget.moment.weekdays;
    _singleDate = widget.moment.singleDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _guidanceController.dispose();
    _durationController.dispose();
    _maxDailyUsesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(momentUpdateProvider);
    final isLoading = updateState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BoussoleAppBar(title: "Modifier le moment"),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            AppCard(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration(
                      label: "Nom du moment",
                      icon: Icons.edit_rounded,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Pour guider ton enfant",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _guidanceController,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 180,
                    decoration: _inputDecoration(
                      label: "Exemple : pense à prendre ta serviette.",
                      icon: Icons.chat_bubble_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _OrderTimeSelector(
                    time: _orderTime == null
                        ? 'Choisir une heure'
                        : _formatTime(_orderTime!),
                    onTap: isLoading ? null : _pickOrderTime,
                  ),
                  const SizedBox(height: 18),
                  _ScheduleFields(
                    scheduleMode: _scheduleMode,
                    weekdays: _weekdays,
                    singleDate: _singleDate,
                    inputDecoration: _inputDecoration,
                    onModeChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _scheduleMode = value;
                              if (value == MomentScheduleModes.daily) {
                                _weekdays = const [];
                                _singleDate = null;
                              }
                              if (value != MomentScheduleModes.singleDate) {
                                _singleDate = null;
                              }
                            });
                          },
                    onWeekdayToggled: isLoading ? null : _toggleWeekday,
                    onPickDate: isLoading ? null : _pickSingleDate,
                  ),
                  if (_canUseTimeOptions) ...[
                    const SizedBox(height: 18),
                    _TimeOptionsFields(
                      value: _childTimeDisplayType,
                      durationController: _durationController,
                      inputDecoration: _inputDecoration,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _childTimeDisplayType = value;
                                if (value == 'none') {
                                  _durationController.clear();
                                }
                              });
                            },
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Privilèges"),
                    subtitle: const Text(
                      "Pour les moments qu'on peut relancer",
                    ),
                    value: _isMultiUse,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _isMultiUse = value;
                              if (value &&
                                  _maxDailyUsesController.text.trim().isEmpty) {
                                _maxDailyUsesController.text = '2';
                              }
                            });
                          },
                  ),
                  if (_isMultiUse) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxDailyUsesController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        label: "Nombre d'utilisations par jour",
                        icon: Icons.repeat_rounded,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Ce moment ouvre une routine"),
                    value: _hasRoutine,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _hasRoutine = value;
                            });
                          },
                  ),
                  if (_hasRoutine) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              context.push(
                                '/moment-routines',
                                extra: widget.moment,
                              );
                            },
                      icon: const Icon(Icons.checklist_rounded),
                      label: const Text("Gérer la routine"),
                    ),
                  ],
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Moment actif"),
                    value: _active,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _active = value;
                            });
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : BoussoleButton(
                    text: "Enregistrer",
                    icon: Icons.check_rounded,
                    onPressed: _saveMoment,
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

  Future<void> _saveMoment() async {
    final name = _nameController.text.trim();
    final durationMinutes = int.tryParse(_durationController.text.trim());
    final maxDailyUses = int.tryParse(_maxDailyUsesController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Merci d'indiquer un nom.")));
      return;
    }

    if (_orderTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Merci de choisir une heure.")),
      );
      return;
    }

    if (_canUseTimeOptions &&
        _childTimeDisplayType == 'timer' &&
        (durationMinutes == null || durationMinutes <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Indiquez une durée en minutes.")),
      );
      return;
    }

    if (_canUseTimeOptions &&
        _childTimeDisplayType == 'maxDuration' &&
        (durationMinutes == null || durationMinutes <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Indiquez une durée maximum en minutes.")),
      );
      return;
    }

    if (_isMultiUse && (maxDailyUses == null || maxDailyUses <= 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Indiquez au moins 2 utilisations par jour."),
        ),
      );
      return;
    }

    if ((_scheduleMode == MomentScheduleModes.weekdays ||
            _scheduleMode == MomentScheduleModes.weekly) &&
        _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Choisissez au moins un jour.")),
      );
      return;
    }

    if (_scheduleMode == MomentScheduleModes.singleDate &&
        _singleDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Choisissez une date.")));
      return;
    }

    final childTimeDisplayType = _canUseTimeOptions
        ? _childTimeDisplayType
        : 'none';

    final updatedMoment = widget.moment.copyWith(
      name: name,
      guidanceText: _guidanceController.text.trim().isEmpty
          ? null
          : _guidanceController.text.trim(),
      orderMinutes: _minutes(_orderTime!),
      childTimeDisplayType: childTimeDisplayType,
      timerMinutes: childTimeDisplayType == 'timer' ? durationMinutes : null,
      maxDurationMinutes: childTimeDisplayType == 'maxDuration'
          ? durationMinutes
          : null,
      isMultiUse: _isMultiUse,
      maxDailyUses: _isMultiUse ? maxDailyUses : null,
      hasRoutine: _hasRoutine,
      active: _active,
      scheduleMode: _scheduleMode,
      weekdays: _weekdays,
      singleDate: _singleDate,
    );

    await ref.read(momentUpdateProvider.notifier).updateMoment(updatedMoment);

    if (!mounted) {
      return;
    }

    final updateState = ref.read(momentUpdateProvider);

    if (updateState.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(updateState.error.toString())));
      return;
    }

    context.pop();
  }

  Future<void> _pickOrderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _orderTime ?? TimeOfDay.now(),
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

    setState(() => _orderTime = picked);
  }

  Future<void> _pickSingleDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _singleDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );

    if (picked == null) {
      return;
    }

    setState(() => _singleDate = picked);
  }

  void _toggleWeekday(int weekday) {
    final weekdays = _weekdays.toSet();

    if (weekdays.contains(weekday)) {
      weekdays.remove(weekday);
    } else {
      weekdays.add(weekday);
    }

    setState(() {
      _weekdays = weekdays.toList()..sort();
    });
  }

  bool get _canUseTimeOptions {
    return _isTimeOptionMoment(widget.moment.iconKey);
  }
}

class _ScheduleFields extends StatelessWidget {
  const _ScheduleFields({
    required this.scheduleMode,
    required this.weekdays,
    required this.singleDate,
    required this.inputDecoration,
    required this.onModeChanged,
    required this.onWeekdayToggled,
    required this.onPickDate,
  });

  final String scheduleMode;
  final List<int> weekdays;
  final DateTime? singleDate;
  final InputDecoration Function({
    required String label,
    required IconData icon,
  })
  inputDecoration;
  final ValueChanged<String>? onModeChanged;
  final ValueChanged<int>? onWeekdayToggled;
  final VoidCallback? onPickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: scheduleMode,
          decoration: inputDecoration(
            label: 'Planification',
            icon: Icons.event_repeat_rounded,
          ),
          items: const [
            DropdownMenuItem(
              value: MomentScheduleModes.daily,
              child: Text('Tous les jours'),
            ),
            DropdownMenuItem(
              value: MomentScheduleModes.weekdays,
              child: Text('Certains jours'),
            ),
            DropdownMenuItem(
              value: MomentScheduleModes.singleDate,
              child: Text('Date unique'),
            ),
            DropdownMenuItem(
              value: MomentScheduleModes.weekly,
              child: Text('Récurrence hebdomadaire'),
            ),
          ],
          onChanged: onModeChanged == null
              ? null
              : (value) {
                  if (value == null) return;
                  onModeChanged!(value);
                },
        ),
        if (scheduleMode == MomentScheduleModes.weekdays ||
            scheduleMode == MomentScheduleModes.weekly) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final weekday in _weekdayOptions.entries)
                  FilterChip(
                    showCheckmark: false,
                    label: Text(weekday.value),
                    selected: weekdays.contains(weekday.key),
                    onSelected: onWeekdayToggled == null
                        ? null
                        : (_) => onWeekdayToggled!(weekday.key),
                  ),
              ],
            ),
          ),
        ],
        if (scheduleMode == MomentScheduleModes.singleDate) ...[
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPickDate,
            child: InputDecorator(
              decoration: inputDecoration(
                label: 'Date',
                icon: Icons.calendar_today_rounded,
              ),
              child: Text(_formatDate(singleDate)),
            ),
          ),
        ],
      ],
    );
  }
}

class _TimeOptionsFields extends StatelessWidget {
  const _TimeOptionsFields({
    required this.value,
    required this.durationController,
    required this.inputDecoration,
    required this.onChanged,
  });

  final String value;
  final TextEditingController durationController;
  final InputDecoration Function({
    required String label,
    required IconData icon,
  })
  inputDecoration;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: inputDecoration(
            label: 'Repère enfant',
            icon: Icons.hourglass_bottom_rounded,
          ),
          items: const [
            DropdownMenuItem(value: 'none', child: Text('Aucun')),
            DropdownMenuItem(value: 'timer', child: Text('Timer')),
            DropdownMenuItem(
              value: 'maxDuration',
              child: Text('Durée maximum'),
            ),
          ],
          onChanged: onChanged == null
              ? null
              : (value) {
                  if (value == null) return;
                  onChanged!(value);
                },
        ),
        if (value == 'timer' || value == 'maxDuration') ...[
          const SizedBox(height: 18),
          TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: inputDecoration(
              label: value == 'timer'
                  ? 'Durée en minutes'
                  : 'Durée maximum en minutes',
              icon: Icons.timer_outlined,
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderTimeSelector extends StatelessWidget {
  const _OrderTimeSelector({required this.time, required this.onTap});

  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Heure d'ordre",
          prefixIcon: const Icon(Icons.schedule_rounded),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(time),
      ),
    );
  }
}

TimeOfDay? _timeFromMinutes(int? value) {
  if (value == null) {
    return null;
  }

  return TimeOfDay(hour: value ~/ 60, minute: value % 60);
}

int _minutes(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Choisir une date';
  }

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

const _weekdayOptions = {
  DateTime.monday: 'Lun',
  DateTime.tuesday: 'Mar',
  DateTime.wednesday: 'Mer',
  DateTime.thursday: 'Jeu',
  DateTime.friday: 'Ven',
  DateTime.saturday: 'Sam',
  DateTime.sunday: 'Dim',
};

bool _isTimeOptionMoment(String iconKey) {
  if (iconKey == 'routineMorning' ||
      iconKey == 'routineEvening' ||
      iconKey == 'breakfast' ||
      iconKey == 'lunch' ||
      iconKey == 'dinner' ||
      iconKey == 'wake_up' ||
      iconKey == 'sleep' ||
      iconKey == 'householdTasks') {
    return false;
  }

  return true;
}
