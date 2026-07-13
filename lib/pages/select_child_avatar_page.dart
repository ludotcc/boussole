import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/planning_day_kind.dart';
import '../models/school_academy.dart';
import '../providers/academy_provider.dart';
import '../providers/child_creation_provider.dart';
import '../providers/children_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/welcome/welcome_background.dart';

class SelectChildAvatarPage extends ConsumerStatefulWidget {
  const SelectChildAvatarPage({super.key});

  @override
  ConsumerState<SelectChildAvatarPage> createState() =>
      _SelectChildAvatarPageState();
}

class _SelectChildAvatarPageState extends ConsumerState<SelectChildAvatarPage> {
  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _profileType = 'child';
  String _academyId = defaultSchoolAcademyId;
  Map<int, String> _weeklyRhythmByWeekday = const {
    DateTime.monday: 'school',
    DateTime.tuesday: 'school',
    DateTime.wednesday: 'wednesday',
    DateTime.thursday: 'school',
    DateTime.friday: 'school',
    DateTime.saturday: 'weekend',
    DateTime.sunday: 'weekend',
  };
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _ageController.dispose();
    super.dispose();
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

  Future<void> _saveChild({required bool addAnother}) async {
    final draft = ref.read(childCreationProvider);
    final firstName = _firstNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (draft == null || draft.avatar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Merci de choisir un avatar.")),
      );
      context.go('/create-child');
      return;
    }

    if (firstName.isEmpty || age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Merci de compléter correctement tous les champs."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      ref
          .read(childCreationProvider.notifier)
          .updateInfo(
            firstName: firstName,
            age: age,
            profileType: _profileType,
          );
      ref.read(childCreationProvider.notifier).updateAcademy(_academyId);
      ref
          .read(childCreationProvider.notifier)
          .updateWeeklyRhythm(_weeklyRhythmByWeekday);

      await ref.read(childRegistrationProvider.notifier).finishRegistration();

      if (!mounted) return;

      final registrationState = ref.read(childRegistrationProvider);

      if (registrationState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(registrationState.error.toString())),
        );
        return;
      }

      ref.invalidate(childrenProvider);

      if (addAnother) {
        context.go('/create-child');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(childCreationProvider);
    final academiesAsync = ref.watch(schoolAcademiesProvider);
    final academies = academiesAsync.valueOrNull ?? _fallbackAcademies;

    return Scaffold(
      body: Stack(
        children: [
          const WelcomeBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profil de l'enfant",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20305E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ajoutez les informations de votre enfant.",
                    style: TextStyle(fontSize: 17, color: Color(0xFF4F5D75)),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .95),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (draft?.avatar.isNotEmpty == true) ...[
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: const Color(0xFFEFF5FF),
                            backgroundImage: AssetImage(
                              'assets/images/avatars/${draft!.avatar}.png',
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        TextField(
                          controller: _firstNameController,
                          decoration: _inputDecoration(
                            label: "Prénom",
                            icon: Icons.child_care,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: "Âge",
                            icon: Icons.cake_outlined,
                          ),
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          initialValue: _profileType,
                          decoration: _inputDecoration(
                            label: "Rôle",
                            icon: Icons.family_restroom,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'child',
                              child: Text('Enfant'),
                            ),
                            DropdownMenuItem(
                              value: 'baby',
                              child: Text('Bébé'),
                            ),
                          ],
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  if (value == null) return;

                                  setState(() {
                                    _profileType = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 24),
                        _OnboardingStepTitle(
                          number: '1',
                          title: "Choix de l'académie",
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _academyId,
                          decoration: _inputDecoration(
                            label: "Académie",
                            icon: Icons.school_rounded,
                          ),
                          items: [
                            for (final academy in academies)
                              DropdownMenuItem(
                                value: academy.id,
                                child: Text(academy.label),
                              ),
                          ],
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() => _academyId = value);
                                },
                        ),
                        const SizedBox(height: 24),
                        _OnboardingStepTitle(
                          number: '2',
                          title: 'Rythme hebdomadaire',
                        ),
                        const SizedBox(height: 12),
                        _WeeklyRhythmFields(
                          rhythms: _weeklyRhythmByWeekday,
                          isLoading: _isLoading,
                          onChanged: (weekday, dayKind) {
                            setState(() {
                              _weeklyRhythmByWeekday = {
                                ..._weeklyRhythmByWeekday,
                                weekday: dayKind.value,
                              };
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  BoussoleButton(
                                    text: "Ajouter un autre enfant",
                                    icon: Icons.add_rounded,
                                    onPressed: () =>
                                        _saveChild(addAnother: true),
                                  ),
                                  const SizedBox(height: 14),
                                  BoussoleButton(
                                    text: "Terminer",
                                    icon: Icons.check_rounded,
                                    isPrimary: false,
                                    onPressed: () =>
                                        _saveChild(addAnother: false),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStepTitle extends StatelessWidget {
  const _OnboardingStepTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFF20305E),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF20305E),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeeklyRhythmFields extends StatelessWidget {
  const _WeeklyRhythmFields({
    required this.rhythms,
    required this.isLoading,
    required this.onChanged,
  });

  final Map<int, String> rhythms;
  final bool isLoading;
  final void Function(int weekday, PlanningDayKind dayKind) onChanged;

  @override
  Widget build(BuildContext context) {
    final dayKinds = PlanningDayKind.values
        .where((dayKind) => dayKind != PlanningDayKind.vacation)
        .toList();

    return Column(
      children: [
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
                  initialValue: PlanningDayKind.fromValue(rhythms[weekday.key]),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
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
