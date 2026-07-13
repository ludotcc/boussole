import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_bootstrap_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    await Future.wait([
      ref.read(appBootstrapProvider.notifier).bootstrap(),
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);

    if (!mounted) return;

    final state = ref.read(appBootstrapProvider);
    context.go(state.destination ?? '/welcome');
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
