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
    final dayTypesAsync = ref.watch(dayTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journées types')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SectionCard(
          title: 'Mes journées types',
          icon: Icons.calendar_today_rounded,
          child: dayTypesAsync.when(
            loading: () => const LoadingCard(),

            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: 'Impossible de charger les journées.',
              message: error.toString(),
            ),

            data: (dayTypes) {
              if (dayTypes.isEmpty) {
                return const EmptyState(
                  icon: Icons.calendar_month_outlined,
                  title: 'Aucune journée type',
                  message:
                      'Commencez par créer une journée type pour votre famille.',
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dayTypes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final DayTypeModel dayType = dayTypes[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.calendar_today),
                    ),
                    title: Text(dayType.name, style: AppTextStyles.cardTitle),
                    subtitle: Text(dayType.type),
                    trailing: dayType.active
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
