import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),

        borderRadius: BorderRadius.circular(32),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),

      child: Column(
        children: [
          Text(
            "Des repères pour bien grandir,",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: const Color(0xff20305E),
            ),
          ),

          const SizedBox(height: 6),

          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [Color(0xff8B5CF6), Color(0xffC084FC)],
              ).createShader(bounds);
            },
            child: Text(
              "chaque jour. ❤",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
