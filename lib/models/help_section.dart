import 'package:MotionReach/config/api_config.dart';

/// One card/item inside a help section's active batch.
class HelpItem {
  final int id;
  final String? subtitle;
  final String? content; // may be HTML (from Quill editor)
  final String? icon;
  final String? bgImage;
  final String? phone;
  final String? website;
  final String? placement;

  const HelpItem({
    required this.id,
    this.subtitle,
    this.content,
    this.icon,
    this.bgImage,
    this.phone,
    this.website,
    this.placement,
  });

  factory HelpItem.fromJson(Map<String, dynamic> json) {
    String? fix(dynamic v) {
      if (v is String && v.isNotEmpty) return ApiConfig.fixMediaUrl(v);
      return null;
    }

    String? str(dynamic v) {
      if (v is String && v.isNotEmpty) return v;
      return null;
    }

    return HelpItem(
      id: (json['id'] ?? 0) as int,
      subtitle: str(json['subtitle']),
      content: str(json['content']),
      icon: fix(json['icon']),
      bgImage: fix(json['bg_image']),
      phone: str(json['phone']),
      website: str(json['website']),
      placement: str(json['placement']),
    );
  }
}

/// The "active" batch inside a help section — a group of items shown together.
class HelpBatch {
  final String? batchId;
  final String? batchName;
  final String? batchSubtitle;
  final String? batchBgImage;
  final List<HelpItem> items;

  const HelpBatch({
    this.batchId,
    this.batchName,
    this.batchSubtitle,
    this.batchBgImage,
    this.items = const [],
  });

  HelpItem? get firstItem => items.isEmpty ? null : items.first;

  factory HelpBatch.fromJson(Map<String, dynamic> json) {
    String? fix(dynamic v) {
      if (v is String && v.isNotEmpty) return ApiConfig.fixMediaUrl(v);
      return null;
    }

    final rawItems = json['items'];
    return HelpBatch(
      batchId: json['batch_id'] as String?,
      batchName: json['batch_name'] as String?,
      batchSubtitle: json['batch_subtitle'] as String?,
      batchBgImage: fix(json['batch_bg_image']),
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(HelpItem.fromJson)
              .toList()
          : const [],
    );
  }
}

/// A single section row from the BackOffice `/help-center` page.
/// `placement` is one of: `header`, `box1`, `box2`, `box3`, `box4`.
class HelpSection {
  final int id;
  final String? title;
  final String? subtitle;
  final String? placement;
  final String? sectionBgImage;
  final HelpBatch? activeSet;

  const HelpSection({
    required this.id,
    this.title,
    this.subtitle,
    this.placement,
    this.sectionBgImage,
    this.activeSet,
  });

  factory HelpSection.fromJson(Map<String, dynamic> json) {
    String? fix(dynamic v) {
      if (v is String && v.isNotEmpty) return ApiConfig.fixMediaUrl(v);
      return null;
    }

    return HelpSection(
      id: (json['id'] ?? 0) as int,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      placement: json['placement'] as String?,
      sectionBgImage: fix(json['section_bg_image']),
      activeSet: json['active_set'] is Map<String, dynamic>
          ? HelpBatch.fromJson(json['active_set'] as Map<String, dynamic>)
          : null,
    );
  }
}
