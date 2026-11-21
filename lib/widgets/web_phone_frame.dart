import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Constrains the app to a centered phone-width column on the web build, so the
/// portrait-designed UI doesn't stretch edge-to-edge on a desktop browser.
/// No-op on native and on already-narrow (phone/tablet) web viewports.
///
/// Overrides MediaQuery.size to the framed width so responsive breakpoints
/// (e.g. the `width < 600` phone check) behave as on a real phone.
class WebPhoneFrame extends StatelessWidget {
  const WebPhoneFrame({super.key, required this.child});
  final Widget child;

  /// Logical width of the phone frame — a large-phone portrait width.
  static const double _frameWidth = 440;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    final mq = MediaQuery.of(context);
    // Leave narrow viewports (actual phones) alone.
    if (mq.size.width <= _frameWidth + 1) return child;

    return ColoredBox(
      color: const Color(0xFF0A0908), // letterbox backdrop
      child: Center(
        child: Container(
          width: _frameWidth,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 32,
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: MediaQuery(
            // Report the framed width so `MediaQuery.size.width` checks see a phone.
            data: mq.copyWith(size: Size(_frameWidth, mq.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}
