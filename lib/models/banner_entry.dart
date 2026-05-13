import 'package:MotionReach/config/api_config.dart';

class BannerEntry {
  final int id;
  final String titleTh;
  final String? bannerUrl;
  final String? logoUrl;
  final String? overlayUrl;
  final int displayOrder;

  const BannerEntry({
    required this.id,
    required this.titleTh,
    required this.bannerUrl,
    required this.logoUrl,
    required this.overlayUrl,
    required this.displayOrder,
  });

  factory BannerEntry.fromJson(Map<String, dynamic> json) {
    String? fix(dynamic v) {
      if (v is String && v.isNotEmpty) return ApiConfig.fixMediaUrl(v);
      return null;
    }

    return BannerEntry(
      id: (json['id'] ?? 0) as int,
      titleTh: (json['title_th'] ?? '') as String,
      bannerUrl: fix(json['banner_url']),
      logoUrl: fix(json['logo_url']),
      overlayUrl: fix(json['overlay_url']),
      displayOrder: (json['display_order'] ?? 0) as int,
    );
  }
}
