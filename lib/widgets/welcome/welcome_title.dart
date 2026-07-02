import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bienvenue dans',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: width * 0.068,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF20305E),
            height: 1,
          ),
        ),
        SizedBox(height: width * 0.01),
        Text(
          'Boussole',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: width * 0.130,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF20305E),
            height: 0.95,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}
