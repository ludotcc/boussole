import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_border_radius.dart';
import 'app_shadows.dart';

class AppThemeExtension {
  AppThemeExtension._();

  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.medium,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.medium,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.medium,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  static CardThemeData get cardTheme {
    return CardThemeData(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.large),
      margin: EdgeInsets.zero,
    );
  }

  static List<BoxShadow> get cardShadow => AppShadows.card;
}
