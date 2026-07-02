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
                return Stack(
                  children: [
                    /// HEADER
                    Positioned(
                      top: 12,
                      left: 24,
                      right: 24,
                      child: Column(
                        children: const [
                          WelcomeLogo(),
                          SizedBox(height: 8),
                          WelcomeTitle(),
                          SizedBox(height: 18),
                          WelcomeMessage(),
                        ],
                      ),
                    ),

                    /// HAPPY
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 175,
                      child: Center(child: WelcomeMascot()),
                    ),

                    /// BAS DE PAGE
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          WelcomeButtons(),
                          SizedBox(height: 18),
                          SecureFooter(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
