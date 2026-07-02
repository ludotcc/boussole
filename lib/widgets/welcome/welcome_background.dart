import 'package:flutter/material.dart';

class WelcomeBackground extends StatelessWidget {
  const WelcomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        "assets/images/backgrounds/background_lever_soleil.png",
        fit: BoxFit.cover,
      ),
    );
  }
}
