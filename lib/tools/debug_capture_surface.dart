import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'screen_capture_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DebugCaptureSurface
//
// Wraps the router's widget tree (injected via MaterialApp.router builder)
// with a root RepaintBoundary and a persistent 📷 FAB overlay that:
//   • Hides itself before capturing (so it's absent from the PNG)
//   • Auto-numbers screenshots → exported_screenshots/shot_001.png …
//   • Shows a brief filename toast after each save
//
// Only active in debug builds (kDebugMode). In release builds the wrapper
// is a transparent passthrough, so no prod impact.
// ─────────────────────────────────────────────────────────────────────────────

class DebugCaptureSurface extends StatefulWidget {
  const DebugCaptureSurface({super.key, required this.child});

  final Widget child;

  @override
  State<DebugCaptureSurface> createState() => _DebugCaptureSurfaceState();
}

class _DebugCaptureSurfaceState extends State<DebugCaptureSurface> {
  final _svc      = ScreenCaptureService.instance;
  String? _toastMsg;

  Future<void> _capture() async {
    final path = await _svc.captureAndSave();
    if (!mounted) return;
    if (path != null) {
      // Extract just the filename for the toast
      final name = path.replaceAll('\\', '/').split('/').last;
      setState(() => _toastMsg = 'Saved: $name');
      // Clear toast after 3 s
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _toastMsg = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    return Stack(
      children: [
        // ── Root RepaintBoundary — captures everything below ─────────────────
        RepaintBoundary(
          key: _svc.boundaryKey,
          child: widget.child,
        ),

        // ── Floating capture button + toast ───────────────────────────────────
        ValueListenableBuilder<bool>(
          valueListenable: _svc.capturing,
          builder: (_, capturing, __) {
            if (capturing) return const SizedBox.shrink();

            return Positioned(
              bottom: 88,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Filename toast
                  if (_toastMsg != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xDD0a1a0a),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF44aa44)),
                      ),
                      child: Text(
                        _toastMsg!,
                        style: const TextStyle(
                            color: Color(0xFF88dd88), fontSize: 11),
                      ),
                    ),

                  // Camera FAB
                  FloatingActionButton.small(
                    heroTag: 'debug_capture',
                    backgroundColor: const Color(0xDD1a1a2e),
                    foregroundColor: Colors.white,
                    onPressed: _capture,
                    child: const Icon(Icons.camera_alt, size: 18),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
