import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/family_member_model.dart';
import '../providers/adult_creation_provider.dart';
import '../providers/child_creation_provider.dart';
import '../providers/children_provider.dart';
import '../providers/family_provider.dart';
import '../providers/family_members_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/avatar_circle.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';
import '../widgets/family/family_member_form_card.dart';

class FamilyMembersManagementPage extends ConsumerStatefulWidget {
  const FamilyMembersManagementPage({super.key});

  @override
  ConsumerState<FamilyMembersManagementPage> createState() =>
      _FamilyMembersManagementPageState();
}

class _FamilyMembersManagementPageState
    extends ConsumerState<FamilyMembersManagementPage> {
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

  Future<void> _addMember() async {
    final firstName = _firstNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final avatar = _selectedAvatar;

    if (firstName.isEmpty || age == null || age <= 0 || avatar == null) {
      _showMessage('Merci de compléter correctement le membre.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_profileType == 'papa' || _profileType == 'maman') {
      await ref
          .read(adultRegistrationProvider.notifier)
          .createAdultProfile(
            firstName: firstName,
            age: age,
            profileType: _profileType,
            avatar: avatar,
          );
    } else {
      await ref
          .read(childRegistrationProvider.notifier)
          .createChildProfile(
            firstName: firstName,
            age: age,
            avatar: avatar,
            profileType: _profileType,
          );
    }

    if (!mounted) {
      return;
    }

    final adultState = ref.read(adultRegistrationProvider);
    final childState = ref.read(childRegistrationProvider);
    final error = _profileType == 'papa' || _profileType == 'maman'
        ? adultState.error
        : childState.error;

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      _showMessage(error.toString());
      return;
    }

    _resetForm();
    _refreshMembers();
    _showMessage('Membre ajouté.');
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

  void _refreshMembers() {
    ref.invalidate(familyMembersProvider);
    ref.invalidate(adultProfilesProvider);
    ref.invalidate(familyChildMembersProvider);
    ref.invalidate(childrenProvider);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(familyMembersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mes membres'), elevation: 0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.backgroundBase01, fit: BoxFit.cover),

          Container(color: Colors.white.withValues(alpha: .30)),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshMembers();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Toute la famille',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: const Color.fromARGB(255, 68, 93, 117),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez ou ajustez les profils de la famille.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 68, 93, 117),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  membersAsync.when(
                    loading: () => const LoadingCard(),
                    error: (error, stackTrace) => EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Oups',
                      message: error.toString(),
                    ),
                    data: (members) => _MembersList(members: members),
                  ),

                  const SizedBox(height: 20),

                  if (_showForm)
                    FamilyMemberFormCard(
                      firstNameController: _firstNameController,
                      ageController: _ageController,
                      profileType: _profileType,
                      selectedAvatar: _selectedAvatar,
                      isLoading: _isLoading,
                      onProfileTypeChanged: (value) {
                        setState(() {
                          _profileType = value;
                          _selectedAvatar = null;
                        });
                      },
                      onAvatarSelected: (avatarId) {
                        setState(() {
                          _selectedAvatar = avatarId;
                        });
                      },
                      onSubmit: _addMember,
                      onCancel: _resetForm,
                    ),

                  if (!_showForm)
                    BoussoleButton(
                      text: 'Ajouter un membre',
                      icon: Icons.add_rounded,
                      onPressed: () {
                        setState(() {
                          _showForm = true;
                        });
                      },
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

class _MembersList extends StatelessWidget {
  const _MembersList({required this.members});

  final List<FamilyMemberModel> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const EmptyState(
        icon: Icons.family_restroom_rounded,
        title: 'Aucun membre',
        message: 'Ajoutez un premier profil.',
      );
    }

    return Column(
      children: [
        for (final member in members) ...[
          AppCard(
            padding: const EdgeInsets.all(14),
            onTap: () {
              context.push('/member-detail', extra: member);
            },
            child: Row(
              children: [
                AvatarCircle(imagePath: member.avatar, radius: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.firstName, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 3),
                      Text(
                        '${_roleLabel(member.profileType)} · ${member.age ?? '-'} ans',
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
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
