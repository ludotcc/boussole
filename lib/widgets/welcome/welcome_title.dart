import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Text(
          "Bienvenue dans",
          style: GoogleFonts.nunito(
            fontSize: width * .072,
            fontWeight: FontWeight.w700,
            color: const Color(0xff20305E),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "Boussole",
          style: GoogleFonts.nunito(
            fontSize: width * .14,
            fontWeight: FontWeight.w900,
            height: 1,
            color: const Color(0xff20305E),
          ),
        ),
      ],
    );
  }
}
