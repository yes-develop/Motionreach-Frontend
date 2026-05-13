import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:MotionReach/config/api_config.dart';
import 'package:MotionReach/models/banner_entry.dart';

/// Manages the ordered list of banner entries displayed in the navbar.
/// The navbar shows 4 slots at a time; if more entries exist, it cycles through
/// in groups of 4 every [_rotateInterval].
class BannerEntryProvider extends ChangeNotifier {
  BannerEntryProvider._internal();
  static final BannerEntryProvider instance = BannerEntryProvider._internal();

  static const int slotCount = 4;
  static const Duration _refreshInterval = Duration(seconds: 30);
  static const Duration _rotateInterval = Duration(seconds: 30);

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: {'Accept': 'application/json'},
    ),
  );

  List<BannerEntry> _entries = const [];
  List<BannerEntry> get entries => _entries;

  int _viewportStart = 0;
  int get viewportStart => _viewportStart;

  /// Returns exactly [slotCount] entries for the navbar, wrapping around.
  /// When the list has fewer than [slotCount] items, the remaining slots are
  /// filled by wrapping from the start; if empty, returns an empty list.
  List<BannerEntry?> get visibleSlots {
    if (_entries.isEmpty) return List<BannerEntry?>.filled(slotCount, null);
    final slots = <BannerEntry?>[];
    for (int i = 0; i < slotCount; i++) {
      slots.add(_entries[(_viewportStart + i) % _entries.length]);
    }
    return slots;
  }

  Timer? _pollTimer;
  Timer? _rotateTimer;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    refresh();
    _pollTimer = Timer.periodic(_refreshInterval, (_) => refresh());
    _rotateTimer = Timer.periodic(_rotateInterval, (_) => _rotate());
  }

  void stop() {
    _pollTimer?.cancel();
    _rotateTimer?.cancel();
    _pollTimer = null;
    _rotateTimer = null;
    _started = false;
  }

  Future<void> refresh() async {
    try {
      final response = await _dio.get(
        ApiConfig.bannerEntriesEndpoint,
        queryParameters: {'vehicle_plate': ApiConfig.vehiclePlate},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final newEntries = (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(BannerEntry.fromJson)
            .toList();
        final changed = _entriesChanged(_entries, newEntries);
        _entries = newEntries;
        if (_entries.isEmpty || _viewportStart >= _entries.length) {
          _viewportStart = 0;
        }
        if (changed) notifyListeners();
      }
    } catch (_) {
      // Silent: keep current state.
    }
  }

  void _rotate() {
    if (_entries.length <= slotCount) return;
    _viewportStart = (_viewportStart + slotCount) % _entries.length;
    notifyListeners();
  }

  bool _entriesChanged(List<BannerEntry> a, List<BannerEntry> b) {
    if (a.length != b.length) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].bannerUrl != b[i].bannerUrl ||
          a[i].logoUrl != b[i].logoUrl ||
          a[i].overlayUrl != b[i].overlayUrl) {
        return true;
      }
    }
    return false;
  }
}
