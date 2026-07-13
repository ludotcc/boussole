import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ParentAccessGesture extends StatefulWidget {
  const ParentAccessGesture({
    super.key,
    required this.child,
    this.holdDuration = const Duration(seconds: 5),
  });

  final Widget child;
  final Duration holdDuration;

  @override
  State<ParentAccessGesture> createState() => _ParentAccessGestureState();
}

class _ParentAccessGestureState extends State<ParentAccessGesture> {
  Timer? _timer;
  bool _triggered = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startHolding() {
    _timer?.cancel();
    _triggered = false;
    _timer = Timer(widget.holdDuration, () {
      if (!mounted) return;
      _triggered = true;
      context.push('/parent-unlock');
    });
  }

  void _stopHolding() {
    _timer?.cancel();
    _timer = null;
    if (_triggered) {
      _triggered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Accès parent',
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _startHolding(),
        onPointerUp: (_) => _stopHolding(),
        onPointerCancel: (_) => _stopHolding(),
        child: widget.child,
      ),
    );
  }
}
