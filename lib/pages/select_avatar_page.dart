import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/avatar_constants.dart';
import '../providers/family_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/avatar/avatar_grid.dart';
import '../widgets/boussole_button.dart';
import '../widgets/welcome/welcome_background.dart';

class SelectAvatarPage extends ConsumerStatefulWidget {
  const SelectAvatarPage({super.key, required this.isParent});

  final bool isParent;

  @override
  ConsumerState<SelectAvatarPage> createState() => _SelectAvatarPageState();
}

class _SelectAvatarPageState extends ConsumerState<SelectAvatarPage> {
  String? _selectedAvatar;
  bool _isLoading = false;

  Future<void> _continue({String nextRoute = '/home'}) async {
    if (_selectedAvatar == null) return;

    final session = ref.read(sessionProvider);

    if (session == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Session introuvable.")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isParent) {
        await ref
            .read(familyRepositoryProvider)
            .saveParentAvatar(
              familyId: session.familyId,
              parentId: session.userId,
              avatarId: _selectedAvatar!,
            );

        ref.read(sessionProvider.notifier).updateAvatar(_selectedAvatar!);

        if (!mounted) return;

        context.go(nextRoute);
      } else {
        if (!mounted) return;

        context.go(nextRoute);
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
    return Scaffold(
      body: Stack(
        children: [
          const WelcomeBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isParent
                        ? "Choisissez votre avatar"
                        : "Choisissez un avatar",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20305E),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.isParent
                        ? "Votre avatar représentera votre profil."
                        : "Choisissez un avatar pour votre enfant.",
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF4F5D75),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: SingleChildScrollView(
                      child: AvatarGrid(
                        selectedAvatarId: _selectedAvatar,
                        avatars: widget.isParent
                            ? AvatarConstants.adultAvatars
                            : AvatarConstants.avatars,
                        onAvatarSelected: (avatarId) {
                          setState(() {
                            _selectedAvatar = avatarId;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : widget.isParent
                      ? Column(
                          children: [
                            BoussoleButton(
                              text: "Ajouter un autre adulte",
                              icon: Icons.add_rounded,
                              onPressed: _selectedAvatar == null
                                  ? null
                                  : () => _continue(nextRoute: '/create-adult'),
                            ),
                            const SizedBox(height: 14),
                            BoussoleButton(
                              text: "Ajouter un enfant",
                              icon: Icons.child_care_rounded,
                              isPrimary: false,
                              onPressed: _selectedAvatar == null
                                  ? null
                                  : () => _continue(nextRoute: '/create-child'),
                            ),
                            const SizedBox(height: 14),
                            BoussoleButton(
                              text: "Terminer la famille",
                              icon: Icons.check_rounded,
                              isPrimary: false,
                              onPressed: _selectedAvatar == null
                                  ? null
                                  : () => _continue(nextRoute: '/home'),
                            ),
                          ],
                        )
                      : BoussoleButton(
                          text: "Continuer",
                          icon: Icons.arrow_forward,
                          onPressed: _selectedAvatar == null
                              ? null
                              : () => _continue(),
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
