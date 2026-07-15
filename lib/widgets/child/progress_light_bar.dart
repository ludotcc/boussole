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
        key: const ValueKey('daily-progress-right-rail'),
        width: 54 * .98,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1D2A36).withValues(alpha: .82),
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: const Color(0xFF276474), width: .8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: Color(0xFF27B7C2),
            ),
            const SizedBox(height: 5),
            const Text(
              'Ma\nLumière',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 8,
              height: 70,
              child: RotatedBox(
                quarterTurns: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: summary.ratio),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOut,
                    builder: (context, value, _) => LinearProgressIndicator(
                      minHeight: 8,
                      value: value,
                      backgroundColor: const Color(0xFFDDE8EF),
                      valueColor: AlwaysStoppedAnimation(
                        summary.ratio >= 1
                            ? const Color(0xFF54D6A4)
                            : const Color(0xFFFFBE55),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$percent %',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
