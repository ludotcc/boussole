import 'package:flutter/material.dart';

class BoussoleButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? .97 : 1,
        child: Container(
          height: 74,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? const LinearGradient(
                    colors: [Color(0xff4096FF), Color(0xff47D7C9)],
                  )
                : null,
            color: widget.isPrimary ? null : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: widget.isPrimary
                ? null
                : Border.all(color: const Color(0xffD8E5FF), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.isPrimary
                        ? Colors.white.withOpacity(.18)
                        : const Color(0xffEEF5FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.isPrimary
                        ? Colors.white
                        : const Color(0xff3A86FF),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: widget.isPrimary
                          ? Colors.white
                          : const Color(0xff3A86FF),
                    ),
                  ),
                ),

                const SizedBox(width: 42),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
