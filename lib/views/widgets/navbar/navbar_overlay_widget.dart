import 'package:MotionReach/models/banner_entry.dart';
import 'package:MotionReach/models/driver_info.dart';
import 'package:MotionReach/providers/emergency_provider.dart';
import 'package:MotionReach/views/widgets/navbar/sos_sending_overlay_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'help_overlay_widget.dart';

enum NavbarOverlayType { brand, sos, settingsHelp }

class NavbarOverlayWidget extends StatefulWidget {
  const NavbarOverlayWidget({
    super.key,
    required this.type,
    this.brandEntry,
    required this.onClose,
  });

  final NavbarOverlayType type;
  final BannerEntry? brandEntry;
  final VoidCallback onClose;

  @override
  State<NavbarOverlayWidget> createState() => _NavbarOverlayWidgetState();
}

class _NavbarOverlayWidgetState extends State<NavbarOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  final TextEditingController _phoneController = TextEditingController();

  bool _canSend = false;
  bool _showSending = false;
  DriverInfo? _driverInfo;
  String _passengerPhone = '';
  bool get _isBrand => widget.type == NavbarOverlayType.brand;

  /////////////////////////////////////////////////////////////////////////////
  /// INIT (ALWAYS initialize controller → fixes crash)
  /////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /////////////////////////////////////////////////////////////////////////////
  /// BUILD
  /////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    // Avoid [Positioned] when parent is [GestureDetector] (brand overlay path);
    // [Positioned] must be a direct child of [Stack].
    return SizedBox.expand(
      child: _isBrand ? _buildBrandLayout() : _buildModalLayout(),
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  /// LAYOUTS
  /////////////////////////////////////////////////////////////////////////////

  /// ⭐ SOS + HELP → dark background + centered popup
  Widget _buildModalLayout() {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // prevent close when tapping content
            child: _buildOverlayContent(),
          ),
        ),
      ),
    );
  }

  /// ⭐ BRAND → full width + leaves navbar visible + NO background
  Widget _buildBrandLayout() {
    return Align(
      alignment: Alignment.topCenter,
      child: SlideTransition(position: _slide, child: _buildOverlayContent()),
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  /// CONTENT SWITCHER
  /////////////////////////////////////////////////////////////////////////////

  Widget _buildOverlayContent() {
    if (_showSending) {
      return SosSendingOverlayWidget(
        onClose: widget.onClose,
        driverInfo: _driverInfo,
        passengerPhone: _passengerPhone,
      );
    }

    switch (widget.type) {
      case NavbarOverlayType.brand:
        return _buildBrandOverlay();

      case NavbarOverlayType.sos:
        return _buildSosOverlay();

      case NavbarOverlayType.settingsHelp:
        return HelpOverlayWidget(onClose: widget.onClose);
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  /// BRAND OVERLAY
  /// full width
  /// height leaves navbar visible
  /// no background dim
  /////////////////////////////////////////////////////////////////////////////

  Widget _buildBrandOverlay() {
    final entry = widget.brandEntry;
    if (entry == null) return const SizedBox();
    final screen = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: widget.onClose,
      child: SizedBox(
        width: double.infinity,
        height: screen.height * 0.902, // leave navbar visible
        child: ClipRRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFF12141C)),
              Positioned.fill(child: _BrandHeroImage(entry: entry)),
            ],
          ),
        ),
      ),
    );
  }

  /////////////////////////////////////////////////////////////////////////////
  /// SOS OVERLAY (simple demo – replace with your full design)
  /////////////////////////////////////////////////////////////////////////////
  Widget _buildSosOverlay() {
    final screen = MediaQuery.of(context).size;

    return Container(
      width: screen.width * 0.55,
      height: screen.height * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 177, 255, 255).withOpacity(0.5),
            blurRadius: 13,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            //////////////////////////////////////////////////////////////////////////
            /// background
            //////////////////////////////////////////////////////////////////////////
            _sosBG(),

            //////////////////////////////////////////////////////////////////////////
            /// main content
            //////////////////////////////////////////////////////////////////////////
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// icon
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// gradient title
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 135, 84, 154),
                          Color.fromARGB(255, 143, 212, 243),
                        ],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Verify SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Enter phone number to send alert message.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  //////////////////////////////////////////////////////////////////////////
                  /// phone field
                  //////////////////////////////////////////////////////////////////////////
                  SizedBox(
                    width: 425,
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white, fontSize: 20),

                      onChanged: (value) {
                        setState(() {
                          _canSend = value.trim().isNotEmpty;
                        });
                      },

                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        hintText: 'Phone Number',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Tap Cancel if accidental.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  //////////////////////////////////////////////////////////////////////////
                  /// buttons row
                  //////////////////////////////////////////////////////////////////////////
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// SEND
                      SizedBox(
                        width: 295,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _canSend
                              ? () async {
                                  final phone = _phoneController.text.trim();
                                  final driver = await EmergencyProvider
                                      .instance
                                      .fetchDriver();
                                  if (!mounted) return;
                                  final success = await EmergencyProvider
                                      .instance
                                      .sendSos(phone: phone);
                                  if (!mounted) return;
                                  if (success) {
                                    setState(() {
                                      _driverInfo = driver;
                                      _passengerPhone = phone;
                                      _showSending = true;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to send SOS. Please try again.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              : null, // disabled if empty

                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canSend
                                ? Colors.deepPurple
                                : Colors.grey[700],
                            disabledBackgroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            elevation: _canSend ? 6 : 0,
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 20,
                                color: _canSend
                                    ? Colors.white
                                    : const Color(0xFFB3B3B3),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Send Now',
                                style: TextStyle(
                                  color: _canSend
                                      ? Colors.white
                                      : const Color(0xFFB3B3B3),
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// CANCEL
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: Stack(
                          children: [
                            /// ⭐ Gradient glowing border
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFF87549A),
                                    Color(0xFF8FD4F3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            /// ⭐ Real button (NOT masked)
                            Positioned.fill(
                              child: ElevatedButton(
                                onPressed: widget.onClose,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //////////////////////////////////////////////////////////////////////////
            /// close button top-right
            //////////////////////////////////////////////////////////////////////////
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ⭐ OUTER DIRECTIONAL GLOW
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
                    // BUTTON WITH GRADIENT BORDER
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(
                          221,
                          77,
                          68,
                          68,
                        ).withOpacity(1),
                        border: Border.all(
                          width: 1.5,
                          color: Colors.transparent,
                        ),
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
                    const Icon(Icons.close, color: Colors.white, size: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  /// background layers
  ////////////////////////////////////////////////////////////////////////////

  Widget _sosBG() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Image.asset('assets/images/blendBG.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                radius: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Prefers overlay art, falls back to navbar banner URL; survives broken overlay URLs.
class _BrandHeroImage extends StatefulWidget {
  const _BrandHeroImage({required this.entry});

  final BannerEntry entry;

  @override
  State<_BrandHeroImage> createState() => _BrandHeroImageState();
}

class _BrandHeroImageState extends State<_BrandHeroImage> {
  late String? _url;
  bool _overlayPreferred = false;

  @override
  void initState() {
    super.initState();
    _applyEntry(widget.entry);
  }

  @override
  void didUpdateWidget(_BrandHeroImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id ||
        oldWidget.entry.overlayUrl != widget.entry.overlayUrl ||
        oldWidget.entry.bannerUrl != widget.entry.bannerUrl) {
      _applyEntry(widget.entry);
    }
  }

  void _applyEntry(BannerEntry e) {
    final overlay = e.overlayUrl;
    final banner = e.bannerUrl;
    if (overlay != null && overlay.isNotEmpty) {
      _url = overlay;
      _overlayPreferred = true;
    } else if (banner != null && banner.isNotEmpty) {
      _url = banner;
      _overlayPreferred = false;
    } else {
      _url = null;
      _overlayPreferred = false;
    }
  }

  static const Widget _loading = ColoredBox(
    color: Color(0xFF12141C),
    child: Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white38,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final url = _url;
    if (url == null || url.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 56),
      );
    }

    return CachedNetworkImage(
      key: ValueKey<String>(url),
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, _) => _loading,
      errorWidget: (context, imageUrl, _) {
        final banner = widget.entry.bannerUrl;
        if (_overlayPreferred &&
            banner != null &&
            banner.isNotEmpty &&
            banner != url) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _url = banner;
              _overlayPreferred = false;
            });
          });
          return _loading;
        }
        return const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white30, size: 56),
        );
      },
    );
  }
}
