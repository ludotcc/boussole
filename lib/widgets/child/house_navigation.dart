import 'package:flutter/material.dart';

class HouseNavigation extends StatelessWidget {
  const HouseNavigation({super.key, required this.onOpenToday});

  final VoidCallback onOpenToday;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _HouseAction(
          icon: Icons.today_rounded,
          label: 'Ma journée',
          color: const Color(0xFF2F80ED),
          onTap: onOpenToday,
        ),
        const _HouseAction(
          icon: Icons.auto_awesome_rounded,
          label: 'Les Trouvailles',
          color: Color(0xFF8B5CF6),
        ),
        const _HouseAction(
          icon: Icons.favorite_rounded,
          label: 'Moments partagés',
          color: Color(0xFF2EC5B6),
        ),
        const _HouseAction(
          icon: Icons.face_retouching_natural_rounded,
          label: 'Changer de Gardien',
          color: Color(0xFFFF9E42),
        ),
      ],
    );
  }
}

class _HouseAction extends StatelessWidget {
  const _HouseAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: enabled ? label : '$label, bientôt disponible',
      child: Material(
        color: Colors.white.withValues(alpha: enabled ? .94 : .72),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            width: 150,
            height: 92,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: enabled ? color : Colors.blueGrey,
                    size: 28,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      color: const Color(0xFF22304A),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  if (!enabled)
                    const Text(
                      'Bientôt',
                      style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
