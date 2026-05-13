import 'package:MotionReach/models/banner_entry.dart';
import 'package:MotionReach/providers/banner_entry_provider.dart';
import 'package:MotionReach/views/pages/sleep_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NavbarbannerWidget extends StatefulWidget {
  const NavbarbannerWidget({
    super.key,
    this.onBrandTap,
    this.onSosTap,
    this.onMenuTap,
  });

  /// Fires when a brand button is tapped. Passes the selected [BannerEntry],
  /// or null when the selection is cleared.
  final Function(BannerEntry?)? onBrandTap;

  final VoidCallback? onSosTap;

  /// Normal menu action (open settings bar etc.)
  final VoidCallback? onMenuTap;

  @override
  State<NavbarbannerWidget> createState() => NavbarbannerWidgetState();
}

class NavbarbannerWidgetState extends State<NavbarbannerWidget> {
  int _selectedSlotIndex = -1;

  @override
  void initState() {
    super.initState();
    BannerEntryProvider.instance.addListener(_onEntriesChanged);
  }

  @override
  void dispose() {
    BannerEntryProvider.instance.removeListener(_onEntriesChanged);
    super.dispose();
  }

  void _onEntriesChanged() {
    // Clear selection if the list shifted — the old slot no longer points at
    // the same entry.
    if (mounted) {
      setState(() {
        _selectedSlotIndex = -1;
      });
    }
  }

  bool get _hasBrandSelected => _selectedSlotIndex != -1;

  /// Parent can call this via GlobalKey.
  void clearSelection() {
    setState(() {
      _selectedSlotIndex = -1;
    });
  }

  void _selectSlot(int index, BannerEntry? entry) {
    if (entry == null) return;
    setState(() {
      _selectedSlotIndex = index;
    });
    widget.onBrandTap?.call(entry);
  }

  void _handleMenuPressed() {
    if (_hasBrandSelected) {
      clearSelection();
      widget.onBrandTap?.call(null);
      return;
    }
    widget.onMenuTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 27, 57, 87),
            Color.fromARGB(255, 51, 39, 72),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        children: [
          _buildSosButton(),
          const SizedBox(width: 5),
          Expanded(child: _buildBrandButtons()),
          const SizedBox(width: 5),
          _buildPowerButton(),
        ],
      ),
    );
  }

  Widget _buildSosButton() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
      alignment: Alignment.center,
      child: Container(
        width: 55,
        height: 50,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF2A1481), Color(0xFF9E2BFF)],
          ),
        ),
        child: TextButton(
          onPressed: widget.onSosTap,
          child: const Text(
            'SOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'BoundedVariable',
              fontVariations: [FontVariation('wght', 560)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandButtons() {
    final slots = BannerEntryProvider.instance.visibleSlots;
    return Row(
      children: List.generate(BannerEntryProvider.slotCount, (index) {
        final entry = index < slots.length ? slots[index] : null;
        final isSelected = _selectedSlotIndex == index;
        final imageUrl = entry?.bannerUrl;
        final logoUrl = entry?.logoUrl;

        return Expanded(
          child: GestureDetector(
            onTap: () => _selectSlot(index, entry),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, _) =>
                            Container(color: Colors.black.withOpacity(0.2)),
                        errorWidget: (context, _, __) =>
                            Container(color: Colors.black.withOpacity(0.2)),
                      )
                    else
                      Container(color: Colors.black.withOpacity(0.2)),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: isSelected
                          ? Colors.black.withOpacity(0.45)
                          : Colors.transparent,
                    ),

                    if (logoUrl != null && logoUrl.isNotEmpty)
                      Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 1 : 0,
                          child: CachedNetworkImage(
                            imageUrl: logoUrl,
                            height: 30,
                            fit: BoxFit.contain,
                            placeholder: (context, _) => const SizedBox.shrink(),
                            errorWidget: (context, _, __) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPowerButton() {
    return Container(
      width: 120,
      height: 130,
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _circleButton(
            icon: Icons.power_settings_new,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SleepModeScreen()),
              );
            },
          ),
          const SizedBox(width: 5),
          _circleButton(
            onTap: _handleMenuPressed,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                _hasBrandSelected ? Icons.close : Icons.menu,
                key: ValueKey(_hasBrandSelected),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    IconData? icon,
    Widget? child,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.grey[600]!, Colors.grey[800]!],
          center: Alignment.center,
          radius: 0.8,
        ),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: child ?? Icon(icon, color: Colors.white),
      ),
    );
  }
}
