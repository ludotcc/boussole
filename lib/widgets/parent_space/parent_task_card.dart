import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/parent_task_model.dart';

class ParentTaskCard extends StatelessWidget {
  const ParentTaskCard({
    super.key,
    required this.task,
    required this.onToggleDone,
    required this.onStatusChanged,
    required this.onStepToggle,
    required this.onPlan,
    required this.onRemovePlanning,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  final ParentTaskModel task;
  final VoidCallback onToggleDone;
  final ValueChanged<ParentTaskStatus> onStatusChanged;
  final ValueChanged<ParentTaskStepModel> onStepToggle;
  final VoidCallback onPlan;
  final VoidCallback onRemovePlanning;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<String> onMove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.isDone
            ? AppColors.cardSecondary.withValues(alpha: .62)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: task.isDone, onChanged: (_) => onToggleDone()),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    task.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isDone
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  } else if (value == 'start') {
                    onStatusChanged(ParentTaskStatus.started);
                  } else if (value == 'complete') {
                    onStatusChanged(ParentTaskStatus.done);
                  } else if (value == 'reopen') {
                    onStatusChanged(ParentTaskStatus.todo);
                  } else if (value == 'abandon') {
                    onStatusChanged(ParentTaskStatus.abandoned);
                  } else if (value == 'plan') {
                    onPlan();
                  } else if (value == 'removePlanning') {
                    onRemovePlanning();
                  } else {
                    onMove(value);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  if (task.status == ParentTaskStatus.todo ||
                      task.status == ParentTaskStatus.started)
                    PopupMenuItem(
                      value: 'plan',
                      child: Text(
                        task.isPlanned
                            ? 'Modifier la planification'
                            : 'Planifier',
                      ),
                    ),
                  if (task.isPlanned &&
                      (task.status == ParentTaskStatus.todo ||
                          task.status == ParentTaskStatus.started))
                    const PopupMenuItem(
                      value: 'removePlanning',
                      child: Text('Retirer la planification'),
                    ),
                  if (task.status == ParentTaskStatus.todo)
                    const PopupMenuItem(
                      value: 'start',
                      child: Text('Commencer'),
                    ),
                  if (task.status == ParentTaskStatus.started)
                    const PopupMenuItem(
                      value: 'complete',
                      child: Text('Terminer'),
                    ),
                  if (task.status == ParentTaskStatus.done ||
                      task.status == ParentTaskStatus.abandoned)
                    const PopupMenuItem(
                      value: 'reopen',
                      child: Text('Réouvrir'),
                    ),
                  if (task.status == ParentTaskStatus.todo ||
                      task.status == ParentTaskStatus.started)
                    const PopupMenuItem(
                      value: 'abandon',
                      child: Text('Abandonner'),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'urgent_important',
                    child: Text('Urgent & Important'),
                  ),
                  const PopupMenuItem(
                    value: 'important_not_urgent',
                    child: Text('Important & Pas urgent'),
                  ),
                  const PopupMenuItem(
                    value: 'urgent_not_important',
                    child: Text('Urgent & Pas important'),
                  ),
                  const PopupMenuItem(
                    value: 'not_urgent_not_important',
                    child: Text('Pas urgent & Pas important'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Supprimer'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _TaskTag(
                icon: _statusIcon(task.status),
                label: task.status.label,
                color: _statusColor(task.status),
              ),
              if (task.isPlanned)
                const _TaskTag(
                  icon: Icons.event_available_rounded,
                  label: 'Planifiée',
                  color: AppColors.success,
                ),
              _TaskTag(
                icon: Icons.flag_outlined,
                label: task.importance.label,
                color: _importanceColor(task.importance),
              ),
            ],
          ),
          if (task.description != null) ...[
            const SizedBox(height: 4),
            Text(
              task.description!,
              style: AppTextStyles.small.copyWith(height: 1.3),
            ),
          ],
          if (task.dueDate != null || task.reminders.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                if (task.dueDate != null)
                  _InfoLine(
                    icon: Icons.calendar_today_rounded,
                    text: 'Échéance ${_formatDate(task.dueDate!)}',
                  ),
                if (task.reminders.isNotEmpty)
                  _InfoLine(
                    icon: Icons.notifications_none_rounded,
                    text: task.reminders.length == 1
                        ? '1 rappel'
                        : '${task.reminders.length} rappels',
                  ),
              ],
            ),
          ],
          if (task.steps.isNotEmpty) ...[
            const SizedBox(height: 10),
            _TaskSteps(task: task, onStepToggle: onStepToggle),
          ],
        ],
      ),
    );
  }
}

class _TaskSteps extends StatefulWidget {
  const _TaskSteps({required this.task, required this.onStepToggle});

  final ParentTaskModel task;
  final ValueChanged<ParentTaskStepModel> onStepToggle;

  @override
  State<_TaskSteps> createState() => _TaskStepsState();
}

class _TaskStepsState extends State<_TaskSteps> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final canEdit =
        task.status != ParentTaskStatus.done &&
        task.status != ParentTaskStatus.abandoned;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${task.completedStepCount} sur ${task.steps.length}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: task.stepProgress,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: AppColors.border,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            for (final step in task.steps)
              CheckboxListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                controlAffinity: ListTileControlAffinity.leading,
                value: step.isDone,
                onChanged: canEdit ? (_) => widget.onStepToggle(step) : null,
                title: Text(
                  step.title,
                  style: AppTextStyles.small.copyWith(
                    decoration: step.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _TaskTag extends StatelessWidget {
  const _TaskTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _statusIcon(ParentTaskStatus status) {
  return switch (status) {
    ParentTaskStatus.todo => Icons.radio_button_unchecked_rounded,
    ParentTaskStatus.started => Icons.play_circle_outline_rounded,
    ParentTaskStatus.done => Icons.check_circle_outline_rounded,
    ParentTaskStatus.abandoned => Icons.spa_outlined,
  };
}

Color _statusColor(ParentTaskStatus status) {
  return switch (status) {
    ParentTaskStatus.todo => AppColors.textSecondary,
    ParentTaskStatus.started => AppColors.info,
    ParentTaskStatus.done => AppColors.success,
    ParentTaskStatus.abandoned => AppColors.violet,
  };
}

Color _importanceColor(ParentTaskImportance importance) {
  return switch (importance) {
    ParentTaskImportance.low => AppColors.turquoise,
    ParentTaskImportance.normal => AppColors.primary,
    ParentTaskImportance.high => AppColors.softOrange,
  };
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}
