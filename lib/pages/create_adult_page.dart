import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/avatar_constants.dart';
import '../providers/adult_creation_provider.dart';
import '../widgets/avatar/avatar_grid.dart';
import '../widgets/boussole_button.dart';
import '../widgets/welcome/welcome_background.dart';

class CreateAdultPage extends ConsumerStatefulWidget {
  const CreateAdultPage({super.key});

  @override
  ConsumerState<CreateAdultPage> createState() => _CreateAdultPageState();
}

class _CreateAdultPageState extends ConsumerState<CreateAdultPage> {
  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _profileType = 'papa';
  String? _selectedAvatar;
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

  Future<void> _saveAdult({required String nextRoute}) async {
    final age = int.tryParse(_ageController.text.trim());
    final avatar = _selectedAvatar;

    if (_firstNameController.text.trim().isEmpty ||
        age == null ||
        age <= 0 ||
        avatar == null) {
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
      await ref
          .read(adultRegistrationProvider.notifier)
          .createAdultProfile(
            firstName: _firstNameController.text,
            age: age,
            profileType: _profileType,
            avatar: avatar,
          );

      if (!mounted) return;

      final registrationState = ref.read(adultRegistrationProvider);

      if (registrationState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(registrationState.error.toString())),
        );
        return;
      }

      context.go(nextRoute);
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profil adulte",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20305E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ajoutez un autre adulte à la famille.",
                    style: TextStyle(fontSize: 17, color: Color(0xFF4F5D75)),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _profileType,
                    decoration: _inputDecoration(
                      label: "Rôle",
                      icon: Icons.family_restroom,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'papa', child: Text('Papa')),
                      DropdownMenuItem(value: 'maman', child: Text('Maman')),
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
                  const SizedBox(height: 24),
                  AvatarGrid(
                    selectedAvatarId: _selectedAvatar,
                    avatars: AvatarConstants.avatarsForProfileType(
                      _profileType,
                    ),
                    onAvatarSelected: (avatarId) {
                      setState(() {
                        _selectedAvatar = avatarId;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            BoussoleButton(
                              text: "Ajouter un autre adulte",
                              icon: Icons.add_rounded,
                              onPressed: () =>
                                  _saveAdult(nextRoute: '/create-adult'),
                            ),
                            const SizedBox(height: 14),
                            BoussoleButton(
                              text: "Ajouter un enfant",
                              icon: Icons.child_care_rounded,
                              isPrimary: false,
                              onPressed: () =>
                                  _saveAdult(nextRoute: '/create-child'),
                            ),
                            const SizedBox(height: 14),
                            BoussoleButton(
                              text: "Terminer la famille",
                              icon: Icons.check_rounded,
                              isPrimary: false,
                              onPressed: () => _saveAdult(nextRoute: '/home'),
                            ),
                          ],
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
