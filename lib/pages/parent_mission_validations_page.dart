import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/children_provider.dart';
import '../providers/mission_provider.dart';

class ParentMissionValidationsPage extends ConsumerWidget {
  const ParentMissionValidationsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(pendingMissionValidationsProvider);
    final children = ref.watch(childrenProvider).valueOrNull ?? const [];
    final action = ref.watch(missionValidationProvider);
    String childName(String id) {
      for (final child in children) {
        if (child.id == id) return child.firstName;
      }
      return 'Enfant';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Missions à valider')),
      body: missions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Impossible de charger les validations.')),
        data: (items) => items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Text(
                    'Aucune Mission n’attend de validation.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final mission = items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            childName(mission.childId),
                            style: const TextStyle(
                              color: Color(0xFF8064A2),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(mission.description),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: action.isLoading
                                      ? null
                                      : () => ref
                                            .read(
                                              missionValidationProvider
                                                  .notifier,
                                            )
                                            .refuse(mission),
                                  child: const Text('Refuser'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: action.isLoading
                                      ? null
                                      : () => ref
                                            .read(
                                              missionValidationProvider
                                                  .notifier,
                                            )
                                            .validate(mission),
                                  child: const Text('Valider'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
