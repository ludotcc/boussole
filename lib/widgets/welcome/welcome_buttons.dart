import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../boussole_button.dart';

class WelcomeButtons extends StatelessWidget {
  const WelcomeButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BoussoleButton(
            text: "Retrouver ma famille",
            icon: Icons.groups_rounded,
            onPressed: () {
              context.go('/login');
            },
          ),

          const SizedBox(height: 14),

          BoussoleButton(
            text: "Créer une famille",
            icon: Icons.home_rounded,
            isPrimary: false,
            onPressed: () {
              context.go('/create-family');
            },
          ),
        ],
      ),
    );
  }
}
