import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/family_event_model.dart';
import '../models/family_member_model.dart';
import '../providers/family_events_provider.dart';
import '../providers/family_members_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';
import '../widgets/family/family_event_card.dart';

enum _AgendaFilter { today, week, upcoming }

class _AgendaTypeFilter {
  const _AgendaTypeFilter({required this.value, required this.label});

  final String value;
  final String label;
}

String _eventCountLabel(int count) {
  return count == 1 ? '1 événement' : '$count événements';
}

String _eventTypeLabel(String type) {
  return switch (type) {
    'sante' => 'Santé',
    'ecole' => 'École',
    'activite' => 'Activité',
    'famille' => 'Famille',
    'anniversaire' => 'Anniversaire',
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

const _familyTypeFilters = [
  _AgendaTypeFilter(value: 'all', label: 'Tous'),
  _AgendaTypeFilter(value: 'sante', label: 'Santé'),
  _AgendaTypeFilter(value: 'ecole', label: 'École'),
  _AgendaTypeFilter(value: 'activite', label: 'Activité'),
  _AgendaTypeFilter(value: 'famille', label: 'Famille'),
  _AgendaTypeFilter(value: 'anniversaire', label: 'Anniversaire'),
  _AgendaTypeFilter(value: 'rendezVous', label: 'Rendez-vous'),
  _AgendaTypeFilter(value: 'autre', label: 'Autre'),
];

class FamilyAgendaPage extends ConsumerStatefulWidget {
  const FamilyAgendaPage({super.key});

  @override
  ConsumerState<FamilyAgendaPage> createState() => _FamilyAgendaPageState();
}

class _FamilyAgendaPageState extends ConsumerState<FamilyAgendaPage> {
  _AgendaFilter _filter = _AgendaFilter.week;
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

  Future<void> _refresh() async {
    ref.invalidate(familyEventsProvider);
    ref.invalidate(upcomingFamilyEventsProvider);
  }

  Future<void> _deleteEvent(FamilyEventModel event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer cet événement ?'),
          content: const Text('Il disparaîtra de l’agenda familial.'),
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

    if (confirmed != true) {
      return;
    }

    await ref.read(familyEventActionProvider.notifier).deleteEvent(event);

    if (!mounted) {
      return;
    }

    final state = ref.read(familyEventActionProvider);

    if (state.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(familyEventsProvider);
    final membersAsync = ref.watch(familyMembersProvider);
    final actionState = ref.watch(familyEventActionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agenda familial'),
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
          Image.asset(AppAssets.backgroundBase03, fit: BoxFit.cover),
          Container(color: Colors.white.withValues(alpha: .40)),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 60),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Organisez votre famille en toute simplicité.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: const Color.fromARGB(255, 68, 93, 117),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  _AgendaHeader(actionState: actionState),
                  const SizedBox(height: 20),
                  _FilterBar(
                    selected: _filter,
                    onChanged: (filter) {
                      setState(() => _filter = filter);
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
                    filters: _familyTypeFilters,
                    selected: _selectedType,
                    onChanged: (type) {
                      setState(() => _selectedType = type);
                    },
                  ),
                  const SizedBox(height: 24),
                  eventsAsync.when(
                    loading: () => const LoadingCard(),
                    error: (error, stackTrace) => EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Oups',
                      message: error.toString(),
                    ),
                    data: (events) {
                      return membersAsync.when(
                        loading: () => const LoadingCard(),
                        error: (error, stackTrace) => EmptyState(
                          icon: Icons.error_outline_rounded,
                          title: 'Oups',
                          message: error.toString(),
                        ),
                        data: (members) {
                          final filteredEvents = _filteredEvents(
                            events,
                            members,
                          );

                          if (filteredEvents.isEmpty) {
                            return Column(
                              children: [
                                const EmptyState(
                                  icon: Icons.event_note_rounded,
                                  title: 'Votre agenda est encore calme.',
                                  message:
                                      'Ajoutez un premier moment important pour votre famille.',
                                ),
                                const SizedBox(height: 20),
                                BoussoleButton(
                                  text: 'Créer un événement',
                                  icon: Icons.add_rounded,
                                  onPressed: () {
                                    context.push('/family-event-form');
                                  },
                                ),
                              ],
                            );
                          }

                          return _Timeline(
                            events: filteredEvents,
                            members: members,
                            showMonthsOnly: _filter == _AgendaFilter.upcoming,
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
                            onEdit: (event) {
                              context.push('/family-event-form', extra: event);
                            },
                            onDelete: _deleteEvent,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/family-event-form');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer'),
      ),
    );
  }

  List<FamilyEventModel> _filteredEvents(
    List<FamilyEventModel> events,
    List<FamilyMemberModel> members,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    return events.where((event) {
      final matchesDate = switch (_filter) {
        _AgendaFilter.today => _isSameDay(event.date, today),
        _AgendaFilter.week =>
          !event.date.isBefore(today) && event.date.isBefore(weekEnd),
        _AgendaFilter.upcoming => !event.date.isBefore(today),
      };

      if (!matchesDate) {
        return false;
      }

      if (_selectedType != 'all' && event.type != _selectedType) {
        return false;
      }

      return _matchesSearch(event, members, _searchQuery);
    }).toList();
  }

  bool _matchesSearch(
    FamilyEventModel event,
    List<FamilyMemberModel> members,
    String query,
  ) {
    final normalizedQuery = _normalizeSearch(query);

    if (normalizedQuery.isEmpty) {
      return true;
    }

    final memberNames = members
        .where((member) => event.memberIds.contains(member.id))
        .map((member) => member.firstName)
        .join(' ');
    final searchableText =
        '${event.title} ${_eventTypeLabel(event.type)} $memberNames';

    return _normalizeSearch(searchableText).contains(normalizedQuery);
  }
}

class _AgendaHeader extends StatelessWidget {
  const _AgendaHeader({required this.actionState});

  final AsyncValue<void> actionState;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final _AgendaFilter selected;
  final ValueChanged<_AgendaFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_AgendaFilter>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: _AgendaFilter.today, label: Text('Aujourd’hui')),
        ButtonSegment(value: _AgendaFilter.week, label: Text('Cette semaine')),
        ButtonSegment(value: _AgendaFilter.upcoming, label: Text('À venir')),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
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

  final List<_AgendaTypeFilter> filters;
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

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.events,
    required this.members,
    required this.showMonthsOnly,
    required this.expandedMonths,
    required this.expandedMonthLists,
    required this.onToggleMonth,
    required this.onToggleMonthList,
    required this.onEdit,
    required this.onDelete,
  });

  final List<FamilyEventModel> events;
  final List<FamilyMemberModel> members;
  final bool showMonthsOnly;
  final Set<DateTime> expandedMonths;
  final Set<DateTime> expandedMonthLists;
  final ValueChanged<DateTime> onToggleMonth;
  final ValueChanged<DateTime> onToggleMonthList;
  final ValueChanged<FamilyEventModel> onEdit;
  final ValueChanged<FamilyEventModel> onDelete;

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
              members: members,
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
            FamilyEventCard(
              event: event,
              members: members,
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

  Map<DateTime, List<FamilyEventModel>> _groupByDate(
    List<FamilyEventModel> events,
  ) {
    final groups = <DateTime, List<FamilyEventModel>>{};

    for (final event in events) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      groups.putIfAbsent(date, () => []).add(event);
    }

    return groups;
  }

  Map<DateTime, List<FamilyEventModel>> _groupByMonth(
    List<FamilyEventModel> events,
  ) {
    final sortedEvents = [...events]..sort((a, b) => a.date.compareTo(b.date));
    final groups = <DateTime, List<FamilyEventModel>>{};

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
    required this.members,
    required this.isExpanded,
    required this.isShowingAll,
    required this.onToggle,
    required this.onToggleShowAll,
    required this.onEdit,
    required this.onDelete,
  });

  final DateTime month;
  final List<FamilyEventModel> events;
  final List<FamilyMemberModel> members;
  final bool isExpanded;
  final bool isShowingAll;
  final VoidCallback onToggle;
  final VoidCallback onToggleShowAll;
  final ValueChanged<FamilyEventModel> onEdit;
  final ValueChanged<FamilyEventModel> onDelete;

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
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  for (final event in visibleEvents) ...[
                    FamilyEventCard(
                      event: event,
                      members: members,
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
