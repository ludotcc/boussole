import 'package:flutter/material.dart';

import '../widgets/welcome/secure_footer.dart';
import '../widgets/welcome/welcome_background.dart';
import '../widgets/welcome/welcome_buttons.dart';
import '../widgets/welcome/welcome_logo.dart';
import '../widgets/welcome/welcome_mascot.dart';
import '../widgets/welcome/welcome_message.dart';
import '../widgets/welcome/welcome_title.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const WelcomeBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: h * .025),

                      const WelcomeLogo(),

                      SizedBox(height: h * .02),

                      const WelcomeTitle(),

                      SizedBox(height: h * .025),

                      const WelcomeMessage(),

                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: const WelcomeMascot(),
                        ),
                      ),

                      const WelcomeButtons(),

                      SizedBox(height: h * .02),

                      const SecureFooter(),

                      SizedBox(height: h * .02),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
