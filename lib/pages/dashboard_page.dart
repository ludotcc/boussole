import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/constants/avatar_constants.dart';
import '../models/child_model.dart';
import '../models/family_event_model.dart';
import '../models/family_member_model.dart';
import '../providers/children_provider.dart';
import '../providers/companion_provider.dart';
import '../providers/dashboard_refresh_provider.dart';
import '../providers/family_events_provider.dart';
import '../providers/family_members_provider.dart';
import '../providers/family_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/common/avatar_circle.dart';
import '../widgets/family/family_event_style.dart';

const parentCompanionCardTitle = 'Compagnon';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(familyRepositoryProvider).signOut();
    ref.read(sessionProvider.notifier).clearSession();

    if (context.mounted) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRefreshing = ref.watch(dashboardRefreshProvider);

    Future<void> refreshDashboard() {
      return ref.read(dashboardRefreshProvider.notifier).refresh();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Bienvenue'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _signOut(context, ref),
          ),
        ],
      ),
      body: _DashboardBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isRefreshing) ...[
                    const LinearProgressIndicator(minHeight: 3),
                    const SizedBox(height: 14),
                  ],
                  const _DashboardGreeting(),
                  const SizedBox(height: 34),
                  const _ChildrenAccessSection(),
                  const SizedBox(height: 36),
                  const _QuickAccessSection(),
                  const SizedBox(height: 36),
                  const _UpcomingFamilyEventsSection(),
                  const SizedBox(height: 30),
                  const _MoreOptionsCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardGreeting extends ConsumerWidget {
  const _DashboardGreeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(currentFamilyProvider).valueOrNull;
    final familyName = (family?.name.trim() ?? '').toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bonjour à toute la famille',
              textAlign: TextAlign.center,
              style: AppTextStyles.h2.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color.fromARGB(255, 68, 93, 117),
                height: 1.05,
              ),
            ),

            if (familyName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                familyName,
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: const Color.fromARGB(255, 68, 93, 117),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChildrenAccessSection extends ConsumerWidget {
  const _ChildrenAccessSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider);

    return childrenAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (children) {
        if (children.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(title: 'Profils enfants'),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth / 1.3;

                return SizedBox(
                  height: 135,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: children.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      return _ChildTodayCard(
                        child: children[index],
                        width: cardWidth.clamp(150, 150).toDouble(),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _QuickAccessSection extends ConsumerWidget {
  const _QuickAccessSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(familyMembersProvider);
    final attentionCount =
        ref.watch(parentAttentionCountProvider).valueOrNull ?? 0;

    return membersAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(title: 'Accès rapides'),
          const SizedBox(height: 12),
          _DashboardImageCard(
            title: 'Agenda familial',
            subtitle: 'Voir les moments importants',
            imagePath: 'assets/images/objects/page_planning.png',
            color: AppColors.gold,
            onTap: () => context.push('/family-agenda'),
          ),
        ],
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (members) {
        final papa = _firstParentByType(members, 'papa');
        final maman = _firstParentByType(members, 'maman');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(title: 'Accès rapides'),
            const SizedBox(height: 12),
            _DashboardImageCard(
              title: 'Agenda familial',
              subtitle: 'Voir les moments importants',
              imagePath: 'assets/images/objects/page_planning.png',
              color: AppColors.gold,
              onTap: () => context.push('/family-agenda'),
            ),
            const SizedBox(height: 16),
            _DashboardImageCard(
              title: parentCompanionCardTitle,
              subtitle: 'Missions, mémoires et célébrations',
              imagePath: 'assets/images/objects/page_planning.png',
              color: AppColors.primary,
              onTap: () => context.push('/parent/mission-validations'),
              attentionCount: attentionCount,
            ),
            if (papa != null) ...[
              const SizedBox(height: 16),
              _ParentSpaceCard(
                parent: papa,
                imagePath: 'assets/images/objects/page_papa.png',
              ),
            ],
            if (maman != null) ...[
              const SizedBox(height: 16),
              _ParentSpaceCard(
                parent: maman,
                imagePath: 'assets/images/objects/page_maman.png',
              ),
            ],
          ],
        );
      },
    );
  }
}

class _UpcomingFamilyEventsSection extends ConsumerWidget {
  const _UpcomingFamilyEventsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingEvents = ref.watch(upcomingFamilyEventsProvider);

    return upcomingEvents.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (events) {
        if (events.isEmpty) {
          return const SizedBox.shrink();
        }

        final visibleEvents = events.take(3).toList();

        return _SoftSection(
          title: 'À venir',
          trailing: TextButton(
            onPressed: () => context.push('/family-agenda'),
            child: const Text('Voir tout'),
          ),
          child: Column(
            children: [
              for (var index = 0; index < visibleEvents.length; index++) ...[
                _UpcomingEventTile(event: visibleEvents[index]),
                if (index < visibleEvents.length - 1)
                  const SizedBox(height: 14),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MoreOptionsCard extends StatelessWidget {
  const _MoreOptionsCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardImageCard(
      title: 'Plus d’options',
      subtitle:
          'Gestion des membres, paramètres famille, aide et informations.',
      imagePath: 'assets/images/objects/page_planning.png',
      color: AppColors.primary,
      compactImage: true,
      onTap: () => _showMoreOptions(context),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Plus d’options', style: AppTextStyles.h2),
                const SizedBox(height: 14),
                _OptionSheetButton(
                  icon: Icons.calendar_month_rounded,
                  label: 'Planning familial',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/planner');
                  },
                ),
                _OptionSheetButton(
                  icon: Icons.family_restroom_rounded,
                  label: 'Mes membres',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/members');
                  },
                ),
                _OptionSheetButton(
                  icon: Icons.settings_rounded,
                  label: 'Paramètres famille',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/family-settings');
                  },
                ),
                _OptionSheetButton(
                  icon: Icons.info_outline_rounded,
                  label: 'Aide / informations',
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParentSpaceCard extends StatelessWidget {
  const _ParentSpaceCard({required this.parent, required this.imagePath});

  final FamilyMemberModel parent;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return _DashboardImageCard(
      title: parent.firstName,
      subtitle: 'Agenda personnel et priorités',
      imagePath: _parentAvatarPath(parent.avatar, fallback: imagePath),
      color: AppColors.violet,
      onTap: () => context.push('/parent-space', extra: parent),
    );
  }
}

String _parentAvatarPath(String avatar, {required String fallback}) {
  final avatarId = avatar.trim();
  if (avatarId.isEmpty) {
    return fallback;
  }

  if (avatarId.startsWith('assets/')) {
    return avatarId;
  }

  try {
    return AvatarConstants.assetFromId(avatarId);
  } catch (_) {
    return fallback;
  }
}

class _ChildTodayCard extends StatelessWidget {
  const _ChildTodayCard({required this.child, required this.width});

  final ChildModel child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final roleLabel = child.profileType == 'baby' ? 'Bébé' : 'Enfant';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          context.push('/child/${child.id}/house');
        },
        child: Ink(
          width: width,
          height: 125,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .82),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: .72)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .08),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarCircle(
                imagePath: child.avatar,
                radius: 24,
                icon: Icons.child_care_rounded,
              ),
              const SizedBox(height: 14),
              Text(
                child.firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 2),
              Text(
                '$roleLabel · ${child.age} ans',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.small,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftSection extends StatelessWidget {
  const _SoftSection({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .72)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _SectionTitle(title: title)),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.cardTitle);
  }
}

class _UpcomingEventTile extends StatelessWidget {
  const _UpcomingEventTile({required this.event});

  final FamilyEventModel event;

  @override
  Widget build(BuildContext context) {
    final color = familyEventColor(event.type);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(familyEventIcon(event.type), color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                _formatUpcomingDate(event),
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionSheetButton extends StatelessWidget {
  const _OptionSheetButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white.withValues(alpha: .86),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: AppTextStyles.body)),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardImageCard extends StatelessWidget {
  const _DashboardImageCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.color,
    required this.onTap,
    this.compactImage = false,
    this.attentionCount = 0,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;
  final bool compactImage;
  final int attentionCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(compactImage ? 12 : 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .86),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: .72)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: compactImage ? 42 : 80,
                height: compactImage ? 42 : 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(compactImage ? 16 : 24),
                ),
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: compactImage ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: compactImage
                          ? AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            )
                          : AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small.copyWith(
                        height: 1.2,
                        color: compactImage ? AppColors.textSecondary : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (attentionCount > 0) ...[
                Container(
                  key: const ValueKey('parent-attention-badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$attentionCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withValues(alpha: .68),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBackground extends StatelessWidget {
  const _DashboardBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/backgrounds/background_base.png',
          fit: BoxFit.cover,
        ),
        Container(color: Colors.white.withValues(alpha: .50)),
        child,
      ],
    );
  }
}

FamilyMemberModel? _firstParentByType(
  List<FamilyMemberModel> members,
  String profileType,
) {
  for (final member in members) {
    if (member.isAdult && member.profileType == profileType) {
      return member;
    }
  }

  return null;
}

String _formatUpcomingDate(FamilyEventModel event) {
  final day = event.date.day.toString().padLeft(2, '0');
  final month = event.date.month.toString().padLeft(2, '0');
  final time = event.isAllDay || event.time == null || event.time!.isEmpty
      ? ''
      : ' · ${event.time!.replaceAll(':', 'h')}';

  return '$day/$month/${event.date.year}$time';
}
