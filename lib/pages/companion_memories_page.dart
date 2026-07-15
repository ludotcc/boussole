import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../models/companion_memory.dart';
import '../models/family_member_model.dart';
import '../providers/companion_provider.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';

class CompanionMemoriesPage extends ConsumerWidget {
  const CompanionMemoriesPage({super.key, required this.child});

  final FamilyMemberModel child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(companionMemoriesProvider(child.id));
    final decisionState = ref.watch(companionMemoryDecisionProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Mémoires de ${child.firstName}')),
      body: SafeArea(
        child: memoriesAsync.when(
          loading: () =>
              const Padding(padding: EdgeInsets.all(24), child: LoadingCard()),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Impossible de charger les mémoires',
              message: error.toString(),
            ),
          ),
          data: (memories) {
            final proposed = memories
                .where((memory) => memory.isProposed)
                .toList();
            final validated = memories
                .where((memory) => memory.isValidated)
                .toList();
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Le parent reste toujours décisionnaire. Une mémoire refusée ne sera jamais utilisée.',
                ),
                const SizedBox(height: 24),
                _MemorySection(
                  title: 'Proposées',
                  memories: proposed,
                  emptyMessage: 'Aucune mémoire en attente.',
                  actions: true,
                  isLoading: decisionState.isLoading,
                  onValidate: (memory) => ref
                      .read(companionMemoryDecisionProvider.notifier)
                      .validate(memory),
                  onRefuse: (memory) => ref
                      .read(companionMemoryDecisionProvider.notifier)
                      .refuse(memory),
                ),
                const SizedBox(height: 24),
                _MemorySection(
                  title: 'Validées',
                  memories: validated,
                  emptyMessage: 'Aucune mémoire validée pour le moment.',
                  actions: false,
                  isLoading: false,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MemorySection extends StatelessWidget {
  const _MemorySection({
    required this.title,
    required this.memories,
    required this.emptyMessage,
    required this.actions,
    required this.isLoading,
    this.onValidate,
    this.onRefuse,
  });

  final String title;
  final List<CompanionMemory> memories;
  final String emptyMessage;
  final bool actions;
  final bool isLoading;
  final ValueChanged<CompanionMemory>? onValidate;
  final ValueChanged<CompanionMemory>? onRefuse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (memories.isEmpty)
          Text(emptyMessage)
        else
          for (final memory in memories) ...[
            AppCard(
              key: ValueKey('memory_${memory.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.value,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (actions) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => onRefuse?.call(memory),
                            child: const Text('Refuser'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: isLoading
                                ? null
                                : () => onValidate?.call(memory),
                            child: const Text('Valider'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
