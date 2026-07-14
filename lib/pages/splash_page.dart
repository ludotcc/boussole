import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_bootstrap_provider.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);

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
          child: bootstrap.hasError
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 52,
                        color: Color(0xFFE45757),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Boussole ne peut pas démarrer pour le moment.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : Image.asset('assets/images/logo/logo.png', width: 280)
                    .animate()
                    .fadeIn(duration: 900.ms)
                    .scale(
                      begin: const Offset(.9, .9),
                      end: const Offset(1, 1),
                    ),
        ),
      ),
    );
  }
}
