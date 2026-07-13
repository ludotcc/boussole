import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants/avatar_constants.dart';
import '../models/child_model.dart';
import '../models/parent_model.dart';
import '../providers/adult_creation_provider.dart';
import '../providers/child_creation_provider.dart';
import '../providers/children_provider.dart';
import '../providers/family_provider.dart';
import '../widgets/avatar/avatar_grid.dart';
import '../widgets/boussole_button.dart';
import '../widgets/welcome/welcome_background.dart';

class FamilyMembersPage extends ConsumerStatefulWidget {
  const FamilyMembersPage({super.key});

  @override
  ConsumerState<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

class _FamilyMembersPageState extends ConsumerState<FamilyMembersPage> {
  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _profileType = 'papa';
  String? _selectedAvatar;
  bool _showForm = false;
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

  Future<void> _addMember() async {
    final age = int.tryParse(_ageController.text.trim());
    final avatar = _selectedAvatar;

    if (_firstNameController.text.trim().isEmpty ||
        age == null ||
        age <= 0 ||
        avatar == null) {
      _showMessage("Merci de compléter correctement tous les champs.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_profileType == 'papa' || _profileType == 'maman') {
        await ref
            .read(adultRegistrationProvider.notifier)
            .createAdultProfile(
              firstName: _firstNameController.text,
              age: age,
              profileType: _profileType,
              avatar: avatar,
            );
      } else {
        await ref
            .read(childRegistrationProvider.notifier)
            .createChildProfile(
              firstName: _firstNameController.text,
              age: age,
              avatar: avatar,
              profileType: _profileType,
            );
      }

      if (!mounted) return;

      ref.invalidate(adultProfilesProvider);
      ref.invalidate(familyChildMembersProvider);
      ref.invalidate(childrenProvider);
      _resetForm();
      _showMessage("Membre ajouté.");
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString());
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _firstNameController.clear();
      _ageController.clear();
      _profileType = 'papa';
      _selectedAvatar = null;
      _showForm = false;
    });
  }

  void _finish({required bool hasMembers}) {
    if (!hasMembers) {
      _showMessage("Ajoutez au moins un membre avant de terminer.");
      return;
    }

    context.go('/home');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final adultsAsync = ref.watch(adultProfilesProvider);
    final childrenAsync = ref.watch(familyChildMembersProvider);
    final adults = adultsAsync.valueOrNull ?? const <ParentModel>[];
    final children = childrenAsync.valueOrNull ?? const <ChildModel>[];
    final hasMembers = adults.isNotEmpty || children.isNotEmpty;

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
                    "Membres de la famille",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20305E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ajoutez les profils qui utiliseront Boussole.",
                    style: TextStyle(fontSize: 17, color: Color(0xFF4F5D75)),
                  ),
                  const SizedBox(height: 24),
                  _MembersList(adults: adults, children: children),
                  const SizedBox(height: 20),
                  if (_showForm) _memberForm(),
                  if (!_showForm)
                    BoussoleButton(
                      text: "Ajouter un membre",
                      icon: Icons.add_rounded,
                      onPressed: () {
                        setState(() {
                          _showForm = true;
                        });
                      },
                    ),
                  const SizedBox(height: 14),
                  BoussoleButton(
                    text: "Terminer",
                    icon: Icons.check_rounded,
                    isPrimary: false,
                    onPressed: () => _finish(hasMembers: hasMembers),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberForm() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
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
          DropdownButtonFormField<String>(
            initialValue: _profileType,
            decoration: _inputDecoration(
              label: "Rôle",
              icon: Icons.family_restroom,
            ),
            items: [
              _roleMenuItem(value: 'papa', label: 'Papa'),
              _roleMenuItem(value: 'maman', label: 'Maman'),
              _roleMenuItem(value: 'frere', label: 'Frère'),
              _roleMenuItem(value: 'soeur', label: 'Sœur'),
              _roleMenuItem(value: 'baby', label: 'Bébé'),
            ],
            onChanged: _isLoading
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      _profileType = value;
                      _selectedAvatar = null;
                    });
                  },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _firstNameController,
            decoration: _inputDecoration(
              label: "Prénom",
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(
              label: "Âge",
              icon: Icons.cake_outlined,
            ),
          ),
          const SizedBox(height: 20),
          AvatarGrid(
            selectedAvatarId: _selectedAvatar,
            avatars: AvatarConstants.avatarsForProfileType(_profileType),
            onAvatarSelected: (avatarId) {
              setState(() {
                _selectedAvatar = avatarId;
              });
            },
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    BoussoleButton(
                      text: "Ajouter ce membre",
                      icon: Icons.add_rounded,
                      onPressed: _addMember,
                    ),
                    const SizedBox(height: 12),
                    BoussoleButton(
                      text: "Annuler",
                      icon: Icons.close_rounded,
                      isPrimary: false,
                      onPressed: _resetForm,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _roleMenuItem({
    required String value,
    required String label,
  }) {
    return DropdownMenuItem(value: value, child: Text(label));
  }
}

class _MembersList extends StatelessWidget {
  const _MembersList({required this.adults, required this.children});

  final List<ParentModel> adults;
  final List<ChildModel> children;

  @override
  Widget build(BuildContext context) {
    if (adults.isEmpty && children.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          "Aucun membre ajouté pour le moment.",
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        for (final adult in adults)
          _MemberTile(
            avatar: adult.avatar,
            firstName: adult.firstName,
            roleLabel: _roleLabel(adult.profileType),
            age: adult.age,
          ),
        for (final child in children)
          _MemberTile(
            avatar: child.avatar,
            firstName: child.firstName,
            roleLabel: _roleLabel(child.profileType),
            age: child.age,
          ),
      ],
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

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.avatar,
    required this.firstName,
    required this.roleLabel,
    required this.age,
  });

  final String avatar;
  final String firstName;
  final String roleLabel;
  final int? age;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.cardSecondary,
            backgroundImage: avatar.isEmpty
                ? null
                : AssetImage('assets/images/avatars/$avatar.png'),
            child: avatar.isEmpty ? const Icon(Icons.person_rounded) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(firstName, style: AppTextStyles.cardTitle),
                const SizedBox(height: 3),
                Text(
                  age == null ? roleLabel : '$roleLabel · $age ans',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
