import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'boussole_colors.dart';

class BoussoleTheme {
  BoussoleTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: BoussoleColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: BoussoleColors.blue,
      brightness: Brightness.light,
    ),

    textTheme: GoogleFonts.nunitoSansTextTheme().apply(
      bodyColor: BoussoleColors.textPrimary,
      displayColor: BoussoleColors.textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: BoussoleColors.textPrimary,
    ),

    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BoussoleColors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GoogleFonts.nunitoSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: BoussoleColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: BoussoleColors.blue, width: 2),
      ),
    ),
  );
}
