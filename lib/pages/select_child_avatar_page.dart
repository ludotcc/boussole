import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/child_creation_provider.dart';
import '../providers/family_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/avatar/avatar_grid.dart';
import '../widgets/boussole_button.dart';
import '../widgets/welcome/welcome_background.dart';

class SelectChildAvatarPage extends ConsumerStatefulWidget {
  const SelectChildAvatarPage({super.key});

  @override
  ConsumerState<SelectChildAvatarPage> createState() =>
      _SelectChildAvatarPageState();
}

class _SelectChildAvatarPageState extends ConsumerState<SelectChildAvatarPage> {
  String? _selectedAvatar;
  bool _isLoading = false;

  Future<void> _finishRegistration() async {
    if (_selectedAvatar == null) return;

    final session = ref.read(sessionProvider);
    final draft = ref.read(childCreationProvider);

    if (session == null || draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de terminer l'inscription.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mise à jour du brouillon avec l'avatar choisi
      ref.read(childCreationProvider.notifier).updateAvatar(_selectedAvatar!);

      // Création de l'enfant dans Firestore
      await ref
          .read(familyRepositoryProvider)
          .createChild(
            familyId: session.familyId,
            firstName: draft.firstName,
            age: draft.age,
            avatar: _selectedAvatar!,
          );

      // Nettoyage du provider temporaire
      ref.read(childCreationProvider.notifier).clear();

      if (!mounted) return;

      // Direction le Dashboard
      context.go('/home');
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
                  const Text(
                    "Avatar de l'enfant",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20305E),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Choisissez un avatar pour votre enfant.",
                    style: TextStyle(fontSize: 17, color: Color(0xFF4F5D75)),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: SingleChildScrollView(
                      child: AvatarGrid(
                        selectedAvatarId: _selectedAvatar,
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
                      : BoussoleButton(
                          text: "Terminer",
                          icon: Icons.check,
                          onPressed: _selectedAvatar == null
                              ? null
                              : _finishRegistration,
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
