import 'package:flutter/material.dart';

class HouseNavigation extends StatelessWidget {
  const HouseNavigation({
    super.key,
    required this.onOpenFindings,
    required this.onOpenSharedMoments,
    required this.onChangeGuardian,
  });

  final VoidCallback onOpenFindings;
  final VoidCallback onOpenSharedMoments;
  final VoidCallback onChangeGuardian;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 5.0;
                final width = (constraints.maxWidth - spacing * 2) / 3;
                return Row(
                  children: [
                    _HouseAction(
                      width: width,
                      icon: Icons.auto_awesome_rounded,
                      label: 'Les Trouvailles',
                      onTap: onOpenFindings,
                    ),
                    const SizedBox(width: spacing),
                    _HouseAction(
                      width: width,
                      icon: Icons.favorite_rounded,
                      onTap: onOpenSharedMoments,
                      label: 'Moments partagés',
                    ),
                    const SizedBox(width: spacing),
                    _HouseAction(
                      width: width,
                      icon: Icons.face_retouching_natural_rounded,
                      label: 'Changer de Gardien',
                      onTap: onChangeGuardian,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HouseAction extends StatelessWidget {
  const _HouseAction({
    required this.width,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: onTap == null ? '$label, bientôt disponible' : label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: width,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(
                0xFF263B50,
              ).withValues(alpha: onTap == null ? .40 : .74),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: onTap == null ? .24 : .5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: onTap == null
                          ? Colors.white38
                          : const Color(0xFFFFD87C),
                      size: 20,
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white70,
                        size: 12,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (onTap == null)
                  const Text(
                    'Bientôt',
                    style: TextStyle(color: Color(0xFF7B8797), fontSize: 8),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
