import 'package:MotionReach/models/help_section.dart';
import 'package:MotionReach/providers/help_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Layout 3 / box3 — "Our technology". 3 feature cards with icons pulled from
/// the active batch's items, with hardcoded fallback.
class Help3OverlayWidget extends StatelessWidget {
  const Help3OverlayWidget({super.key});

  static const _fallbackFeatures = <_FeatureData>[
    _FeatureData(
      title: 'ACCURATE REPORTING',
      subtitle:
          'Transparent Performance Real-time tracking and post-campaign reports ensure measurable, accountable results.',
      iconAsset: 'assets/images/reportIcon.png',
    ),
    _FeatureData(
      title: 'ROUTE SELECTION',
      subtitle:
          'Targeted Reach Select fleet routes and zones to connect with the right audience at the right place.',
      iconAsset: 'assets/images/routeIcon.png',
    ),
    _FeatureData(
      title: 'DYNAMIC CREATIVE ADJUSTMENT',
      subtitle:
          'Real-Time Control Instantly update ads via the cloud to match moments, events, and audience behavior.',
      iconAsset: 'assets/images/calendarIcon.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: HelpProvider.instance,
      builder: (context, _) {
        if (!HelpProvider.instance.hasLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        final section = HelpProvider.instance.byPlacement('box3');
        final items = section?.activeSet?.items ?? const <HelpItem>[];
        final header = HelpProvider.instance.byPlacement('header');
        final headerItem = header?.activeSet?.firstItem;

        // Build 3 feature cards, falling back per-slot.
        final features = List<_FeatureData>.generate(3, (i) {
          if (i < items.length) {
            final item = items[i];
            return _FeatureData(
              title: item.subtitle ?? _fallbackFeatures[i].title,
              subtitle:
                  _stripHtml(item.content) ?? _fallbackFeatures[i].subtitle,
              iconAsset: _fallbackFeatures[i].iconAsset,
              iconUrl: item.icon,
            );
          }
          return _fallbackFeatures[i];
        });

        final batch = section?.activeSet;
        final title = batch?.batchName?.isNotEmpty == true
            ? batch!.batchName!
            : 'Our technology';
        final website = headerItem?.website?.isNotEmpty == true
            ? headerItem!.website!
            : 'motinreach.com';
        final phone = headerItem?.phone?.isNotEmpty == true
            ? headerItem!.phone!
            : '02-XXX-XXXX';

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 135, 84, 154),
                      Color.fromARGB(255, 143, 212, 243),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontFamily: 'BoundedVariable',
                    fontVariations: [FontVariation('wght', 560)],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 350,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: _FeatureCard(data: features[i]),
                              ),
                            ),
                          ),
                          if (i < 2) const SizedBox(width: 10),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public_rounded, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      website,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.call, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      phone,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String? _stripHtml(String? html) {
    if (html == null || html.isEmpty) return null;
    final stripped = html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return stripped.isEmpty ? null : stripped;
  }
}

class _FeatureData {
  final String title;
  final String subtitle;
  final String iconAsset;
  final String? iconUrl;
  const _FeatureData({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    this.iconUrl,
  });
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data});

  final _FeatureData data;

  @override
  Widget build(BuildContext context) {
    final icon = (data.iconUrl != null && data.iconUrl!.isNotEmpty)
        ? CachedNetworkImage(
            imageUrl: data.iconUrl!,
            width: 75,
            height: 75,
            fit: BoxFit.contain,
            placeholder: (_, __) => const SizedBox(width: 75, height: 75),
            errorWidget: (_, __, ___) =>
                Image.asset(data.iconAsset, width: 75, height: 75),
            fadeInDuration: const Duration(milliseconds: 150),
          )
        : Image.asset(data.iconAsset, width: 75, height: 75);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black.withValues(alpha: 1)),
        Image.asset(
          'assets/images/blendBG.png',
          fit: BoxFit.fill,
          width: double.infinity,
          height: double.infinity,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(221, 146, 201, 204).withValues(alpha: 0.7),
                const Color.fromARGB(255, 105, 41, 201).withValues(alpha: 0.5),
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        Positioned(top: 22, left: 22, child: icon),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 50),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontFamily: 'BoundedVariable',
                      fontVariations: [FontVariation('wght', 560)],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.subtitle,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
