import 'package:MotionReach/providers/help_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Layout 2 / box2 — "Who are we". Hero image + description pulled from the
/// active batch's first item, with hardcoded fallback.
class Help2OverlayWidget extends StatelessWidget {
  const Help2OverlayWidget({super.key});

  static const _fallbackDescription =
      'We are a new-generation media company redefining Out-of-Home advertising through data, design, and mobility. By transforming taxis into smart, connected media platforms, we help brands reach audiences in motion creating positive, memorable and measurable experiences on every journey.';

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
        final section = HelpProvider.instance.byPlacement('box2');
        final batch = section?.activeSet;
        final firstItem = batch?.firstItem;
        final header = HelpProvider.instance.byPlacement('header');
        final headerItem = header?.activeSet?.firstItem;

        final title = batch?.batchName?.isNotEmpty == true
            ? batch!.batchName!
            : 'Who are we';
        final tagline = batch?.batchSubtitle?.isNotEmpty == true
            ? batch!.batchSubtitle!
            : 'CONNECTING JOURNEYS, CONNECTING BRANDS';
        final description =
            _stripHtml(firstItem?.content) ?? _fallbackDescription;
        final heroUrl = firstItem?.bgImage ?? section?.sectionBgImage;
        final website = headerItem?.website?.isNotEmpty == true
            ? headerItem!.website!
            : 'motinreach.com';
        final phone = headerItem?.phone?.isNotEmpty == true
            ? headerItem!.phone!
            : '02-XXX-XXXX';

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
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
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _heroCard(heroUrl),
                      const SizedBox(height: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tagline,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _heroCard(String? url) {
    final img = (url != null && url.isNotEmpty)
        ? CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => const SizedBox.expand(),
            errorWidget: (_, __, ___) =>
                Image.asset('assets/images/help1.jpg', fit: BoxFit.cover),
            fadeInDuration: const Duration(milliseconds: 150),
          )
        : Image.asset('assets/images/help1.jpg', fit: BoxFit.cover);

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            img,
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  stops: [0.45, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _stripHtml(String? html) {
    if (html == null || html.isEmpty) return null;
    final stripped = html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return stripped.isEmpty ? null : stripped;
  }
}
