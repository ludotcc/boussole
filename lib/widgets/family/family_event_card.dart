import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/family_event_model.dart';
import '../../models/family_member_model.dart';
import '../agenda/compact_expandable_event_card.dart';
import '../common/avatar_circle.dart';
import 'family_event_style.dart';

class FamilyEventCard extends StatelessWidget {
  const FamilyEventCard({
    super.key,
    required this.event,
    required this.members,
    required this.onEdit,
    required this.onDelete,
  });

  final FamilyEventModel event;
  final List<FamilyMemberModel> members;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final selectedMembers = members
        .where((member) => event.memberIds.contains(member.id))
        .toList();

    return CompactExpandableEventCard(
      title: event.title,
      subtitle: _formatEventDate(event.date),
      icon: familyEventIcon(event.type),
      color: familyEventColor(event.type),
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
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _EventBadge(
                label: _eventTypeLabel(event.type),
                color: familyEventColor(event.type),
              ),
              if (event.recurrenceType != 'none')
                _EventBadge(
                  label: _recurrenceLabel(event.recurrenceType),
                  color: AppColors.violet,
                ),
              if (event.isSensitiveMoment)
                const _EventBadge(
                  label: 'Accompagnement doux',
                  color: AppColors.violet,
                ),
            ],
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
          const SizedBox(height: 8),
          if (selectedMembers.isEmpty)
            Text(
              'Toute la famille',
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final member in selectedMembers.take(4))
                  _MemberChip(member: member),
                if (selectedMembers.length > 4)
                  _MoreMembersChip(count: selectedMembers.length - 4),
              ],
            ),
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

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.member});

  final FamilyMemberModel member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardSecondary.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarCircle(imagePath: member.avatar, radius: 9),
          const SizedBox(width: 5),
          Text(member.firstName, style: AppTextStyles.small),
        ],
      ),
    );
  }
}

class _MoreMembersChip extends StatelessWidget {
  const _MoreMembersChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardSecondary.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('+$count', style: AppTextStyles.small),
    );
  }
}

class _EventBadge extends StatelessWidget {
  const _EventBadge({required this.label, required this.color});

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

String _eventTypeLabel(String type) {
  return switch (type) {
    'sante' => 'Santé',
    'ecole' => 'École',
    'activite' => 'Activité',
    'famille' => 'Famille',
    'anniversaire' => 'Anniversaire',
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
