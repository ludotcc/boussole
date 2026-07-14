import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/secret_mission.dart';
import '../providers/guardian_provider.dart';
import '../providers/mission_provider.dart';

class SecretMissionPage extends ConsumerWidget {
  const SecretMissionPage({
    super.key,
    required this.childId,
    required this.missionId,
  });
  final String childId;
  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(childSecretMissionProvider(childId));
    final guardian = ref.watch(childGuardianProvider(childId)).valueOrNull;
    final action = ref.watch(missionActionProvider(childId));
    return Scaffold(
      backgroundColor: const Color(0xFFF2ECF8),
      appBar: AppBar(
        title: const Text('Mission Secrète'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/child/$childId/house'),
        ),
      ),
      body: missionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('La mission se cache pour le moment.')),
        data: (mission) {
          if (mission == null || mission.id != missionId) {
            return const Center(
              child: Text('Cette mission n’est plus disponible.'),
            );
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      if (guardian != null)
                        Image.asset(
                          guardian.idleAsset,
                          height: 190,
                          fit: BoxFit.contain,
                        ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .9),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFF8064A2),
                              size: 34,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              mission.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF3F3152),
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mission.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF665A72),
                                fontSize: 16,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _statusMessage(mission.status),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF8064A2),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (mission.status == SecretMissionStatus.available)
                        FilledButton.icon(
                          onPressed: action.isLoading || guardian == null
                              ? null
                              : () => ref
                                    .read(
                                      missionActionProvider(childId).notifier,
                                    )
                                    .accept(mission, guardian.storageId),
                          icon: const Icon(Icons.favorite_outline_rounded),
                          label: const Text('J’accepte'),
                        ),
                      if (mission.status == SecretMissionStatus.accepted)
                        FilledButton.icon(
                          onPressed: action.isLoading
                              ? null
                              : () => ref
                                    .read(
                                      missionActionProvider(childId).notifier,
                                    )
                                    .complete(mission),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Mission terminée'),
                        ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/child/$childId/house'),
                        child: const Text('Pas maintenant'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusMessage(SecretMissionStatus status) => switch (status) {
    SecretMissionStatus.available =>
      'Tu es libre de l’accepter, ou de revenir plus tard.',
    SecretMissionStatus.accepted =>
      'Prends ton temps et profite de ce beau moment.',
    SecretMissionStatus.completedByChild ||
    SecretMissionStatus.awaitingParentValidation =>
      'Le parent va maintenant pouvoir valider ce beau moment.',
    SecretMissionStatus.validated => 'Ce beau moment a rejoint tes souvenirs.',
    SecretMissionStatus.refused =>
      'Ce n’est pas grave, il y aura d’autres beaux moments.',
    SecretMissionStatus.expired =>
      'Cette mission est terminée, une autre viendra un jour.',
  };
}
