import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/child_creation_provider.dart';
import '../widgets/avatar/avatar_grid.dart';
import '../widgets/boussole_button.dart';
import '../widgets/welcome/welcome_background.dart';

class CreateChildPage extends ConsumerStatefulWidget {
  const CreateChildPage({super.key});

  @override
  ConsumerState<CreateChildPage> createState() => _CreateChildPageState();
}

class _CreateChildPageState extends ConsumerState<CreateChildPage> {
  String? _selectedAvatar;

  void _continue() {
    final avatar = _selectedAvatar;

    if (avatar == null) {
      return;
    }

    ref.read(childCreationProvider.notifier).createAvatarDraft(avatar: avatar);

    context.go('/select-child-avatar');
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
                  BoussoleButton(
                    text: "Continuer",
                    icon: Icons.arrow_forward,
                    onPressed: _selectedAvatar == null ? null : _continue,
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
