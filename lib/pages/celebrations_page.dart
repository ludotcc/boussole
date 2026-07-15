import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../models/celebration.dart';
import '../models/family_member_model.dart';
import '../providers/companion_provider.dart';
import '../widgets/boussole_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';

class CelebrationsPage extends ConsumerStatefulWidget {
  const CelebrationsPage({super.key, required this.child});

  final FamilyMemberModel child;

  @override
  ConsumerState<CelebrationsPage> createState() => _CelebrationsPageState();
}

class _CelebrationsPageState extends ConsumerState<CelebrationsPage> {
  CelebrationType _type = CelebrationType.positiveBehavior;
  int _shardReward = 0;

  Future<void> _create() async {
    await ref
        .read(celebrationCreationProvider.notifier)
        .create(
          childId: widget.child.id,
          type: _type,
          shardReward: _shardReward,
        );
    if (!mounted) return;
    final state = ref.read(celebrationCreationProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.hasError
              ? state.error.toString()
              : 'La célébration est prête pour ${widget.child.firstName}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final celebrationsAsync = ref.watch(celebrationsProvider(widget.child.id));
    final creationState = ref.watch(celebrationCreationProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Célébrations de ${widget.child.firstName}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Célébrez un effort, un progrès ou un beau comportement. Le Compagnon prolongera votre encouragement.',
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<CelebrationType>(
                    key: const ValueKey('celebration_type'),
                    initialValue: _type,
                    decoration: const InputDecoration(
                      labelText: 'Type de comportement',
                    ),
                    items: [
                      for (final type in CelebrationType.values)
                        DropdownMenuItem(
                          value: type,
                          child: Text(_celebrationLabel(type)),
                        ),
                    ],
                    onChanged: creationState.isLoading
                        ? null
                        : (value) {
                            if (value != null) setState(() => _type = value);
                          },
                  ),
                  const SizedBox(height: 12),
                  const Text('Éclats remis par le Compagnon'),
                  const SizedBox(height: 8),
                  Wrap(
                    key: const ValueKey('celebration_shard'),
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var amount = 0; amount <= 5; amount++)
                        ChoiceChip(
                          label: Text(
                            amount == 0
                                ? 'Sans Éclat'
                                : '+$amount Éclat${amount > 1 ? 's' : ''}',
                          ),
                          selected: _shardReward == amount,
                          onSelected: creationState.isLoading
                              ? null
                              : (_) => setState(() => _shardReward = amount),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (creationState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    BoussoleButton(
                      text: 'Créer la célébration',
                      icon: Icons.celebration_rounded,
                      onPressed: _create,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Célébrations récentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            celebrationsAsync.when(
              loading: () => const LoadingCard(),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Impossible de charger les célébrations',
                message: error.toString(),
              ),
              data: (celebrations) => celebrations.isEmpty
                  ? const Text('Aucune célébration pour le moment.')
                  : Column(
                      children: [
                        for (final celebration in celebrations) ...[
                          AppCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.celebration_rounded),
                              title: Text(_celebrationLabel(celebration.type)),
                              subtitle: Text(
                                celebration.shardReward > 0
                                    ? 'Avec ${celebration.shardReward} Éclat${celebration.shardReward > 1 ? 's' : ''}'
                                    : 'Sans Éclat',
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _celebrationLabel(CelebrationType type) => switch (type) {
  CelebrationType.courage => 'Courage',
  CelebrationType.patience => 'Patience',
  CelebrationType.autonomy => 'Autonomie',
  CelebrationType.respect => 'Respect',
  CelebrationType.politeness => 'Politesse',
  CelebrationType.emotionManagement => 'Gestion des émotions',
  CelebrationType.perseverance => 'Persévérance',
  CelebrationType.helping => 'Entraide',
  CelebrationType.initiative => 'Initiative',
  CelebrationType.positiveBehavior => 'Beau comportement',
};
