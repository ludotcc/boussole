import 'package:flutter/material.dart';

class GuardianChoicesPanel extends StatelessWidget {
  const GuardianChoicesPanel({
    super.key,
    required this.onFirstChoice,
    required this.onSecondChoice,
    required this.onClose,
    this.secretMission = false,
  });

  final VoidCallback onFirstChoice;
  final VoidCallback onSecondChoice;
  final VoidCallback onClose;
  final bool secretMission;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _ChoiceCard(
                  key: const ValueKey('guardian-choice-first'),
                  icon: secretMission
                      ? Icons.lock_rounded
                      : Icons.today_rounded,
                  label: secretMission
                      ? 'Découvrir la mission'
                      : 'Continuer ma journée',
                  onTap: onFirstChoice,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChoiceCard(
                  key: const ValueKey('guardian-choice-second'),
                  icon: secretMission
                      ? Icons.schedule_rounded
                      : Icons.auto_awesome_rounded,
                  label: secretMission
                      ? 'Pas maintenant'
                      : 'Découvrir mes Trouvailles',
                  onTap: onSecondChoice,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Fermer'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: const Color(0xFF526174),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFFFBF4).withValues(alpha: .94),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF3C7890), size: 24),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Color(0xFF33465C),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
