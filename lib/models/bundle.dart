import 'package:MotionReach/config/api_config.dart';

class Bundle {
  final int id;
  final String titleTh;
  final String? mainVideoUrl;
  final String? sideImageUrl;
  final int displayOrder;

  const Bundle({
    required this.id,
    required this.titleTh,
    required this.mainVideoUrl,
    required this.sideImageUrl,
    required this.displayOrder,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    String? fix(dynamic v) {
      if (v is String && v.isNotEmpty) return ApiConfig.fixMediaUrl(v);
      return null;
    }

    return Bundle(
      id: (json['id'] ?? 0) as int,
      titleTh: (json['title_th'] ?? '') as String,
      mainVideoUrl: fix(json['main_video_url']),
      sideImageUrl: fix(json['side_image_url']),
      displayOrder: (json['display_order'] ?? 0) as int,
    );
  }
}
