import 'package:MotionReach/models/help_section.dart';
import 'package:MotionReach/providers/help_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Layout 1 / box1 — "Advertise with us". 4-stat grid pulled from the active
/// batch of the box1 section, with hardcoded fallback when API data is absent.
class Help1OverlayWidget extends StatelessWidget {
  const Help1OverlayWidget({super.key});

  static const _fallbackStats = <_StatData>[
    _StatData(title: '6 Average', subtitle: 'Ad frequency', asset: 'assets/images/stack1.png'),
    _StatData(title: '98%', subtitle: 'Of BKK area covered', asset: 'assets/images/stack2.jpg'),
    _StatData(title: '18 Minutes', subtitle: 'Engagement time per trip', asset: 'assets/images/stack3.png'),
    _StatData(title: '1,000', subtitle: 'Digital Screens', asset: 'assets/images/help2.png'),
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
        final section = HelpProvider.instance.byPlacement('box1');
        final items = section?.activeSet?.items ?? const <HelpItem>[];
        final header = HelpProvider.instance.byPlacement('header');
        final headerItem = header?.activeSet?.firstItem;

        // Convention: items[0] = hero (title + description + image),
        //             items[1..4] = the 4 stat cards.
        final heroItem = items.isNotEmpty ? items.first : null;
        final statItems =
            items.length > 1 ? items.sublist(1) : const <HelpItem>[];

        // Compose exactly 4 stat cards, falling back per-slot.
        final stats = List<_StatData>.generate(4, (i) {
          if (i < statItems.length) {
            final item = statItems[i];
            return _StatData(
              title: item.subtitle ?? _fallbackStats[i].title,
              subtitle: _stripHtml(item.content) ?? _fallbackStats[i].subtitle,
              asset: _fallbackStats[i].asset,
              url: item.bgImage,
            );
          }
          return _fallbackStats[i];
        });

        final batch = section?.activeSet;
        final heroTitle = batch?.batchName?.isNotEmpty == true
            ? batch!.batchName!
            : 'Advertise with us';
        final heroTagline = heroItem?.subtitle?.isNotEmpty == true
            ? heroItem!.subtitle!
            : 'CONNECTING JOURNEYS, CONNECTING BRANDS';
        final heroSubtitle = _stripHtml(heroItem?.content) ??
            (batch?.batchSubtitle?.isNotEmpty == true
                ? batch!.batchSubtitle!
                : 'Our city-wide mobility network drives measurable brand impact reaching millions of journeys every month through smart, connected media.');
        final heroImageUrl = heroItem?.bgImage ?? section?.sectionBgImage;
        final website = headerItem?.website?.isNotEmpty == true
            ? headerItem!.website!
            : 'motionreach.com';
        final phone = headerItem?.phone?.isNotEmpty == true
            ? headerItem!.phone!
            : '02-XXX-XXXX';

        return Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF87549A), Color(0xFF8FD4F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  heroTitle,
                  style: const TextStyle(
                    fontSize: 45,
                    fontFamily: 'BoundedVariable',
                    fontVariations: [FontVariation('wght', 560)],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 40, left: 40, right: 40),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            Expanded(
                              child: _ImageCard(
                                url: heroImageUrl,
                                fallbackAsset: 'assets/images/help1.jpg',
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    heroTagline,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: 'BoundedVariable',
                                      fontVariations: [
                                        FontVariation('wght', 560)
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    heroSubtitle,
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _StatCard(data: stats[0]),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _StatCard(data: stats[1]),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _StatCard(data: stats[2]),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _StatCard(data: stats[3]),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.public_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  website,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 20),
                                const Icon(Icons.call, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  phone,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
    // Simple tag strip. Good enough for Quill's <p>/<strong> output.
    final stripped = html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return stripped.isEmpty ? null : stripped;
  }
}

class _StatData {
  final String title;
  final String subtitle;
  final String asset;
  final String? url;
  const _StatData({
    required this.title,
    required this.subtitle,
    required this.asset,
    this.url,
  });
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.url, required this.fallbackAsset});

  final String? url;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    final img = (url != null && url!.isNotEmpty)
        ? CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.cover,
            placeholder: (_, __) => const SizedBox.expand(),
            errorWidget: (_, __, ___) =>
                Image.asset(fallbackAsset, fit: BoxFit.cover),
            fadeInDuration: const Duration(milliseconds: 150),
          )
        : Image.asset(fallbackAsset, fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          img,
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(221, 80, 214, 255).withValues(alpha: 0.3),
                  const Color.fromARGB(255, 255, 255, 255)
                      .withValues(alpha: 0.3),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final img = (data.url != null && data.url!.isNotEmpty)
        ? CachedNetworkImage(
            imageUrl: data.url!,
            fit: BoxFit.cover,
            placeholder: (_, __) => const SizedBox.expand(),
            errorWidget: (_, __, ___) =>
                Image.asset(data.asset, fit: BoxFit.cover),
            fadeInDuration: const Duration(milliseconds: 150),
          )
        : Image.asset(data.asset, fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(opacity: 0.9, child: img),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(221, 146, 201, 204)
                      .withValues(alpha: 0.7),
                  const Color.fromARGB(255, 105, 41, 201).withValues(alpha: 0.4),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.3)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontFamily: 'BoundedVariable',
                    fontVariations: [FontVariation('wght', 560)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
