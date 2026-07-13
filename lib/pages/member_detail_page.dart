import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants/avatar_constants.dart';
import '../models/family_member_model.dart';
import '../models/planning_day_kind.dart';
import '../models/school_academy.dart';
import '../providers/academy_provider.dart';
import '../providers/children_provider.dart';
import '../providers/family_members_provider.dart';
import '../widgets/avatar/avatar_grid.dart';
import '../widgets/boussole_button.dart';
import '../widgets/common/app_card.dart';

class MemberDetailPage extends ConsumerStatefulWidget {
  const MemberDetailPage({super.key, required this.member});

  final FamilyMemberModel member;

  @override
  ConsumerState<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends ConsumerState<MemberDetailPage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _ageController;
  late String _profileType;
  late String _selectedAvatar;
  late String _academyId;
  late Map<int, String> _weeklyRhythmByWeekday;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.member.firstName);
    _ageController = TextEditingController(
      text: widget.member.age?.toString() ?? '',
    );
    _profileType = _normalizedProfileType(widget.member);
    _academyId = widget.member.academyId ?? defaultSchoolAcademyId;
    _weeklyRhythmByWeekday = widget.member.weeklyRhythmByWeekday.isEmpty
        ? _defaultWeeklyRhythm()
        : {...widget.member.weeklyRhythmByWeekday};
    _selectedAvatar = widget.member.avatar.isEmpty
        ? AvatarConstants.avatarsForProfileType(_profileType).first.id
        : widget.member.avatar;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final firstName = _firstNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (age == null) {
      _showMessage('Merci d’indiquer un âge.');
      return;
    }

    await ref
        .read(familyMemberActionProvider.notifier)
        .updateMember(
          member: widget.member,
          firstName: firstName,
          age: age,
          avatar: _selectedAvatar,
          profileType: _profileType,
        );

    if (!mounted) {
      return;
    }

    final state = ref.read(familyMemberActionProvider);

    if (state.hasError) {
      _showMessage(state.error.toString());
      return;
    }

    if (!widget.member.isAdult) {
      await ref
          .read(childWeeklyRhythmProvider.notifier)
          .updateWeeklyRhythm(
            childId: widget.member.id,
            weeklyRhythmByWeekday: _weeklyRhythmByWeekday,
            academyId: _academyId,
          );

      if (!mounted) {
        return;
      }

      final childState = ref.read(childWeeklyRhythmProvider);

      if (childState.hasError) {
        _showMessage(childState.error.toString());
        return;
      }

      ref.invalidate(familyMembersProvider);
    }

    context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer ce membre ?'),
          content: const Text('Cette action retirera le profil de la famille.'),
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

    await ref
        .read(familyMemberActionProvider.notifier)
        .deleteMember(widget.member);

    if (!mounted) {
      return;
    }

    final state = ref.read(familyMemberActionProvider);

    if (state.hasError) {
      _showMessage(state.error.toString());
      return;
    }

    context.pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(familyMemberActionProvider);
    final childActionState = ref.watch(childWeeklyRhythmProvider);
    final academiesAsync = ref.watch(schoolAcademiesProvider);
    final avatars = _avatarsForCurrentRole();
    final isLoading = actionState.isLoading || childActionState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Fiche membre'), elevation: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(widget.member.firstName, style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Ajustez doucement son profil.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration: _inputDecoration(
                      label: 'Prénom',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: 'Âge',
                      icon: Icons.cake_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _profileType,
                    decoration: _inputDecoration(
                      label: 'Rôle',
                      icon: Icons.family_restroom_rounded,
                    ),
                    items: _roleItems(),
                    onChanged: actionState.isLoading
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              _profileType = value;
                              final nextAvatars =
                                  AvatarConstants.avatarsForProfileType(value);
                              if (!nextAvatars.any(
                                (avatar) => avatar.id == _selectedAvatar,
                              )) {
                                _selectedAvatar = nextAvatars.first.id;
                              }
                            });
                          },
                  ),
                  const SizedBox(height: 20),
                  AvatarGrid(
                    selectedAvatarId: _selectedAvatar,
                    avatars: avatars,
                    onAvatarSelected: actionState.isLoading
                        ? (_) {}
                        : (avatarId) {
                            setState(() {
                              _selectedAvatar = avatarId;
                            });
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!widget.member.isAdult) ...[
              _AcademySection(
                academyId: _academyId,
                academies: academiesAsync.valueOrNull ?? _fallbackAcademies,
                isLoading: isLoading,
                onChanged: (value) => setState(() => _academyId = value),
              ),
              const SizedBox(height: 20),
              _WeeklyRhythmSection(
                rhythms: _weeklyRhythmByWeekday,
                isLoading: isLoading,
                includeVacation: false,
                onChanged: (weekday, dayKind) {
                  setState(() {
                    _weeklyRhythmByWeekday = {
                      ..._weeklyRhythmByWeekday,
                      weekday: dayKind.value,
                    };
                  });
                },
              ),
              const SizedBox(height: 20),
            ],
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              BoussoleButton(
                text: 'Enregistrer',
                icon: Icons.check_rounded,
                onPressed: _save,
              ),
              const SizedBox(height: 12),
              BoussoleButton(
                text: 'Supprimer le membre',
                icon: Icons.delete_outline_rounded,
                isPrimary: false,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<AvatarItem> _avatarsForCurrentRole() {
    final avatars = AvatarConstants.avatarsForProfileType(_profileType);

    if (avatars.any((avatar) => avatar.id == _selectedAvatar)) {
      return avatars;
    }

    return [
      ...avatars,
      AvatarConstants.allAvatars.firstWhere(
        (avatar) => avatar.id == _selectedAvatar,
        orElse: () => avatars.first,
      ),
    ];
  }

  String _normalizedProfileType(FamilyMemberModel member) {
    if (member.isAdult) {
      return switch (member.profileType) {
        'maman' => 'maman',
        _ => 'papa',
      };
    }

    return switch (member.profileType) {
      'soeur' => 'soeur',
      'baby' => 'baby',
      _ => 'frere',
    };
  }

  List<DropdownMenuItem<String>> _roleItems() {
    final roles = widget.member.isAdult
        ? const {'papa': 'Papa', 'maman': 'Maman'}
        : const {'frere': 'Frère', 'soeur': 'Sœur', 'baby': 'Bébé'};

    return [
      for (final entry in roles.entries)
        DropdownMenuItem(value: entry.key, child: Text(entry.value)),
    ];
  }

  Map<int, String> _defaultWeeklyRhythm() {
    return const {
      DateTime.monday: 'school',
      DateTime.tuesday: 'school',
      DateTime.wednesday: 'wednesday',
      DateTime.thursday: 'school',
      DateTime.friday: 'school',
      DateTime.saturday: 'weekend',
      DateTime.sunday: 'weekend',
    };
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

class _AcademySection extends StatelessWidget {
  const _AcademySection({
    required this.academyId,
    required this.academies,
    required this.isLoading,
    required this.onChanged,
  });

  final String academyId;
  final List<SchoolAcademy> academies;
  final bool isLoading;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedAcademy = academies.any((academy) => academy.id == academyId)
        ? academyId
        : defaultSchoolAcademyId;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Académie', style: AppTextStyles.cardTitle),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedAcademy,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.school_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            items: [
              for (final academy in academies)
                DropdownMenuItem(value: academy.id, child: Text(academy.label)),
            ],
            onChanged: isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    onChanged(value);
                  },
          ),
        ],
      ),
    );
  }
}

class _WeeklyRhythmSection extends StatelessWidget {
  const _WeeklyRhythmSection({
    required this.rhythms,
    required this.isLoading,
    required this.onChanged,
    this.includeVacation = false,
  });

  final Map<int, String> rhythms;
  final bool isLoading;
  final bool includeVacation;
  final void Function(int weekday, PlanningDayKind dayKind) onChanged;

  @override
  Widget build(BuildContext context) {
    final dayKinds = PlanningDayKind.values
        .where(
          (dayKind) => includeVacation || dayKind != PlanningDayKind.vacation,
        )
        .toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rythme hebdomadaire', style: AppTextStyles.cardTitle),
          const SizedBox(height: 12),
          for (final weekday in _weekdayLabels.entries) ...[
            Row(
              children: [
                SizedBox(
                  width: 82,
                  child: Text(
                    weekday.value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<PlanningDayKind>(
                    initialValue: PlanningDayKind.fromValue(
                      rhythms[weekday.key],
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    items: [
                      for (final dayKind in dayKinds)
                        DropdownMenuItem(
                          value: dayKind,
                          child: Text(dayKind.label),
                        ),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value == null) return;
                            onChanged(weekday.key, value);
                          },
                  ),
                ),
              ],
            ),
            if (weekday.key != DateTime.sunday) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

const _weekdayLabels = {
  DateTime.monday: 'Lundi',
  DateTime.tuesday: 'Mardi',
  DateTime.wednesday: 'Mercredi',
  DateTime.thursday: 'Jeudi',
  DateTime.friday: 'Vendredi',
  DateTime.saturday: 'Samedi',
  DateTime.sunday: 'Dimanche',
};

const _fallbackAcademies = [
  SchoolAcademy(id: defaultSchoolAcademyId, label: 'Non renseignée', zone: ''),
];
