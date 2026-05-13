class ApiConfig {
  // ───────────────────────────────────────────────────────────────────────────
  // BASE URL — uncomment the one matching where Laravel is running.
  // ───────────────────────────────────────────────────────────────────────────

  // Production (remote server):
  // static const String baseUrl = 'https://motion-reach-app.yesdemo.co';

  // Local Laravel on Android emulator (host machine reachable via 10.0.2.2):
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Local Laravel on iOS simulator / desktop / web:
  // static const String baseUrl = 'http://127.0.0.1:8000';

  // Local Laravel on a physical device (same Wi-Fi) — replace with your Mac's LAN IP:
  // static const String baseUrl = 'http://192.168.0.51:8000';

  static const String bundlesEndpoint = '/api/v1/bundles';
  static const String helpCenterEndpoint = '/api/v1/help-center';
  static const String bannerEntriesEndpoint = '/api/v1/banner-entries';
  static const String emergencyEndpoint = '/api/v1/emergency/rescue';
  static const String fleetDriverEndpoint = '/api/v1/fleet/driver';
  static const String pendingCommandsEndpoint = '/api/v1/remotes/pending-commands';
  static const String playbackEndpoint = '/api/v1/playback';
  static const String vehiclePlate = 'ฉฉ 3344';

  /// Rewrites absolute media URLs returned by the API so they are reachable
  /// from the device Flutter is running on. Handles both the production host
  /// and any local host Laravel might serve URLs as (port-agnostic).
  static String fixMediaUrl(String url) {
    // Production hostnames → baseUrl
    url = url
        .replaceAll('https://motion-reach-app.yesdemo.co', baseUrl)
        .replaceAll('http://motion-reach-app.yesdemo.co', baseUrl);

    // Local hosts with any port: http://127.0.0.1[:PORT] → baseUrl,
    // http://localhost[:PORT] → baseUrl. Matches optional port.
    url = url.replaceAllMapped(
      RegExp(r'https?://(127\.0\.0\.1|localhost)(:\d+)?'),
      (_) => baseUrl,
    );

    return url;
  }
}
