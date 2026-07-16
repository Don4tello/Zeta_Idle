import 'dart:async';
import 'package:flutter/material.dart';

/// Fires [onPressed] immediately on press, then repeatedly while held.
/// Null [onPressed] disables all interaction.
class HoldRepeatButton extends StatefulWidget {
  const HoldRepeatButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.initialDelay = const Duration(milliseconds: 420),
    this.repeatInterval = const Duration(milliseconds: 80),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Duration initialDelay;
  final Duration repeatInterval;

  @override
  State<HoldRepeatButton> createState() => _HoldRepeatButtonState();
}

class _HoldRepeatButtonState extends State<HoldRepeatButton> {
  Timer? _delay;
  Timer? _repeat;

  void _fire() => widget.onPressed?.call();

  void _start(PointerDownEvent _) {
    if (widget.onPressed == null) return;
    _fire();
    _delay = Timer(widget.initialDelay, () {
      _repeat = Timer.periodic(widget.repeatInterval, (_) => _fire());
    });
  }

  void _stop([PointerEvent? _]) {
    _delay?.cancel();
    _repeat?.cancel();
    _delay = _repeat = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _start,
      onPointerUp: _stop,
      onPointerCancel: _stop,
      child: widget.child,
    );
  }
}
