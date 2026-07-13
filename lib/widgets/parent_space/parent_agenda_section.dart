import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/parent_personal_event_model.dart';
import '../common/empty_state.dart';
import 'parent_personal_event_card.dart';

enum ParentAgendaFilter { today, week, upcoming }

class _ParentAgendaTypeFilter {
  const _ParentAgendaTypeFilter({required this.value, required this.label});

  final String value;
  final String label;
}

const _parentTypeFilters = [
  _ParentAgendaTypeFilter(value: 'all', label: 'Tous'),
  _ParentAgendaTypeFilter(value: 'personnel', label: 'Personnel'),
  _ParentAgendaTypeFilter(value: 'travail', label: 'Travail'),
  _ParentAgendaTypeFilter(value: 'sante', label: 'Santé'),
  _ParentAgendaTypeFilter(value: 'famille', label: 'Famille'),
  _ParentAgendaTypeFilter(value: 'rendezVous', label: 'Rendez-vous'),
  _ParentAgendaTypeFilter(value: 'autre', label: 'Autre'),
];

String _eventCountLabel(int count) {
  return count == 1 ? '1 événement' : '$count événements';
}

String _eventTypeLabel(String type) {
  return switch (type) {
    'personnel' => 'Personnel',
    'travail' => 'Travail',
    'sante' => 'Santé',
    'famille' => 'Famille',
    'rendezVous' => 'Rendez-vous',
    _ => 'Autre',
  };
}

String _normalizeSearch(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ô', 'o')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ç', 'c');
}

class ParentAgendaSection extends StatefulWidget {
  const ParentAgendaSection({
    super.key,
    required this.events,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ParentPersonalEventModel> events;
  final VoidCallback onCreate;
  final ValueChanged<ParentPersonalEventModel> onEdit;
  final ValueChanged<ParentPersonalEventModel> onDelete;

  @override
  State<ParentAgendaSection> createState() => _ParentAgendaSectionState();
}

class _ParentAgendaSectionState extends State<ParentAgendaSection> {
  ParentAgendaFilter _filter = ParentAgendaFilter.week;
  final _searchController = TextEditingController();
  final Set<DateTime> _expandedMonths = {};
  final Set<DateTime> _expandedMonthLists = {};
  String _selectedType = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _filteredEvents(widget.events);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ParentAgendaFilter>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ParentAgendaFilter.today,
              label: Text('Aujourd’hui'),
            ),
            ButtonSegment(
              value: ParentAgendaFilter.week,
              label: Text('Cette semaine'),
            ),
            ButtonSegment(
              value: ParentAgendaFilter.upcoming,
              label: Text('À venir'),
            ),
          ],
          selected: {_filter},
          onSelectionChanged: (selection) {
            setState(() => _filter = selection.first);
          },
        ),
        const SizedBox(height: 14),
        _AgendaSearchField(
          controller: _searchController,
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        const SizedBox(height: 14),
        _TypeFilterChips(
          filters: _parentTypeFilters,
          selected: _selectedType,
          onChanged: (type) {
            setState(() => _selectedType = type);
          },
        ),
        const SizedBox(height: 20),
        if (filteredEvents.isEmpty)
          EmptyState(
            icon: Icons.event_note_rounded,
            title: 'Votre agenda personnel est calme.',
            message: 'Ajoutez un repère pour votre journée.',
          )
        else
          _ParentAgendaTimeline(
            events: filteredEvents,
            showMonthsOnly: _filter == ParentAgendaFilter.upcoming,
            expandedMonths: _expandedMonths,
            expandedMonthLists: _expandedMonthLists,
            onToggleMonth: (month) {
              setState(() {
                if (_expandedMonths.contains(month)) {
                  _expandedMonths.remove(month);
                } else {
                  _expandedMonths.add(month);
                }
              });
            },
            onToggleMonthList: (month) {
              setState(() {
                if (_expandedMonthLists.contains(month)) {
                  _expandedMonthLists.remove(month);
                } else {
                  _expandedMonthLists.add(month);
                }
              });
            },
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
          ),
      ],
    );
  }

  List<ParentPersonalEventModel> _filteredEvents(
    List<ParentPersonalEventModel> events,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    return events.where((event) {
      final matchesDate = switch (_filter) {
        ParentAgendaFilter.today => _isSameDay(event.date, today),
        ParentAgendaFilter.week =>
          !event.date.isBefore(today) && event.date.isBefore(weekEnd),
        ParentAgendaFilter.upcoming => !event.date.isBefore(today),
      };

      if (!matchesDate) {
        return false;
      }

      if (_selectedType != 'all' && event.type != _selectedType) {
        return false;
      }

      return _matchesSearch(event, _searchQuery);
    }).toList();
  }

  bool _matchesSearch(ParentPersonalEventModel event, String query) {
    final normalizedQuery = _normalizeSearch(query);

    if (normalizedQuery.isEmpty) {
      return true;
    }

    final searchableText = '${event.title} ${_eventTypeLabel(event.type)}';

    return _normalizeSearch(searchableText).contains(normalizedQuery);
  }
}

class _AgendaSearchField extends StatelessWidget {
  const _AgendaSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Rechercher un événement',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}

class _TypeFilterChips extends StatelessWidget {
  const _TypeFilterChips({
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  final List<_ParentAgendaTypeFilter> filters;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            ChoiceChip(
              showCheckmark: false,
              label: Text(filter.label),
              selected: selected == filter.value,
              onSelected: (_) => onChanged(filter.value),
              selectedColor: AppColors.primary.withValues(alpha: .14),
              backgroundColor: Colors.white.withValues(alpha: .86),
              labelStyle: AppTextStyles.small.copyWith(
                color: selected == filter.value
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: selected == filter.value
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: selected == filter.value
                      ? AppColors.primary.withValues(alpha: .24)
                      : AppColors.border,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ParentAgendaTimeline extends StatelessWidget {
  const _ParentAgendaTimeline({
    required this.events,
    required this.showMonthsOnly,
    required this.expandedMonths,
    required this.expandedMonthLists,
    required this.onToggleMonth,
    required this.onToggleMonthList,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ParentPersonalEventModel> events;
  final bool showMonthsOnly;
  final Set<DateTime> expandedMonths;
  final Set<DateTime> expandedMonthLists;
  final ValueChanged<DateTime> onToggleMonth;
  final ValueChanged<DateTime> onToggleMonthList;
  final ValueChanged<ParentPersonalEventModel> onEdit;
  final ValueChanged<ParentPersonalEventModel> onDelete;

  @override
  Widget build(BuildContext context) {
    if (showMonthsOnly) {
      final groupedEvents = _groupByMonth(events);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in groupedEvents.entries) ...[
            _MonthSection(
              month: entry.key,
              events: entry.value,
              isExpanded: expandedMonths.contains(entry.key),
              isShowingAll: expandedMonthLists.contains(entry.key),
              onToggle: () => onToggleMonth(entry.key),
              onToggleShowAll: () => onToggleMonthList(entry.key),
              onEdit: onEdit,
              onDelete: onDelete,
            ),
            const SizedBox(height: 8),
          ],
        ],
      );
    }

    final groupedEvents = _groupByDate(events);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groupedEvents.entries) ...[
          _TimelineDateLabel(date: entry.key),
          const SizedBox(height: 6),
          for (final event in entry.value) ...[
            ParentPersonalEventCard(
              event: event,
              onEdit: () => onEdit(event),
              onDelete: () => onDelete(event),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  Map<DateTime, List<ParentPersonalEventModel>> _groupByDate(
    List<ParentPersonalEventModel> events,
  ) {
    final groups = <DateTime, List<ParentPersonalEventModel>>{};

    for (final event in events) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      groups.putIfAbsent(date, () => []).add(event);
    }

    return groups;
  }

  Map<DateTime, List<ParentPersonalEventModel>> _groupByMonth(
    List<ParentPersonalEventModel> events,
  ) {
    final sortedEvents = [...events]..sort((a, b) => a.date.compareTo(b.date));
    final groups = <DateTime, List<ParentPersonalEventModel>>{};

    for (final event in sortedEvents) {
      final month = DateTime(event.date.year, event.date.month);
      groups.putIfAbsent(month, () => []).add(event);
    }

    return groups;
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({
    required this.month,
    required this.events,
    required this.isExpanded,
    required this.isShowingAll,
    required this.onToggle,
    required this.onToggleShowAll,
    required this.onEdit,
    required this.onDelete,
  });

  final DateTime month;
  final List<ParentPersonalEventModel> events;
  final bool isExpanded;
  final bool isShowingAll;
  final VoidCallback onToggle;
  final VoidCallback onToggleShowAll;
  final ValueChanged<ParentPersonalEventModel> onEdit;
  final ValueChanged<ParentPersonalEventModel> onDelete;

  @override
  Widget build(BuildContext context) {
    final visibleEvents = isShowingAll ? events : events.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _monthYearLabel(month),
                          style: AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _eventCountLabel(events.length),
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  for (final event in visibleEvents) ...[
                    ParentPersonalEventCard(
                      event: event,
                      onEdit: () => onEdit(event),
                      onDelete: () => onDelete(event),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (events.length > 5)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onToggleShowAll,
                        icon: Icon(
                          isShowingAll
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                        ),
                        label: Text(
                          isShowingAll
                              ? 'Réduire'
                              : 'Voir plus (${events.length - 5})',
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineDateLabel extends StatelessWidget {
  const _TimelineDateLabel({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(_dateGroupLabel(date), style: AppTextStyles.cardTitle),
      ],
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _dateGroupLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  if (_isSameDay(date, today)) {
    return 'Aujourd’hui';
  }

  if (_isSameDay(date, tomorrow)) {
    return 'Demain';
  }

  final diff = date.difference(today).inDays;

  if (diff > 1 && diff < 7) {
    return _weekdayLabel(date.weekday);
  }

  if (diff >= 7 && diff < 14) {
    return '${_weekdayLabel(date.weekday)} prochain';
  }

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

String _weekdayLabel(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'Lundi',
    DateTime.tuesday => 'Mardi',
    DateTime.wednesday => 'Mercredi',
    DateTime.thursday => 'Jeudi',
    DateTime.friday => 'Vendredi',
    DateTime.saturday => 'Samedi',
    _ => 'Dimanche',
  };
}

String _monthYearLabel(DateTime date) {
  return '${_monthLabel(date.month)} ${date.year}';
}

String _monthLabel(int month) {
  return switch (month) {
    DateTime.january => 'Janvier',
    DateTime.february => 'Février',
    DateTime.march => 'Mars',
    DateTime.april => 'Avril',
    DateTime.may => 'Mai',
    DateTime.june => 'Juin',
    DateTime.july => 'Juillet',
    DateTime.august => 'Août',
    DateTime.september => 'Septembre',
    DateTime.october => 'Octobre',
    DateTime.november => 'Novembre',
    _ => 'Décembre',
  };
}
