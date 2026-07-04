import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Couleurs principales Boussole
  // ---------------------------------------------------------------------------

  static const Color primary = Color(0xFF2F80ED); // Bleu Boussole
  static const Color turquoise = Color(0xFF2EC5B6);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color gold = Color(0xFFF7C948);
  static const Color softOrange = Color(0xFFFF9E42);

  // ---------------------------------------------------------------------------
  // Couleurs de statut
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF4CAF7D);
  static const Color info = Color(0xFF4DA3FF);
  static const Color warning = Color(0xFFF6B74E);
  static const Color error = Color(0xFFE57373);

  // ---------------------------------------------------------------------------
  // Couleurs neutres
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color cardSecondary = Color(0xFFF4F7FB);

  static const Color border = Color(0xFFE6ECF3);

  static const Color textPrimary = Color(0xFF22304A);
  static const Color textSecondary = Color(0xFF5B6B82);
  static const Color textDisabled = Color(0xFFA7B2C2);

  // ---------------------------------------------------------------------------
  // Dégradés
  // ---------------------------------------------------------------------------

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, turquoise],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient magicGradient = LinearGradient(
    colors: [turquoise, violet],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient solarGradient = LinearGradient(
    colors: [gold, softOrange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  // ---------------------------------------------------------------------------
  // Couleurs des moments
  // ---------------------------------------------------------------------------

  static const Color momentMorning = Color(0xFF4DA3FF);

  static const Color momentMeal = Color(0xFFFFA726);

  static const Color momentSchool = Color(0xFF7E57C2);

  static const Color momentLeisure = Color(0xFF26A69A);

  static const Color momentEvening = Color(0xFF3F51B5);

  static const Color momentHygiene = Color(0xFF66BB6A);
}
