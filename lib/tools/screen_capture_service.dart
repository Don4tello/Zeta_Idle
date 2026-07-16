import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScreenCaptureService
//
// Singleton that owns the GlobalKey attached to the root RepaintBoundary
// (see DebugCaptureSurface in main.dart) and handles the async
// capture → PNG → disk pipeline.
//
// Usage:
//   final path = await ScreenCaptureService.instance.captureAndSave();
// ─────────────────────────────────────────────────────────────────────────────

class ScreenCaptureService {
  ScreenCaptureService._();
  static final instance = ScreenCaptureService._();

  /// Attached to the root RepaintBoundary via DebugCaptureSurface.
  final GlobalKey boundaryKey = GlobalKey();

  /// True while a capture is in progress — used to hide the FAB so it
  /// doesn't appear in the captured image.
  final ValueNotifier<bool> capturing = ValueNotifier(false);

  Future<String?> captureAndSave() async {
    capturing.value = true;

    // Give the UI one frame to hide the button before capturing.
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 80));

    try {
      final obj = boundaryKey.currentContext?.findRenderObject();
      if (obj is! RenderRepaintBoundary) {
        debugPrint('ScreenCapture: boundary not found');
        return null;
      }

      final image    = await obj.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) return null;

      final outDir = Directory('exported_screenshots');
      await outDir.create(recursive: true);

      // Auto-number: shot_001.png, shot_002.png …
      int n = 1;
      late File file;
      do {
        file = File('${outDir.path}/shot_${n.toString().padLeft(3, '0')}.png');
        n++;
      } while (file.existsSync());

      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } finally {
      capturing.value = false;
    }
  }
}
