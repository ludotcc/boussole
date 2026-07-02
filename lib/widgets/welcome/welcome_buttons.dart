import 'package:flutter/material.dart';

import '../boussole_button.dart';

class WelcomeButtons extends StatelessWidget {
  const WelcomeButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BoussoleButton(
          text: "Retrouver ma famille",
          icon: Icons.groups_rounded,
          onPressed: () {},
        ),

        const SizedBox(height: 18),

        BoussoleButton(
          text: "Créer une famille",
          icon: Icons.home_rounded,
          isPrimary: false,
          onPressed: () {},
        ),
      ],
    );
  }
}
