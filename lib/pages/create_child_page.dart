import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/child_creation_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/welcome/welcome_background.dart';

class CreateChildPage extends ConsumerStatefulWidget {
  const CreateChildPage({super.key});

  @override
  ConsumerState<CreateChildPage> createState() => _CreateChildPageState();
}

class _CreateChildPageState extends ConsumerState<CreateChildPage> {
  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();

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

  void _continue() {
    final firstName = _firstNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (firstName.isEmpty || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Merci de compléter correctement tous les champs."),
        ),
      );
      return;
    }

    ref
        .read(childCreationProvider.notifier)
        .createDraft(firstName: firstName, age: age);

    context.go('/select-child-avatar');
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
                    "Premier enfant",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20305E),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Créons le profil de votre premier enfant.",
                    style: TextStyle(fontSize: 17, color: Color(0xFF4F5D75)),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.95),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
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

                        const SizedBox(height: 30),

                        BoussoleButton(
                          text: "Continuer",
                          icon: Icons.arrow_forward,
                          onPressed: _continue,
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
