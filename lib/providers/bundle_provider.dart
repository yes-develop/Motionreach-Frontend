import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:MotionReach/config/api_config.dart';
import 'package:MotionReach/models/bundle.dart';

/// Manages the ordered list of ad bundles and tracks which one is currently
/// playing on the main area. Videos advance via [advance] when their playback
/// completes. Polls the server every 30s for updated bundle lists.
class BundleProvider extends ChangeNotifier {
  BundleProvider._internal();
  static final BundleProvider instance = BundleProvider._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );

  List<Bundle> _bundles = const [];
  List<Bundle> get bundles => _bundles;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Bundle? get current =>
      _bundles.isEmpty ? null : _bundles[_currentIndex.clamp(0, _bundles.length - 1)];

  Timer? _pollTimer;
  bool _started = false;

  // Playback-event tracking. Stamps the moment the current bundle became
  // visible; when it rotates off (via advance() or a refresh() that removes
  // the bundle) we fire a POST to /api/v1/playback so the BackOffice can
  // build Advertising Performance reports.
  DateTime? _currentStartedAt;
  int? _currentReportedBannerId;

  void start() {
    if (_started) return;
    _started = true;
    refresh();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
    _markCurrentPlayStart();
  }

  void stop() {
    // Flush whatever is currently playing before we go away.
    _flushCurrentPlay();
    _pollTimer?.cancel();
    _pollTimer = null;
    _started = false;
  }

  Future<void> refresh() async {
    try {
      final response = await _dio.get(
        ApiConfig.bundlesEndpoint,
        // Required for per-screen targeting. Backend falls back to global
        // delivery when the plate is omitted, so older builds still work.
        queryParameters: {'vehicle_plate': ApiConfig.vehiclePlate},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final newBundles = (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Bundle.fromJson)
            .toList();
        // Only notify if list changed to avoid unnecessary rebuilds.
        final changed = _bundlesChanged(_bundles, newBundles);
        final previousCurrentId = current?.id;
        _bundles = newBundles;
        if (_currentIndex >= _bundles.length) _currentIndex = 0;
        // If the currently-playing bundle is no longer in the list (got
        // removed / targeting changed), flush its play event and restamp.
        if (previousCurrentId != null && current?.id != previousCurrentId) {
          _flushCurrentPlay();
          _markCurrentPlayStart();
        }
        if (changed) notifyListeners();
      }
    } catch (_) {
      // Silent: keep showing whatever we had.
    }
  }

  /// Advance to the next bundle. Called by the video player when a clip ends.
  void advance() {
    if (_bundles.isEmpty) return;
    _flushCurrentPlay();
    _currentIndex = (_currentIndex + 1) % _bundles.length;
    _markCurrentPlayStart();
    notifyListeners();
  }

  // ─── Playback event reporting ────────────────────────────────────────
  void _markCurrentPlayStart() {
    final c = current;
    if (c == null) {
      _currentStartedAt = null;
      _currentReportedBannerId = null;
      return;
    }
    _currentStartedAt = DateTime.now().toUtc();
    _currentReportedBannerId = c.id;
  }

  /// POST the just-ended play to the BackOffice. Fire-and-forget — failures
  /// are swallowed so reporting hiccups never block video playback.
  void _flushCurrentPlay() {
    final startedAt = _currentStartedAt;
    final bannerId = _currentReportedBannerId;
    _currentStartedAt = null;
    _currentReportedBannerId = null;

    if (startedAt == null || bannerId == null) return;
    final endedAt = DateTime.now().toUtc();
    // Reject suspiciously short plays (<2s) — almost always means the tablet
    // rotated through the list before the first video even decoded. Including
    // them would poison the "avg watch time" metric.
    if (endedAt.difference(startedAt).inSeconds < 2) return;

    // Intentionally no await — fire-and-forget.
    _dio.post(ApiConfig.playbackEndpoint, data: {
      'vehicle_plate': ApiConfig.vehiclePlate,
      'banner_id':     bannerId,
      'started_at':    startedAt.toIso8601String(),
      'ended_at':      endedAt.toIso8601String(),
    }).catchError((_) {
      // Reporting is best-effort. Next plays will still log.
      return null;
    });
  }

  bool _bundlesChanged(List<Bundle> a, List<Bundle> b) {
    if (a.length != b.length) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].mainVideoUrl != b[i].mainVideoUrl ||
          a[i].sideImageUrl != b[i].sideImageUrl) {
        return true;
      }
    }
    return false;
  }
}
