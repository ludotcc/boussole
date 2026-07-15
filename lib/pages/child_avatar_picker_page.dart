import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../models/family_member_model.dart';
import '../providers/family_members_provider.dart';
import '../widgets/avatar/avatar_grid.dart';
import '../widgets/common/boussole_app_bar.dart';

class ChildAvatarPickerPage extends ConsumerStatefulWidget {
  const ChildAvatarPickerPage({super.key, required this.member});

  final FamilyMemberModel member;

  @override
  ConsumerState<ChildAvatarPickerPage> createState() =>
      _ChildAvatarPickerPageState();
}

class _ChildAvatarPickerPageState extends ConsumerState<ChildAvatarPickerPage> {
  late String _selectedAvatarId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedAvatarId = widget.member.avatar;
  }

  Future<void> _selectAvatar(String avatarId) async {
    if (_isSaving || avatarId == _selectedAvatarId) {
      return;
    }

    final previousAvatarId = _selectedAvatarId;

    setState(() {
      _selectedAvatarId = avatarId;
      _isSaving = true;
    });

    await ref
        .read(familyMemberActionProvider.notifier)
        .updateAvatar(member: widget.member, avatar: avatarId);

    if (!mounted) {
      return;
    }

    final actionState = ref.read(familyMemberActionProvider);

    if (actionState.hasError) {
      setState(() {
        _selectedAvatarId = previousAvatarId;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Nous n'avons pas réussi à changer ton avatar cette fois.",
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BoussoleAppBar(title: 'Choisir mon avatar'),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choisis celui qui te ressemble',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ton choix est enregistré automatiquement.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  IgnorePointer(
                    ignoring: _isSaving,
                    child: AvatarGrid(
                      selectedAvatarId: _selectedAvatarId,
                      onAvatarSelected: _selectAvatar,
                    ),
                  ),
                ],
              ),
            ),
            if (_isSaving)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x22000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
