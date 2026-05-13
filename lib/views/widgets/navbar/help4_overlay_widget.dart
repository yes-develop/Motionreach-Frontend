import 'package:MotionReach/providers/help_provider.dart';
import 'package:MotionReach/utils/lorem_ipsum.dart';
import 'package:flutter/material.dart';

/// Layout 4 / box4 — "Terms & Privacy". Text-only legal content pulled from
/// the active batch's first item, with Lorem Ipsum fallback.
class Help4OverlayWidget extends StatelessWidget {
  const Help4OverlayWidget({super.key});

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
        final section = HelpProvider.instance.byPlacement('box4');
        final batch = section?.activeSet;
        final firstItem = batch?.firstItem;
        final header = HelpProvider.instance.byPlacement('header');
        final headerItem = header?.activeSet?.firstItem;

        final title = batch?.batchName?.isNotEmpty == true
            ? batch!.batchName!
            : 'Terms & Privacy';
        // The "Card Header / Title" field on the batch item.
        final cardHeader = firstItem?.subtitle?.isNotEmpty == true
            ? firstItem!.subtitle
            : null;
        final content = _stripHtml(firstItem?.content);
        final website = headerItem?.website?.isNotEmpty == true
            ? headerItem!.website!
            : 'motinreach.com';
        final phone = headerItem?.phone?.isNotEmpty == true
            ? headerItem!.phone!
            : '02-XXX-XXXX';

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                if (cardHeader != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 90.0),
                    child: Text(
                      cardHeader,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 90.0),
                  child: content != null
                      ? Text(
                          content,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        )
                      : Column(
                          children: [
                            Text(
                              LoremIpsum.generateWords(50),
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            const _LoremSub(title: '1.'),
                            const _LoremSub(title: '2.'),
                            const _LoremSub(title: '3.'),
                            const _LoremSub(title: '4.'),
                            const _LoremSub(title: '5.'),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
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

class _LoremSub extends StatelessWidget {
  final String title;

  const _LoremSub({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            LoremIpsum.generateWords(50),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
