import 'package:flutter/material.dart';

import '../../models/celebration.dart';
import '../../models/companion_child_experience.dart';
import '../../models/companion_moment.dart';
import '../../models/secret_mission.dart';

class CompanionIdeasPanel extends StatefulWidget {
  const CompanionIdeasPanel({
    super.key,
    required this.experience,
    required this.onIdeaConfirmed,
    required this.onNewIdeas,
    required this.onMyDay,
    required this.onClose,
    required this.onCelebrationDismissed,
    required this.onMissionAnnouncementDismissed,
    required this.onIdeasShown,
  });

  final CompanionChildExperience experience;
  final ValueChanged<CompanionMoment> onIdeaConfirmed;
  final VoidCallback onNewIdeas;
  final VoidCallback onMyDay;
  final VoidCallback onClose;
  final ValueChanged<Celebration> onCelebrationDismissed;
  final ValueChanged<SecretMission> onMissionAnnouncementDismissed;
  final ValueChanged<List<CompanionMoment>> onIdeasShown;

  @override
  State<CompanionIdeasPanel> createState() => _CompanionIdeasPanelState();
}

class _CompanionIdeasPanelState extends State<CompanionIdeasPanel> {
  String? _announcedIdeasKey;
  CompanionMoment? _selectedIdea;
  String? _dismissedCelebrationId;
  String? _dismissedMissionAnnouncementId;

  @override
  void initState() {
    super.initState();
    _announceIdeas();
  }

  @override
  void didUpdateWidget(covariant CompanionIdeasPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _announceIdeas();
  }

  void _announceIdeas() {
    final ideas = widget.experience.suggestions.ideas.take(3).toList();
    final key = ideas.map((idea) => idea.id).join('|');
    if (key.isEmpty || key == _announcedIdeasKey) return;
    _announcedIdeasKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onIdeasShown(ideas);
    });
  }

  @override
  Widget build(BuildContext context) {
    final celebration = widget.experience.celebration;
    if (celebration != null && celebration.id != _dismissedCelebrationId) {
      return _panel(
        child: _CelebrationContent(
          dialogue: widget.experience.dialogue,
          onContinue: () {
            setState(() => _dismissedCelebrationId = celebration.id);
            widget.onCelebrationDismissed(celebration);
          },
          reward: celebration.shardReward,
        ),
      );
    }
    final mission = widget.experience.missionAnnouncement;
    if (mission != null && mission.id != _dismissedMissionAnnouncementId) {
      return _panel(
        child: _AnnouncementContent(
          key: const ValueKey('mission-announcement'),
          icon: Icons.lock_open_rounded,
          dialogue: widget.experience.dialogue,
          onContinue: () {
            setState(() => _dismissedMissionAnnouncementId = mission.id);
            widget.onMissionAnnouncementDismissed(mission);
          },
        ),
      );
    }
    if (_selectedIdea case final selected?) {
      return _panel(
        child: _SelectedIdeaContent(
          idea: selected,
          onConfirm: () => widget.onIdeaConfirmed(selected),
          onCancel: () => setState(() => _selectedIdea = null),
        ),
      );
    }
    final ideas = widget.experience.suggestions.ideas.take(3).toList();
    return _panel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.experience.dialogue,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF3E4660),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          for (final idea in ideas) ...[
            _IdeaCard(
              key: ValueKey('companion-idea-${idea.id}'),
              idea: idea,
              onTap: () {
                setState(() => _selectedIdea = idea);
              },
            ),
            const SizedBox(height: 5),
          ],
          _MyDayCard(onTap: widget.onMyDay),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                key: const ValueKey('companion-more-ideas'),
                onPressed: widget.onNewIdeas,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('D’autres idées'),
              ),
              TextButton.icon(
                key: const ValueKey('companion-close'),
                onPressed: widget.onClose,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Fermer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) => Material(
    key: const ValueKey('companion-ideas-panel'),
    color: const Color(0xFFF7F1FF).withValues(alpha: .97),
    borderRadius: BorderRadius.circular(24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    ),
  );
}

class _CelebrationContent extends StatelessWidget {
  const _CelebrationContent({
    required this.dialogue,
    required this.onContinue,
    required this.reward,
  });
  final String dialogue;
  final VoidCallback onContinue;
  final int reward;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.celebration_rounded, color: Color(0xFFE09A32), size: 38),
      const SizedBox(height: 10),
      Text(
        dialogue,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF3E4660),
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 18),
      FilledButton(
        key: const ValueKey('companion-celebration-continue'),
        onPressed: onContinue,
        child: Text(reward > 0 ? 'Recevoir mes Éclats' : 'Continuer'),
      ),
    ],
  );
}

class _AnnouncementContent extends StatelessWidget {
  const _AnnouncementContent({
    super.key,
    required this.icon,
    required this.dialogue,
    required this.onContinue,
  });
  final IconData icon;
  final String dialogue;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: const Color(0xFFE09A32), size: 38),
      const SizedBox(height: 10),
      Text(
        dialogue,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF3E4660),
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 18),
      FilledButton(
        key: const ValueKey('mission-announcement-continue'),
        onPressed: onContinue,
        child: const Text('Continuer'),
      ),
    ],
  );
}

class _SelectedIdeaContent extends StatelessWidget {
  const _SelectedIdeaContent({
    required this.idea,
    required this.onConfirm,
    required this.onCancel,
  });
  final CompanionMoment idea;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('companion-selected-idea'),
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(
        Icons.auto_awesome_rounded,
        color: Color(0xFF3C7890),
        size: 34,
      ),
      const SizedBox(height: 8),
      const Text(
        'Super choix !',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
      ),
      const SizedBox(height: 10),
      Text(
        idea.title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
      ),
      const SizedBox(height: 6),
      Text(idea.shortDescription, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      const Text(
        'Passe un bon moment.',
        style: TextStyle(color: Color(0xFF3E4660), fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 18),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          TextButton(
            key: const ValueKey('companion-selected-cancel'),
            onPressed: onCancel,
            child: const Text('Choisir autre chose'),
          ),
          FilledButton(
            key: const ValueKey('companion-selected-done'),
            onPressed: onConfirm,
            child: const Text('C’est parti'),
          ),
        ],
      ),
    ],
  );
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({super.key, required this.idea, required this.onTap});

  final CompanionMoment idea;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF3C7890)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                idea.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${idea.durationMinutes} min',
              style: const TextStyle(fontSize: 11, color: Color(0xFF5D6B7B)),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    ),
  );
}

class _MyDayCard extends StatelessWidget {
  const _MyDayCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    key: const ValueKey('companion-my-day'),
    color: const Color(0xFF183746),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Color(0xFF79E3F2)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ma journée',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}
