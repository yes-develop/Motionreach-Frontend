import 'package:MotionReach/providers/command_provider.dart';
import 'package:MotionReach/views/pages/default_page.dart';
import 'package:MotionReach/views/widgets/navbar/navbar_overlay_widget.dart';
import 'package:MotionReach/views/widgets/navbar/navbarsleep_widget.dart';
import 'package:MotionReach/views/widgets/settingsbar_widget.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SleepModeScreen extends StatefulWidget {
  const SleepModeScreen({super.key});

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen> {
  bool _isSosOverlayOpen = false;
  bool _isHelpOverlayOpen = false;
  bool _showSettingsBar = false;
  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();
    // Source of truth for the is_screen_on heartbeat sent to /remotes.
    // Covers every way this page can be entered: BackOffice command,
    // inactivity timeout, manual navigation.
    CommandProvider.instance.markScreenOff();
    // Start 10-minute timer
    _autoNavigateTimer = Timer(const Duration(minutes: 10), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DefaultPage()),
        (_) => false,
      );
      });
  }

  @override
  void dispose() {
    // Leaving sleep page (tap-to-wake, auto-return, command) → heartbeat
    // should report screen on again.
    CommandProvider.instance.markScreenOn();
    // Cancel timer when screen is disposed
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  void _openSosOverlay() {
    setState(() {
      _isSosOverlayOpen = true;
    });
  }

  void _closeSosOverlay() {
    setState(() {
      _isSosOverlayOpen = false;
    });
  }

  void _openHelpOverlay() {
    setState(() {
      _isHelpOverlayOpen = true;
    });
  }

  void _closeHelpOverlay() {
    setState(() {
      _isHelpOverlayOpen = false;
    });
  }

  void _toggleNavbar() {
    setState(() {
      _showSettingsBar = !_showSettingsBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 24, 0, 67),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Bounded',
      ),
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DefaultPage()),
              (_) => false,
            );
          },
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: const Center(
                      child: Text(
                        'Sleep Mode. Tap to resume.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  _showSettingsBar
                      ? SettingsbarWidget(
                          onSosTap: _openSosOverlay,
                          onHelpTap: _openHelpOverlay,
                          onCloseTap: _toggleNavbar,
                        )
                      : NavbarSleepWidget(
                          onSosTap: _openSosOverlay,
                          onHelpTap: _openHelpOverlay,
                          onMenuTap: _toggleNavbar,
                        ),
                ],
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
        ),
      ),
    );
  }
}
