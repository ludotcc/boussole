import 'package:flutter/material.dart';

class BoussoleColors {
  BoussoleColors._();

  // Couleurs principales
  static const Color blue = Color(0xFF2F80ED);
  static const Color turquoise = Color(0xFF2EC5B6);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color yellow = Color(0xFFF7C948);
  static const Color orange = Color(0xFFFF9E42);

  // Couleurs de statut
  static const Color success = Color(0xFF4CAF7D);
  static const Color info = Color(0xFF4DA3FF);
  static const Color warning = Color(0xFFF6B74E);
  static const Color error = Color(0xFFE53773);

  // Couleurs neutres
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color card = Color(0xFFF4F7FB);
  static const Color border = Color(0xFFE6ECF3);

  static const Color textPrimary = Color(0xFF22304A);
  static const Color textSecondary = Color(0xFF5B6B82);
  static const Color textDisabled = Color(0xFFA7B2C2);

  // Dégradé principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [blue, turquoise],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Dégradé magique
  static const LinearGradient magicGradient = LinearGradient(
    colors: [turquoise, violet],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Dégradé solaire
  static const LinearGradient sunGradient = LinearGradient(
    colors: [yellow, orange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
