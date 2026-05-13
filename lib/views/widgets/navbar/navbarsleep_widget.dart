import 'package:MotionReach/views/pages/default_page.dart';
import 'package:flutter/material.dart';

class NavbarSleepWidget extends StatefulWidget {
  const NavbarSleepWidget({
    super.key,
    this.onSosTap,
    this.onHelpTap,
    this.onMenuTap,
  });

  final VoidCallback? onSosTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onMenuTap;

  @override
  State<NavbarSleepWidget> createState() => _NavbarSleepWidgetState();
}

class _NavbarSleepWidgetState extends State<NavbarSleepWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 130,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 55,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFF2A1481),
                            const Color(0xFF9E2BFF),
                          ],
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
                    SizedBox(width: 5),
                    Container(
                      width: 55,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Colors.grey[600]!, Colors.grey[800]!],
                          center: Alignment.center,
                          radius: 0.8,
                        ),
                      ),
                      child: TextButton(
                        onPressed: widget.onHelpTap,
                        child: const Text(
                          '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'BoundedVariable',
                            fontVariations: [FontVariation('wght', 560)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'CONNECTING ',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'BoundedVariable',
                    fontVariations: [FontVariation('wght', 560)],
                  ),
                ),
                TextSpan(
                  text: 'JOURNEYS',
                  style: TextStyle(
                    color: Color(0xFF9E2BFF),
                    fontFamily: 'BoundedVariable',
                    fontVariations: [FontVariation('wght', 560)],
                  ),
                ),
                const TextSpan(
                  text: ', CONNECTING ',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'BoundedVariable',
                    fontVariations: [FontVariation('wght', 560)],
                  ),
                ),
                TextSpan(
                  text: 'BRANDS',
                  style: TextStyle(
                    color: Color(0xFF9E2BFF),
                    fontFamily: 'BoundedVariable',
                    fontVariations: [FontVariation('wght', 560)],
                  ),
                ),
              ],
            ),
            style: const TextStyle(
              fontSize: 17,
              letterSpacing: 1.2, // looks closer to your image
              fontWeight: FontWeight.bold,
            ),
          ),

          Row(
            children: [
              Container(
                width: 120,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
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
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return DefaultPage();
                              },
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(
                          Icons.power_settings_new,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(40, 40),
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
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
                        onPressed: widget.onMenuTap,
                        icon: const Icon(Icons.menu, color: Colors.white),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(40, 40),
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
    );
  }
}
