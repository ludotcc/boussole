import 'package:flutter/material.dart';

class BoussoleButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const BoussoleButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  State<BoussoleButton> createState() => _BoussoleButtonState();
}

class _BoussoleButtonState extends State<BoussoleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color blue = const Color(0xFF3A86FF);
    final bool enabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: _pressed ? .97 : 1,
        child: Opacity(
          opacity: enabled ? 1 : .5,
          child: Container(
            height: 62,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: widget.isPrimary
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4D96FF), Color(0xFF3ED8C4)],
                    )
                  : null,
              color: widget.isPrimary ? null : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: widget.isPrimary
                  ? null
                  : Border.all(color: const Color(0xFFD7E6FF), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.isPrimary
                          ? Colors.white.withValues(alpha: .20)
                          : const Color(0xFFEFF5FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isPrimary ? Colors.white : blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: widget.isPrimary ? Colors.white : blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
