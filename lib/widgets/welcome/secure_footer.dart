import 'package:flutter/material.dart';

class SecureFooter extends StatelessWidget {
  const SecureFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.lock_rounded, size: 17, color: Color(0xff2E9C76)),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              "Données sécurisées et confidentielles",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xff54606D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
