import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/moment_model.dart';
import '../models/routine_model.dart';
import '../providers/child_day_progress_provider.dart';
import '../providers/steps_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_card.dart';

class ChildRoutinePageArgs {
  const ChildRoutinePageArgs({
    required this.childId,
    required this.moment,
    required this.routine,
    required this.momentIds,
  });

  final String childId;
  final MomentModel moment;
  final RoutineModel routine;
  final List<String> momentIds;
}

class ChildRoutinePage extends ConsumerStatefulWidget {
  const ChildRoutinePage({super.key, required this.args});

  final ChildRoutinePageArgs args;

  @override
  ConsumerState<ChildRoutinePage> createState() => _ChildRoutinePageState();
}

class _ChildRoutinePageState extends ConsumerState<ChildRoutinePage> {
  int _stepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final stepsAsync = ref.watch(stepsForRoutineProvider(widget.args.routine));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(widget.args.moment.name),
      ),
      body: SafeArea(
        child: stepsAsync.when(
          loading: () =>
              const Padding(padding: EdgeInsets.all(24), child: LoadingCard()),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(24),
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Oups',
              message: 'Impossible de charger les étapes.',
            ),
          ),
          data: (steps) {
            final activeSteps = steps.where((step) => step.active).toList();

            if (activeSteps.isEmpty) {
              return _NoStepsView(
                onFinish: () {
                  _finishMoment();
                },
              );
            }

            final step =
                activeSteps[_stepIndex.clamp(0, activeSteps.length - 1)];

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_stepIndex + 1) / activeSteps.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 72,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            step.title,
                            style: AppTextStyles.h2,
                            textAlign: TextAlign.center,
                          ),
                          if (step.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              step.description,
                              style: AppTextStyles.body,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton.icon(
                      onPressed: () => _completeStep(activeSteps.length),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        _stepIndex == activeSteps.length - 1
                            ? 'Terminer'
                            : 'Étape suivante',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _completeStep(int stepsCount) async {
    if (_stepIndex < stepsCount - 1) {
      setState(() {
        _stepIndex += 1;
      });
      return;
    }

    await _finishMoment();
  }

  Future<void> _finishMoment() async {
    await ref
        .read(childDayProgressProvider.notifier)
        .completeMoment(
          childId: widget.args.childId,
          momentId: widget.args.moment.id,
          momentIds: widget.args.momentIds,
          isMultiUse: widget.args.moment.isMultiUse,
          maxDailyUses: widget.args.moment.maxDailyUses,
        );

    if (mounted) {
      context.pop();
    }
  }
}

class _NoStepsView extends StatelessWidget {
  const _NoStepsView({required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'C’est prêt',
            message: 'Tu peux terminer ce moment.',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton(
              onPressed: onFinish,
              child: const Text('Terminer'),
            ),
          ),
        ],
      ),
    );
  }
}
