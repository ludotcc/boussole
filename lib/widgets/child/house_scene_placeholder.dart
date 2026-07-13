import 'package:flutter/material.dart';

class HouseScenePlaceholder extends StatelessWidget {
  const HouseScenePlaceholder({super.key, required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: .9), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22304A).withValues(alpha: .12),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF7CC7FF)],
              ),
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 62,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Bienvenue dans ta Maison, $childName',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF22304A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ton Gardien prépare doucement son arrivée. Ta Maison est déjà là pour t’accompagner.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B6B82),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
