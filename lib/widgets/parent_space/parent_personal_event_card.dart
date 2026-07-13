import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/parent_personal_event_model.dart';
import '../agenda/compact_expandable_event_card.dart';

class ParentPersonalEventCard extends StatelessWidget {
  const ParentPersonalEventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final ParentPersonalEventModel event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CompactExpandableEventCard(
      title: event.title,
      icon: _eventIcon(event.type),
      color: _eventColor(event.type),
      menuItems: const [
        PopupMenuItem(value: 'edit', child: Text('Modifier')),
        PopupMenuItem(value: 'delete', child: Text('Supprimer')),
      ],
      onMenuSelected: (value) {
        if (value == 'edit') {
          onEdit();
        }

        if (value == 'delete') {
          onDelete();
        }
      },
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailLine(
            icon: Icons.calendar_month_rounded,
            label: _formatEventDate(event.date),
          ),
          const SizedBox(height: 6),
          _DetailLine(
            icon: Icons.schedule_rounded,
            label: event.isAllDay
                ? 'Toute la journée'
                : _formatEventTime(event.time),
          ),
          const SizedBox(height: 8),
          _EventTypeChip(
            label: _eventTypeLabel(event.type),
            color: _eventColor(event.type),
          ),
          if (event.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              event.description!.trim(),
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
                height: 1.25,
              ),
            ),
          ],
          if (event.recurrenceType != 'none' || event.shareWithFamily) ...[
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.recurrenceType != 'none')
                  Text(
                    _recurrenceLabel(event.recurrenceType),
                    style: AppTextStyles.caption,
                  ),
                if (event.shareWithFamily)
                  Text(
                    'Partagé avec l’agenda familial',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventTypeChip extends StatelessWidget {
  const _EventTypeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

IconData _eventIcon(String type) {
  return switch (type) {
    'travail' => Icons.work_rounded,
    'sante' => Icons.favorite_rounded,
    'famille' => Icons.family_restroom_rounded,
    'rendezVous' => Icons.event_available_rounded,
    _ => Icons.event_note_rounded,
  };
}

Color _eventColor(String type) {
  return switch (type) {
    'travail' => AppColors.primary,
    'sante' => const Color(0xFFE87393),
    'famille' => AppColors.violet,
    'rendezVous' => AppColors.softOrange,
    _ => AppColors.turquoise,
  };
}

String _formatEventTime(String? time) {
  final value = time?.trim();

  if (value == null || value.isEmpty) {
    return 'Heure à préciser';
  }

  return value.replaceAll(':', 'h');
}

String _formatEventDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

String _eventTypeLabel(String type) {
  return switch (type) {
    'personnel' => 'Personnel',
    'travail' => 'Travail',
    'sante' => 'Santé',
    'famille' => 'Famille',
    'rendezVous' => 'Rendez-vous',
    _ => 'Autre',
  };
}

String _recurrenceLabel(String recurrenceType) {
  return switch (recurrenceType) {
    'daily' => 'Tous les jours',
    'weekly' => 'Chaque semaine',
    'monthly' => 'Chaque mois',
    'yearly' => 'Chaque année',
    _ => 'Jamais',
  };
}
