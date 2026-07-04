import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../providers/moments_provider.dart';
import '../widgets/common/boussole_app_bar.dart';
import '../widgets/common/moment_type_card.dart';

class SelectMomentTypePage extends ConsumerWidget {
  const SelectMomentTypePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(momentCreationProvider);
    final isLoading = creationState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BoussoleAppBar(title: "Choisir un moment"),
      body: Stack(
        children: [
          GridView.count(
            padding: const EdgeInsets.all(24),
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: .78,
            children: [
              MomentTypeCard(
                title: "Rituel du matin",
                image: AppAssets.routineMorning,
                color: AppColors.momentMorning,
                onTap: isLoading
                    ? null
                    : () => _createMoment(context, ref, 'routine_morning'),
              ),
              MomentTypeCard(
                title: "Repas",
                image: AppAssets.breakfast,
                color: AppColors.momentMeal,
                onTap: isLoading
                    ? null
                    : () => _createMoment(context, ref, 'meal'),
              ),
              MomentTypeCard(
                title: "Devoirs",
                image: AppAssets.homework,
                color: AppColors.momentSchool,
                onTap: isLoading
                    ? null
                    : () => _createMoment(context, ref, 'school'),
              ),
              MomentTypeCard(
                title: "Temps libre",
                image: AppAssets.videoGames,
                color: AppColors.momentLeisure,
                onTap: isLoading
                    ? null
                    : () => _createMoment(context, ref, 'leisure'),
              ),
              MomentTypeCard(
                title: "Rituel du soir",
                image: AppAssets.routineEvening,
                color: AppColors.momentEvening,
                onTap: isLoading
                    ? null
                    : () => _createMoment(context, ref, 'routine_evening'),
              ),
              MomentTypeCard(
                title: "Vélo",
                image: AppAssets.bike,
                color: AppColors.momentHygiene,
                onTap: isLoading
                    ? null
                    : () => _createMoment(context, ref, 'bike'),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: AppColors.background.withValues(alpha: .64),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _createMoment(
    BuildContext context,
    WidgetRef ref,
    String type,
  ) async {
    await ref.read(momentCreationProvider.notifier).createMoment(type: type);

    if (!context.mounted) {
      return;
    }

    final creationState = ref.read(momentCreationProvider);

    if (creationState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(creationState.error.toString())),
      );
      return;
    }

    context.pop();
  }
}
