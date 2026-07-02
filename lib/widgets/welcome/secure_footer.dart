import 'package:flutter/material.dart';

class SecureFooter extends StatelessWidget {
  const SecureFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: .90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_rounded, size: 16, color: Color(0xFF2E9C76)),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                "Données sécurisées et confidentielles",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C6675),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
