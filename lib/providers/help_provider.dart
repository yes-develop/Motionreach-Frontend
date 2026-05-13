import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:MotionReach/config/api_config.dart';
import 'package:MotionReach/models/help_section.dart';

/// Fetches and caches help-center content from the BackOffice.
/// Singleton ChangeNotifier — widgets listen with AnimatedBuilder and rebuild
/// when the 30-second poll brings updated data.
class HelpProvider extends ChangeNotifier {
  HelpProvider._internal();
  static final HelpProvider instance = HelpProvider._internal();

  static const Duration _pollInterval = Duration(seconds: 30);

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );

  List<HelpSection> _sections = const [];
  List<HelpSection> get sections => _sections;

  /// True once the first fetch has completed (successfully or not). Used by
  /// widgets to show a loader on cold start instead of flashing the
  /// hardcoded fallbacks before the API response arrives.
  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  Timer? _pollTimer;
  bool _started = false;

  /// Returns the section matching a placement like `box1`, `header`, etc.
  /// Returns null if no section has that placement.
  HelpSection? byPlacement(String placement) {
    for (final s in _sections) {
      if (s.placement == placement) return s;
    }
    return null;
  }

  void start() {
    if (_started) return;
    _started = true;
    refresh();
    _pollTimer = Timer.periodic(_pollInterval, (_) => refresh());
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _started = false;
  }

  Future<void> refresh() async {
    var changed = false;
    try {
      final response = await _dio.get(ApiConfig.helpCenterEndpoint);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final newSections = (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(HelpSection.fromJson)
            .toList();
        changed = _sectionsChanged(_sections, newSections);
        _sections = newSections;
      }
    } catch (_) {
      // Silent failure — widgets fall back to hardcoded content.
    } finally {
      // Always mark "loaded" after the first attempt so the UI can transition
      // out of the loading state, even if the API was unreachable.
      if (!_hasLoaded) {
        _hasLoaded = true;
        changed = true;
      }
      if (changed) notifyListeners();
    }
  }

  bool _sectionsChanged(List<HelpSection> a, List<HelpSection> b) {
    if (a.length != b.length) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].title != b[i].title ||
          a[i].subtitle != b[i].subtitle ||
          a[i].sectionBgImage != b[i].sectionBgImage ||
          (a[i].activeSet?.items.length ?? -1) !=
              (b[i].activeSet?.items.length ?? -1)) {
        return true;
      }
    }
    return false;
  }
}
