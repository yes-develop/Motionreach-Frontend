import 'dart:ui' show FontVariation;

import 'package:MotionReach/models/help_section.dart';
import 'package:MotionReach/providers/help_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'help1_overlay_widget.dart';
import 'help2_overlay_widget.dart';
import 'help3_overlay_widget.dart';
import 'help4_overlay_widget.dart';

class HelpOverlayWidget extends StatefulWidget {
  const HelpOverlayWidget({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<HelpOverlayWidget> createState() => _HelpOverlayWidgetState();
}

String? _stripHtml(String? html) {
  if (html == null || html.isEmpty) return null;
  final stripped = html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  return stripped.isEmpty ? null : stripped;
}

class _HelpOverlayWidgetState extends State<HelpOverlayWidget> {
  int _currentPage = 0;

  void _navigateToPage(int pageIndex) {
    setState(() {
      _currentPage = pageIndex;
    });
  }

  void _goBack() {
    setState(() {
      _currentPage = 0;
    });
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _buildMainHelpPage();
      case 1:
        return const Help1OverlayWidget();
      case 2:
        return const Help2OverlayWidget();
      case 3:
        return const Help3OverlayWidget();
      case 4:
        return const Help4OverlayWidget();
      default:
        return _buildMainHelpPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              255,
              177,
              255,
              255,
            ).withValues(alpha: 0.5),
            blurRadius: 13,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            _currentPage == 0 ? _sosBG() : _overlayBG(),
            _buildCurrentPage(),
            if (_currentPage != 0)
              Positioned(
                top: 20,
                left: 20,
                child: GestureDetector(
                  onTap: _goBack,
                  child: _iconBubble(Icons.arrow_back_ios_rounded),
                ),
              ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: widget.onClose,
                child: _iconBubble(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBubble(IconData icon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.2,
              colors: [
                const Color(0xFFB1FFFF).withOpacity(0.7),
                const Color(0xFFB1FFFF).withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(221, 77, 68, 68).withOpacity(1),
            border: Border.all(width: 1.5, color: Colors.transparent),
          ),
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB1FFFF), Colors.transparent],
              ).createShader(rect);
            },
          ),
        ),
        Icon(icon, color: Colors.white, size: 25),
      ],
    );
  }

  Widget _buildMainHelpPage() {
    // Listen to HelpProvider so the page rebuilds when the 30s poll brings
    // updated content. Show a loader during the very first fetch so users
    // don't see a flash of hardcoded fallback content before the API returns.
    return AnimatedBuilder(
      animation: HelpProvider.instance,
      builder: (context, _) {
        if (!HelpProvider.instance.hasLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        final box1 = HelpProvider.instance.byPlacement('box1');
        final box2 = HelpProvider.instance.byPlacement('box2');
        final box3 = HelpProvider.instance.byPlacement('box3');
        final box4 = HelpProvider.instance.byPlacement('box4');
        final header = HelpProvider.instance.byPlacement('header');
        final headerItem = header?.activeSet?.firstItem;

        // Convention in the BackOffice: HEADER's first item uses
        //   subtitle  = big title ("Help & Information")
        //   content   = tagline (HTML-stripped)
        //   website   = footer site
        //   phone     = footer contact
        final mainTitle = headerItem?.subtitle?.isNotEmpty == true
            ? headerItem!.subtitle!
            : 'Help & Information';
        final tagline = _stripHtml(headerItem?.content) ??
            'CONNECTING JOURNEYS, CONNECTING BRANDS';
        final website = headerItem?.website?.isNotEmpty == true
            ? headerItem!.website!
            : 'motinreach.com';
        final phone = headerItem?.phone?.isNotEmpty == true
            ? headerItem!.phone!
            : '02-XXX-XXXX';

        return SingleChildScrollView(
          child: Center(
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
                    mainTitle,
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
                      _HelpBoxTile(
                        section: box1,
                        fallbackTitle: 'Advertise with Us',
                        fallbackSubtitle: 'Grow your business with moving media',
                        fallbackAsset: 'assets/images/help1.jpg',
                        height: 180,
                        onTap: () => _navigateToPage(1),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _HelpBoxTile(
                              section: box2,
                              fallbackTitle: 'Who are we',
                              fallbackSubtitle: 'About Motion Reach Platform',
                              fallbackAsset: 'assets/images/help2.png',
                              height: 180,
                              onTap: () => _navigateToPage(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _HelpBoxTile(
                              section: box3,
                              fallbackTitle: 'Our \nTechnology',
                              fallbackSubtitle: 'Smart Geo-Targeting System',
                              fallbackAsset: 'assets/images/help3.png',
                              height: 180,
                              onTap: () => _navigateToPage(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _HelpBoxTile(
                              section: box4,
                              fallbackTitle: 'Terms\n& Privacy',
                              fallbackSubtitle: 'Our Conditions',
                              fallbackAsset: 'assets/images/help2.png',
                              height: 180,
                              onTap: () => _navigateToPage(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    tagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.call, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        phone,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sosBG() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/bg.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Image.asset(
          'assets/images/blendBG.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
              radius: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _overlayBG() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/bg.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Image.asset(
          'assets/images/blendBG.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 1),
              ],
              radius: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

/// Clickable help-center box on the main page. Uses API data when a [section]
/// is provided, and falls back to the hardcoded values if not.
class _HelpBoxTile extends StatelessWidget {
  const _HelpBoxTile({
    required this.section,
    required this.fallbackTitle,
    required this.fallbackSubtitle,
    required this.fallbackAsset,
    required this.height,
    required this.onTap,
  });

  final HelpSection? section;
  final String fallbackTitle;
  final String fallbackSubtitle;
  final String fallbackAsset;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Title/subtitle come from the active batch (set), not the section row.
    final batch = section?.activeSet;
    final title = (batch?.batchName?.isNotEmpty ?? false)
        ? batch!.batchName!
        : fallbackTitle;
    final subtitle = (batch?.batchSubtitle?.isNotEmpty ?? false)
        ? batch!.batchSubtitle!
        : fallbackSubtitle;
    // Preview image: batch bg image first, then section bg image, then asset.
    final bgUrl = batch?.batchBgImage ?? section?.sectionBgImage;

    final bgWidget = (bgUrl != null && bgUrl.isNotEmpty)
        ? CachedNetworkImage(
            imageUrl: bgUrl,
            fit: BoxFit.cover,
            // Transparent placeholder while the network image downloads, so we
            // don't flash the hardcoded asset. Asset only used on actual error.
            placeholder: (_, __) => const SizedBox.expand(),
            errorWidget: (_, __, ___) =>
                Image.asset(fallbackAsset, fit: BoxFit.cover),
            fadeInDuration: const Duration(milliseconds: 150),
          )
        : Image.asset(fallbackAsset, fit: BoxFit.cover);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              bgWidget,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: 'BoundedVariable',
                        fontVariations: [FontVariation('wght', 560)],
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
