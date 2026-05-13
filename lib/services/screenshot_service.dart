import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:MotionReach/config/api_config.dart';
import 'package:MotionReach/main.dart' show screenshotBoundaryKey;

/// Captures the current Flutter widget tree to a PNG and uploads it to
/// `POST /api/v1/remotes/screenshot` with the originating `command_id`.
///
/// This doesn't capture anything outside the Flutter canvas (native Android
/// dialogs, the system status bar, etc.). For the digital-signage use case
/// that's sufficient — the admin just wants to see which ad is playing.
class ScreenshotService {
  ScreenshotService._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );

  /// Captures + uploads the current screen. Returns true on success.
  static Future<bool> captureAndUpload(String commandId) async {
    final bytes = await _captureAsPng();
    if (bytes == null) return false;

    try {
      final formData = FormData.fromMap({
        'command_id': commandId,
        'vehicle_plate': ApiConfig.vehiclePlate,
        'image': MultipartFile.fromBytes(
          bytes,
          filename: 'screenshot.png',
        ),
      });
      final response = await _dio.post(
        '/api/v1/remotes/screenshot',
        data: formData,
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (_) {
      return false;
    }
  }

  static Future<Uint8List?> _captureAsPng() async {
    try {
      final context = screenshotBoundaryKey.currentContext;
      if (context == null) return null;

      final boundary =
          context.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // A pixelRatio of 1.0 keeps file size small; bump to device pixel ratio
      // if higher resolution is desired.
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
