import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../providers/session_provider.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/info_tile.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final firstName = session?.firstName ?? 'Enfant';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text("Aujourd'hui"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bonjour 👋', style: AppTextStyles.small),

              const SizedBox(height: 8),

              Text(firstName, style: AppTextStyles.h2),

              const SizedBox(height: 32),

              Text("Aujourd'hui", style: AppTextStyles.h3),

              const SizedBox(height: 16),

              AppCard(
                child: Column(
                  children: [
                    Image.asset(AppAssets.routineMorning, height: 180),

                    const SizedBox(height: 20),

                    Text("C'est le moment de", style: AppTextStyles.small),

                    const SizedBox(height: 8),

                    Text(
                      'Rituel du matin',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('Commencer'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Encore 4 moments aujourd’hui',
                style: AppTextStyles.cardTitle,
              ),

              const SizedBox(height: 20),

              InfoTile(
                leading: Image.asset(AppAssets.meal, width: 56, height: 56),
                title: 'Déjeuner',
              ),

              const SizedBox(height: 12),

              InfoTile(
                leading: Image.asset(
                  AppAssets.videoGames,
                  width: 56,
                  height: 56,
                ),
                title: 'Temps d’écran',
              ),

              const SizedBox(height: 12),

              InfoTile(
                leading: Image.asset(
                  AppAssets.routineEvening,
                  width: 56,
                  height: 56,
                ),
                title: 'Rituel du soir',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
