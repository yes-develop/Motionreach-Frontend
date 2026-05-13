import 'dart:async';

import 'package:MotionReach/models/banner_entry.dart';
import 'package:MotionReach/providers/bundle_provider.dart';
import 'package:MotionReach/views/widgets/media/remote_video.dart';
import 'package:MotionReach/views/widgets/navbar/default_side_widget.dart';
import 'package:MotionReach/views/widgets/navbar/navbar_overlay_widget.dart';
import 'package:MotionReach/views/widgets/navbar/navbarbanner_widget.dart';
import 'package:MotionReach/views/widgets/settingsbar_widget.dart';
import 'package:flutter/material.dart';

class DefaultPage extends StatefulWidget {
  const DefaultPage({super.key});

  @override
  State<DefaultPage> createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  final GlobalKey<NavbarbannerWidgetState> _navbarKey = GlobalKey();
  bool _isSideOpen = false;
  bool _isBrandOverlayOpen = false;
  bool _isSosOverlayOpen = false;
  bool _isHelpOverlayOpen = false;
  bool _showSettingsBar = false;
  BannerEntry? _selectedBrand;
  Timer? _slideBackTimer;

  @override
  void dispose() {
    _slideBackTimer?.cancel();
    super.dispose();
  }

  void _openBrandOverlay(BannerEntry entry) {
    setState(() {
      _selectedBrand = entry;
      _isBrandOverlayOpen = true;
    });
  }

  void _closeBrandOverlay() {
    setState(() {
      _isBrandOverlayOpen = false;
      _selectedBrand = null;
    });

    /// reset navbar highlight
    _navbarKey.currentState?.clearSelection();
  }

  void _openSosOverlay() => setState(() => _isSosOverlayOpen = true);
  void _closeSosOverlay() => setState(() => _isSosOverlayOpen = false);
  void _toggleNavbar() => setState(() => _showSettingsBar = !_showSettingsBar);
  void _openHelpOverlay() => setState(() => _isHelpOverlayOpen = true);
  void _closeHelpOverlay() => setState(() => _isHelpOverlayOpen = false);

  void _startInactivityTimer() {
    _slideBackTimer?.cancel();
    _slideBackTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _isSideOpen) {
        setState(() => _isSideOpen = false);
      }
    });
  }

  void _toggleSide() {
    setState(() => _isSideOpen = !_isSideOpen);
    if (_isSideOpen) {
      _startInactivityTimer();
    } else {
      _slideBackTimer?.cancel();
    }
  }

  void _resetInactivityTimer() {
    _slideBackTimer?.cancel();
    _slideBackTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isSideOpen = false;
          // Brand overlay stays open until the user taps to close — do not
          // reuse this timer or it matches a ~10s "white flash then gone" UX.
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double sidePreviewWidth = 200;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: Row(
                    children: [
                      /// MAIN (bundle cycler)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: _isSideOpen
                            ? 0
                            : MediaQuery.of(context).size.width - sidePreviewWidth,
                        child: const _MainContent(),
                      ),

                      /// SIDE
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: _isSideOpen
                            ? MediaQuery.of(context).size.width
                            : sidePreviewWidth,
                        child: Material(
                          elevation: 8,
                          child: DefaultSideContentWidget(onTap: _toggleSide),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// NAVBAR
              _showSettingsBar
                  ? SettingsbarWidget(
                      onSosTap: _openSosOverlay,
                      onHelpTap: _openHelpOverlay,
                      onCloseTap: _toggleNavbar,
                    )
                  : NavbarbannerWidget(
                      key: _navbarKey,
                      onBrandTap: (entry) {
                        if (entry == null) {
                          _closeBrandOverlay();
                          _slideBackTimer?.cancel();
                        } else {
                          _openBrandOverlay(entry);
                          _resetInactivityTimer();
                        }
                      },
                      onSosTap: _openSosOverlay,
                      onMenuTap: _toggleNavbar,
                    ),
            ],
          ),

          // Brand overlay
          if (_isBrandOverlayOpen && _selectedBrand != null)
            GestureDetector(
              onPanUpdate: (_) => _resetInactivityTimer(),
              onTapDown: (_) => _resetInactivityTimer(),
              child: NavbarOverlayWidget(
                type: NavbarOverlayType.brand,
                brandEntry: _selectedBrand,
                onClose: _closeBrandOverlay,
              ),
            ),

          if (_isHelpOverlayOpen)
            NavbarOverlayWidget(
              type: NavbarOverlayType.settingsHelp,
              onClose: _closeHelpOverlay,
            ),

          if (_isSosOverlayOpen)
            NavbarOverlayWidget(
              type: NavbarOverlayType.sos,
              onClose: _closeSosOverlay,
            ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// MAIN CONTENT — plays the current bundle's video, advances when it ends.
////////////////////////////////////////////////////////////////////////////////

class _MainContent extends StatefulWidget {
  const _MainContent();

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> {
  @override
  void initState() {
    super.initState();
    BundleProvider.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    BundleProvider.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bundle = BundleProvider.instance.current;
    final url = bundle?.mainVideoUrl;

    if (url == null || url.isEmpty) {
      return const Center(
        child: Icon(Icons.video_library_outlined, size: 64, color: Colors.white24),
      );
    }

    return SizedBox.expand(
      child: NetworkVideoPlayer(
        // ValueKey forces a fresh player when the bundle (id) changes.
        key: ValueKey('bundle-${bundle!.id}'),
        url: url,
        looping: false,
        onEnded: () => BundleProvider.instance.advance(),
      ),
    );
  }
}
