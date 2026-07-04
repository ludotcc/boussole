import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_text_styles.dart';
import '../models/day_type_model.dart';
import '../providers/day_types_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';
import '../widgets/common/section_card.dart';

class DayTypesPage extends ConsumerWidget {
  const DayTypesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyPlanningsAsync = ref.watch(familyPlanningsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Planning familial')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SectionCard(
          title: 'Planning de la famille',
          icon: Icons.calendar_today_rounded,
          child: familyPlanningsAsync.when(
            loading: () => const LoadingCard(),

            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: 'Impossible de charger le planning.',
              message: error.toString(),
            ),

            data: (familyPlannings) {
              if (familyPlannings.isEmpty) {
                return const EmptyState(
                  icon: Icons.calendar_month_outlined,
                  title: 'Aucun planning familial',
                  message:
                      'Commencez par préparer le planning de votre famille.',
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: familyPlannings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final DayTypeModel planning = familyPlannings[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.calendar_today),
                    ),
                    title: Text(planning.name, style: AppTextStyles.cardTitle),
                    subtitle: Text(_planningSubtitle(planning.type)),
                    trailing: planning.active
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(
                            Icons.pause_circle_outline,
                            color: Colors.grey,
                          ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

String _planningSubtitle(String type) {
  switch (type) {
    case 'family_planning':
    case 'default':
      return 'Planning personnalisable';
    default:
      return 'Planning importé';
  }
}
