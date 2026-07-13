import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/parent_task_model.dart';
import '../common/app_card.dart';
import 'parent_task_card.dart';

class ParentTaskCategory {
  final String id;
  final String label;
  final String helpMessage;
  final Color color;
  final IconData icon;

  const ParentTaskCategory({
    required this.id,
    required this.label,
    required this.helpMessage,
    required this.color,
    required this.icon,
  });
}

const parentTaskCategories = [
  ParentTaskCategory(
    id: 'urgent_important',
    label: 'Urgent & Important',
    helpMessage: 'A traiter en priorité',
    color: AppColors.error,
    icon: Icons.priority_high_rounded,
  ),
  ParentTaskCategory(
    id: 'important_not_urgent',
    label: 'Important & Pas urgent',
    helpMessage: 'A planifier',
    color: AppColors.success,
    icon: Icons.star_outline_rounded,
  ),
  ParentTaskCategory(
    id: 'urgent_not_important',
    label: 'Urgent & Pas important',
    helpMessage: 'À déléguer',
    color: AppColors.softOrange,
    icon: Icons.schedule_rounded,
  ),
  ParentTaskCategory(
    id: 'not_urgent_not_important',
    label: 'Pas urgent & Pas important',
    helpMessage: 'A abandonner pour le moment',
    color: AppColors.gold,
    icon: Icons.spa_rounded,
  ),
];

class ParentTasksMatrix extends StatefulWidget {
  const ParentTasksMatrix({
    super.key,
    required this.tasks,
    required this.onCreate,
    required this.onToggleDone,
    required this.onStatusChanged,
    required this.onStepToggle,
    required this.onPlan,
    required this.onRemovePlanning,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  final List<ParentTaskModel> tasks;
  final ValueChanged<String> onCreate;
  final ValueChanged<ParentTaskModel> onToggleDone;
  final void Function(ParentTaskModel task, ParentTaskStatus status)
  onStatusChanged;
  final void Function(ParentTaskModel task, ParentTaskStepModel step)
  onStepToggle;
  final ValueChanged<ParentTaskModel> onPlan;
  final ValueChanged<ParentTaskModel> onRemovePlanning;
  final ValueChanged<ParentTaskModel> onEdit;
  final ValueChanged<ParentTaskModel> onDelete;
  final void Function(ParentTaskModel task, String category) onMove;

  @override
  State<ParentTasksMatrix> createState() => _ParentTasksMatrixState();
}

class _ParentTasksMatrixState extends State<ParentTasksMatrix> {
  bool _showCompletedTasks = false;
  bool _showAbandonedTasks = false;
  final Set<String> _expandedCategoryIds = {};

  @override
  Widget build(BuildContext context) {
    final activeTasks =
        widget.tasks
            .where(
              (task) =>
                  task.status == ParentTaskStatus.todo ||
                  task.status == ParentTaskStatus.started,
            )
            .toList()
          ..sort(_compareActiveTasks);
    final completedTasks =
        widget.tasks
            .where((task) => task.status == ParentTaskStatus.done)
            .toList()
          ..sort(
            (a, b) => (b.completedAt ?? b.updatedAt).compareTo(
              a.completedAt ?? a.updatedAt,
            ),
          );
    final abandonedTasks =
        widget.tasks
            .where((task) => task.status == ParentTaskStatus.abandoned)
            .toList()
          ..sort(
            (a, b) => (b.abandonedAt ?? b.updatedAt).compareTo(
              a.abandonedAt ?? a.updatedAt,
            ),
          );

    return Column(
      children: [
        for (final category in parentTaskCategories) ...[
          _TaskCategoryCard(
            category: category,
            tasks: activeTasks
                .where((task) => task.category == category.id)
                .toList(),
            isExpanded: _expandedCategoryIds.contains(category.id),
            onToggleExpanded: () {
              setState(() {
                if (!_expandedCategoryIds.add(category.id)) {
                  _expandedCategoryIds.remove(category.id);
                }
              });
            },
            onCreate: () => widget.onCreate(category.id),
            onToggleDone: widget.onToggleDone,
            onStatusChanged: widget.onStatusChanged,
            onStepToggle: widget.onStepToggle,
            onPlan: widget.onPlan,
            onRemovePlanning: widget.onRemovePlanning,
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
            onMove: widget.onMove,
          ),
          const SizedBox(height: 16),
        ],
        _CompletedTasksSection(
          completedTasks: completedTasks,
          abandonedTasks: abandonedTasks,
          isExpanded: _showCompletedTasks,
          isAbandonedExpanded: _showAbandonedTasks,
          onToggleExpanded: () {
            setState(() => _showCompletedTasks = !_showCompletedTasks);
          },
          onToggleAbandoned: () {
            setState(() => _showAbandonedTasks = !_showAbandonedTasks);
          },
          onToggleDone: widget.onToggleDone,
          onStatusChanged: widget.onStatusChanged,
          onStepToggle: widget.onStepToggle,
          onPlan: widget.onPlan,
          onRemovePlanning: widget.onRemovePlanning,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          onMove: widget.onMove,
        ),
      ],
    );
  }
}

int _compareActiveTasks(ParentTaskModel a, ParentTaskModel b) {
  final importanceComparison = b.importance.index.compareTo(a.importance.index);
  if (importanceComparison != 0) {
    return importanceComparison;
  }

  return a.createdAt.compareTo(b.createdAt);
}

class _CompletedTasksSection extends StatelessWidget {
  const _CompletedTasksSection({
    required this.completedTasks,
    required this.abandonedTasks,
    required this.isExpanded,
    required this.isAbandonedExpanded,
    required this.onToggleExpanded,
    required this.onToggleAbandoned,
    required this.onToggleDone,
    required this.onStatusChanged,
    required this.onStepToggle,
    required this.onPlan,
    required this.onRemovePlanning,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  final List<ParentTaskModel> completedTasks;
  final List<ParentTaskModel> abandonedTasks;
  final bool isExpanded;
  final bool isAbandonedExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onToggleAbandoned;
  final ValueChanged<ParentTaskModel> onToggleDone;
  final void Function(ParentTaskModel task, ParentTaskStatus status)
  onStatusChanged;
  final void Function(ParentTaskModel task, ParentTaskStepModel step)
  onStepToggle;
  final ValueChanged<ParentTaskModel> onPlan;
  final ValueChanged<ParentTaskModel> onRemovePlanning;
  final ValueChanged<ParentTaskModel> onEdit;
  final ValueChanged<ParentTaskModel> onDelete;
  final void Function(ParentTaskModel task, String category) onMove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mes avancées · ${completedTasks.length}',
                      style: AppTextStyles.cardTitle,
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? .5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: completedTasks.isEmpty && abandonedTasks.isEmpty
                  ? Text(
                      'Vos avancées apparaîtront ici, tranquillement.',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Column(
                      children: [
                        for (final task in completedTasks)
                          ParentTaskCard(
                            task: task,
                            onToggleDone: () => onToggleDone(task),
                            onStatusChanged: (status) =>
                                onStatusChanged(task, status),
                            onStepToggle: (step) => onStepToggle(task, step),
                            onPlan: () => onPlan(task),
                            onRemovePlanning: () => onRemovePlanning(task),
                            onEdit: () => onEdit(task),
                            onDelete: () => onDelete(task),
                            onMove: (categoryId) => onMove(task, categoryId),
                          ),
                        if (abandonedTasks.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: onToggleAbandoned,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.spa_outlined,
                                    size: 18,
                                    color: AppColors.violet,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Abandonnées · ${abandonedTasks.length}',
                                      style: AppTextStyles.small.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: isAbandonedExpanded ? .5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isAbandonedExpanded)
                            for (final task in abandonedTasks)
                              ParentTaskCard(
                                task: task,
                                onToggleDone: () => onStatusChanged(
                                  task,
                                  ParentTaskStatus.todo,
                                ),
                                onStatusChanged: (status) =>
                                    onStatusChanged(task, status),
                                onStepToggle: (step) =>
                                    onStepToggle(task, step),
                                onPlan: () => onPlan(task),
                                onRemovePlanning: () => onRemovePlanning(task),
                                onEdit: () => onEdit(task),
                                onDelete: () => onDelete(task),
                                onMove: (categoryId) =>
                                    onMove(task, categoryId),
                              ),
                        ],
                      ],
                    ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _TaskCategoryCard extends StatelessWidget {
  const _TaskCategoryCard({
    required this.category,
    required this.tasks,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onCreate,
    required this.onToggleDone,
    required this.onStatusChanged,
    required this.onStepToggle,
    required this.onPlan,
    required this.onRemovePlanning,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  final ParentTaskCategory category;
  final List<ParentTaskModel> tasks;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onCreate;
  final ValueChanged<ParentTaskModel> onToggleDone;
  final void Function(ParentTaskModel task, ParentTaskStatus status)
  onStatusChanged;
  final void Function(ParentTaskModel task, ParentTaskStepModel step)
  onStepToggle;
  final ValueChanged<ParentTaskModel> onPlan;
  final ValueChanged<ParentTaskModel> onRemovePlanning;
  final ValueChanged<ParentTaskModel> onEdit;
  final ValueChanged<ParentTaskModel> onDelete;
  final void Function(ParentTaskModel task, String category) onMove;

  @override
  Widget build(BuildContext context) {
    final visibleTasks = isExpanded ? tasks : tasks.take(2);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(category.icon, color: category.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.label, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      category.helpMessage,
                      style: AppTextStyles.small.copyWith(
                        color: category.color,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Ajouter',
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (tasks.isEmpty)
            Text(
              'Rien ici pour le moment.',
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else ...[
            for (final task in visibleTasks)
              ParentTaskCard(
                task: task,
                onToggleDone: () => onToggleDone(task),
                onStatusChanged: (status) => onStatusChanged(task, status),
                onStepToggle: (step) => onStepToggle(task, step),
                onPlan: () => onPlan(task),
                onRemovePlanning: () => onRemovePlanning(task),
                onEdit: () => onEdit(task),
                onDelete: () => onDelete(task),
                onMove: (categoryId) => onMove(task, categoryId),
              ),
            if (tasks.length > 2)
              TextButton.icon(
                onPressed: onToggleExpanded,
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                label: Text(
                  isExpanded
                      ? 'Réduire'
                      : 'Voir les autres (${tasks.length - 2})',
                ),
              ),
          ],
        ],
      ),
    );
  }
}
