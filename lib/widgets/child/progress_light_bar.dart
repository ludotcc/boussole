import 'package:flutter/material.dart';

import '../../models/daily_light_summary.dart';

class ProgressLightBar extends StatelessWidget {
  const ProgressLightBar({super.key, required this.summary});

  final DailyLightSummary summary;

  @override
  Widget build(BuildContext context) {
    final percent = (summary.ratio * 100).round();
    return Semantics(
      label: 'Ma Lumière, $percent pour cent',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 230),
        padding: const EdgeInsets.fromLTRB(18, 7, 18, 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 29, 42, 54).withValues(alpha: .72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color.fromARGB(255, 19, 51, 73).withValues(alpha: .82),
            width: .8,
          ),
          boxShadow: const [
            BoxShadow(color: Color.fromARGB(31, 233, 230, 222), blurRadius: 12),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: Color.fromARGB(255, 39, 183, 194),
                ),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Ma Lumière',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '$percent %',
                  style: const TextStyle(
                    color: Color(0xFF6D7885),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: summary.ratio),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOut,
                builder: (context, value, _) => LinearProgressIndicator(
                  minHeight: 5,
                  value: value,
                  backgroundColor: const Color(0xFFDDE8EF),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFFBE55)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
