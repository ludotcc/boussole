import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../core/constants/avatar_constants.dart';
import '../models/family_member_model.dart';
import '../providers/companion_provider.dart';
import '../providers/family_members_provider.dart';
import '../providers/mission_provider.dart';
import '../widgets/common/section_card.dart';
import '../widgets/common/avatar_circle.dart';
import '../widgets/family/parent_rewards_section.dart';

class ParentMissionValidationsPage extends ConsumerStatefulWidget {
  const ParentMissionValidationsPage({super.key});

  @override
  ConsumerState<ParentMissionValidationsPage> createState() =>
      _ParentMissionValidationsPageState();
}

class _ParentMissionValidationsPageState
    extends ConsumerState<ParentMissionValidationsPage> {
  String? _selectedChildId;

  @override
  Widget build(BuildContext context) {
    final missions = ref.watch(pendingMissionValidationsProvider);
    final members = ref.watch(familyMembersProvider).valueOrNull ?? const [];
    final children = members.where((member) => !member.isAdult).toList();
    final selectedChild = children.isEmpty
        ? null
        : children.firstWhere(
            (child) => child.id == _selectedChildId,
            orElse: () => children.first,
          );
    final action = ref.watch(missionValidationProvider);

    String childName(String id) {
      for (final child in children) {
        if (child.id == id) return child.firstName;
      }
      return 'Enfant';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Compagnon')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _PageIntroduction(),
            const SizedBox(height: 16),
            if (selectedChild != null) ...[
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: children.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final child = children[index];
                    final selected = child.id == selectedChild.id;
                    return ChoiceChip(
                      avatar: AvatarCircle(
                        key: ValueKey('companion-child-avatar-${child.id}'),
                        imagePath: _validAvatarId(child.avatar),
                        radius: 18,
                        icon: Icons.child_care_rounded,
                      ),
                      label: Text(child.firstName),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedChildId = child.id),
                    );
                  },
                ),
              ),
              ParentRewardsSection(child: selectedChild, allowRedemption: true),
              const SizedBox(height: 16),
            ],
            missions.when(
              loading: () => const SectionCard(
                title: 'Missions Secrètes',
                icon: Icons.lock_rounded,
                accentColor: AppColors.violet,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SectionCard(
                title: 'Missions Secrètes',
                icon: Icons.lock_rounded,
                accentColor: AppColors.violet,
                child: _EmptySection('Impossible de charger les validations.'),
              ),
              data: (items) => SectionCard(
                title: 'Missions Secrètes',
                icon: Icons.lock_rounded,
                accentColor: AppColors.violet,
                action: items.isEmpty
                    ? null
                    : _PendingBadge(
                        key: const ValueKey('missions-pending-badge'),
                        count: items.length,
                      ),
                child: items.isEmpty
                    ? const _EmptySection(
                        'Aucune Mission n’attend de validation.',
                      )
                    : Column(
                        children: [
                          for (final mission in items) ...[
                            _MissionCard(
                              childName: childName(mission.childId),
                              title: mission.title,
                              description: mission.description,
                              isLoading: action.isLoading,
                              onRefuse: () => ref
                                  .read(missionValidationProvider.notifier)
                                  .refuse(mission),
                              onValidate: () => ref
                                  .read(missionValidationProvider.notifier)
                                  .validate(mission),
                            ),
                            if (mission != items.last)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'Célébrations',
              icon: Icons.celebration_rounded,
              accentColor: AppColors.softOrange,
              child: children.isEmpty
                  ? const _EmptySection('Aucun enfant disponible.')
                  : Column(
                      children: [
                        for (final child in children) ...[
                          _AccessTile(
                            icon: Icons.favorite_rounded,
                            title: child.firstName,
                            subtitle: 'Préparer une célébration',
                            onTap: () => context.push(
                              '/parent/celebrations',
                              extra: child,
                            ),
                          ),
                          if (child != children.last) const SizedBox(height: 8),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'Mémoires',
              icon: Icons.psychology_alt_rounded,
              accentColor: AppColors.primary,
              child: children.isEmpty
                  ? const _EmptySection('Aucun enfant disponible.')
                  : Column(
                      children: [
                        for (final child in children) ...[
                          _MemoryAccessTile(child: child),
                          if (child != children.last) const SizedBox(height: 8),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validAvatarId(String avatarId) {
    if (avatarId.isEmpty) return null;
    return AvatarConstants.allAvatars.any((avatar) => avatar.id == avatarId)
        ? avatarId
        : null;
  }
}

class _PageIntroduction extends StatelessWidget {
  const _PageIntroduction();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      'Validez les moments importants et préparez les encouragements du Compagnon.',
      style: TextStyle(color: AppColors.textSecondary, height: 1.35),
    ),
  );
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.childName,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.onRefuse,
    required this.onValidate,
  });

  final String childName;
  final String title;
  final String description;
  final bool isLoading;
  final VoidCallback onRefuse;
  final VoidCallback onValidate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.cardSecondary,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          childName,
          style: const TextStyle(
            color: AppColors.violet,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(description),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onRefuse,
                child: const Text('Refuser'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: isLoading ? null : onValidate,
                child: const Text('Valider'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _EmptySection extends StatelessWidget {
  const _EmptySection(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.cardSecondary,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      message,
      style: const TextStyle(color: AppColors.textSecondary),
    ),
  );
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.warning.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$count',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _MemoryAccessTile extends ConsumerWidget {
  const _MemoryAccessTile({required this.child});

  final FamilyMemberModel child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(companionMemoriesProvider(child.id));
    final count =
        memories.valueOrNull?.where((memory) => memory.isProposed).length ?? 0;
    return _AccessTile(
      icon: Icons.psychology_alt_rounded,
      title: child.firstName,
      subtitle: count == 0
          ? 'Aucune mémoire à valider'
          : '$count mémoire${count > 1 ? 's' : ''} à valider',
      badge: count == 0
          ? null
          : _PendingBadge(
              key: ValueKey('memories-pending-badge-${child.id}'),
              count: count,
            ),
      onTap: () => context.push('/parent/companion-memories', extra: child),
    );
  }
}

class _AccessTile extends StatelessWidget {
  const _AccessTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.cardSecondary,
    borderRadius: BorderRadius.circular(16),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?badge,
          if (badge != null) const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    ),
  );
}
