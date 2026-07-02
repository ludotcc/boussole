import 'dart:math' as math;

import 'package:flutter/material.dart';

class WelcomeMascot extends StatefulWidget {
  const WelcomeMascot({super.key});

  @override
  State<WelcomeMascot> createState() => _WelcomeMascotState();
}

class _WelcomeMascotState extends State<WelcomeMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final mascotHeight = screenHeight * .30;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final offset = math.sin(_controller.value * math.pi) * 8;

        return Transform.translate(offset: Offset(0, -offset), child: child);
      },
      child: Hero(
        tag: "mascot",
        child: Image.asset(
          "assets/images/mascotte/happy.png",
          height: mascotHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
