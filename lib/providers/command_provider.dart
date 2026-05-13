import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:MotionReach/config/api_config.dart';
import 'package:MotionReach/services/screenshot_service.dart';
import 'package:MotionReach/views/pages/default_page.dart';
import 'package:MotionReach/views/pages/sleep_page.dart';

/// Polls the BackOffice for pending commands and dispatches them to the
/// relevant device controls.
///
/// Supported commands:
///   • `screen_on`       → navigate to DefaultPage
///   • `screen_off`      → navigate to SleepModeScreen
///   • `volume`          → payload `{value: 0..100}` → native setVolume
///   • `brightness`      → payload `{value: 0..100}` → native setBrightness
///   • `clear_cache`     → clears Flutter image + file caches
///   • `reboot`          → native `restartApp` (closes + relaunches the app)
///   • `take_screenshot` → no-op for now (Feature 3, not yet implemented)
class CommandProvider {
  CommandProvider._internal();

  static final CommandProvider instance = CommandProvider._internal();

  /// Shared MethodChannel with the native Android layer. Matches the channel
  /// name set up in SettingsbarWidget and MainActivity.kt.
  static const MethodChannel _deviceChannel =
      MethodChannel('com.motionreach/device_controls');

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );

  Timer? _pollTimer;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Tracks whether the tablet is on an active page (true) or the
  /// SleepModeScreen (false). Sent as a heartbeat hint on every poll so
  /// /remotes can show the real on/off state.
  ///
  /// Source of truth is the SleepModeScreen widget lifecycle
  /// (see [markScreenOff] / [markScreenOn]) — that way any way of entering or
  /// exiting sleep (command, tap-to-wake, auto-return timer) stays correct.
  bool _screenOn = true;

  bool _isScreenOn() => _screenOn;

  /// Called by SleepModeScreen.initState so the next heartbeat reports off.
  void markScreenOff() {
    _screenOn = false;
  }

  /// Called by SleepModeScreen.dispose so the next heartbeat reports on.
  void markScreenOn() {
    _screenOn = true;
  }

  void start(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll() async {
    try {
      // Query current device levels so /remotes can render live sliders.
      // Native returns 0.0–1.0; we convert to 0–100 ints. Failures are
      // non-fatal — we just omit the key and the server keeps the last
      // known value.
      final levels = await _readDeviceLevels();

      final response = await _dio.get(
        ApiConfig.pendingCommandsEndpoint,
        queryParameters: {
          'vehicle_plate': ApiConfig.vehiclePlate,
          // Heartbeat hint so /remotes shows accurate screen state.
          // true when the tablet is on an active page, false when the
          // SleepModeScreen is displayed.
          'is_screen_on': _isScreenOn() ? 1 : 0,
          if (levels['volume'] != null) 'volume': levels['volume'],
          if (levels['brightness'] != null) 'brightness': levels['brightness'],
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        final inner = data['data'] as Map<String, dynamic>;
        final commands = inner['commands'];
        if (commands is List && commands.isNotEmpty) {
          for (final cmd in commands) {
            if (cmd is Map<String, dynamic>) {
              final payload = cmd['payload'] is Map<String, dynamic>
                  ? cmd['payload'] as Map<String, dynamic>
                  : const <String, dynamic>{};
              _handleCommand(
                cmd['command'] as String?,
                payload,
                cmd['id'] as String?,
              );
            }
          }
        }
      }
    } catch (_) {
      // Silently ignore poll failures — next tick will retry.
    }
  }

  void _handleCommand(
    String? command,
    Map<String, dynamic> payload,
    String? commandId,
  ) {
    if (command == null) return;
    final navigator = _navigatorKey?.currentState;

    switch (command) {
      case 'screen_off':
        // SleepModeScreen.initState calls markScreenOff(); no need to flip
        // the flag here — avoids drift if navigation fails.
        navigator?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SleepModeScreen()),
          (_) => false,
        );
        break;

      case 'screen_on':
        // Likewise: SleepModeScreen.dispose flips the flag when it's popped.
        navigator?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DefaultPage()),
          (_) => false,
        );
        break;

      case 'volume':
        _applyVolume(payload);
        break;

      case 'brightness':
        _applyBrightness(payload);
        break;

      case 'clear_cache':
        _clearCaches();
        break;

      case 'reboot':
        _restartApp();
        break;

      case 'take_screenshot':
        if (commandId != null && commandId.isNotEmpty) {
          // Fire-and-forget — the BackOffice is polling for the result_url.
          ScreenshotService.captureAndUpload(commandId);
        }
        break;
    }
  }

  /// Queries native for the current volume/brightness (0.0–1.0) and returns
  /// them as `{'volume': int 0–100, 'brightness': int 0–100}`. Each key is
  /// omitted if the channel call fails, so one failure doesn't block the
  /// other — and the server keeps the last reported value.
  Future<Map<String, int?>> _readDeviceLevels() async {
    int? clamp(double v) => (v * 100).round().clamp(0, 100);

    int? volume;
    int? brightness;
    try {
      final v = await _deviceChannel.invokeMethod<num>('getVolume');
      if (v != null) volume = clamp(v.toDouble());
    } catch (_) {}
    try {
      final b = await _deviceChannel.invokeMethod<num>('getBrightness');
      if (b != null) brightness = clamp(b.toDouble());
    } catch (_) {}
    return {'volume': volume, 'brightness': brightness};
  }

  /// Converts BackOffice slider value (0–100, possibly a string) into the
  /// 0.0–1.0 double the native channel expects.
  double? _normalize0to1(dynamic raw) {
    if (raw == null) return null;
    double? v;
    if (raw is num) {
      v = raw.toDouble();
    } else if (raw is String) {
      v = double.tryParse(raw);
    }
    if (v == null) return null;
    return (v / 100.0).clamp(0.0, 1.0);
  }

  Future<void> _applyVolume(Map<String, dynamic> payload) async {
    final value = _normalize0to1(payload['value']);
    if (value == null) return;
    try {
      await _deviceChannel.invokeMethod('setVolume', value);
    } catch (_) {
      // Swallow: device may not support it, don't block polling.
    }
  }

  Future<void> _applyBrightness(Map<String, dynamic> payload) async {
    final value = _normalize0to1(payload['value']);
    if (value == null) return;
    try {
      await _deviceChannel.invokeMethod('setBrightness', value);
    } catch (_) {
      // Swallow.
    }
  }

  Future<void> _clearCaches() async {
    // In-memory decoded bitmaps used by any Image widget.
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // Disk cache used by CachedNetworkImage (also backs help-center /
    // bundle / banner media).
    try {
      await DefaultCacheManager().emptyCache();
    } catch (_) {
      // Ignore — best effort.
    }
  }

  Future<void> _restartApp() async {
    try {
      await _deviceChannel.invokeMethod('restartApp');
    } catch (_) {
      // If native restart isn't implemented yet, best-effort fallback:
      // force the UI back to a known state.
      _navigatorKey?.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SleepModeScreen()),
        (_) => false,
      );
    }
  }
}
