import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF5FF), Color(0xFFF8FAFC), Color(0xFFFCEEFF)],
          ),
        ),
        child: Center(
          child: Image.asset('assets/images/logo/logo.png', width: 280)
              .animate()
              .fadeIn(duration: 900.ms)
              .scale(begin: const Offset(.9, .9), end: const Offset(1, 1)),
        ),
      ),
    );
  }
}
