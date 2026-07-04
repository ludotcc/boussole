import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../providers/family_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/dashboard/greeting_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(familyRepositoryProvider).signOut();

    ref.read(sessionProvider.notifier).clearSession();

    if (context.mounted) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('Boussole'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const GreetingCard(),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.push('/planner');
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Planning familial"),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.push('/today');
                  },
                  icon: const Icon(Icons.child_care),
                  label: const Text("Voir l'écran enfant"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
