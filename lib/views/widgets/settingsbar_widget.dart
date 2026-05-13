import 'package:MotionReach/views/pages/default_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsbarWidget extends StatefulWidget {
  const SettingsbarWidget({
    super.key,
    this.onSosTap,
    this.onHelpTap,
    this.onCloseTap,
  });

  final VoidCallback? onSosTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onCloseTap;

  @override
  State<SettingsbarWidget> createState() => _SettingsbarWidgetState();
}

class _SettingsbarWidgetState extends State<SettingsbarWidget> {
  static const MethodChannel _deviceChannel = MethodChannel(
    'com.motionreach/device_controls',
  );

  double _brightnessValue = 0.7;
  double _volumeValue = 0.5;
  bool _isMuted = false;
  double _previousVolumeValue = 0.5; // Store volume before mute
  bool _isEnglish = true; // Language toggle state

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _loadDeviceState();
  }

  Future<void> _loadDeviceState() async {
    if (!_isAndroid) return;
    try {
      final brightness = await _deviceChannel.invokeMethod<double>(
        'getBrightness',
      );
      final volume = await _deviceChannel.invokeMethod<double>('getVolume');
      if (!mounted) return;
      setState(() {
        if (brightness != null) {
          _brightnessValue = brightness.clamp(0.0, 1.0);
        }
        if (volume != null) {
          _volumeValue = volume.clamp(0.0, 1.0);
          _isMuted = _volumeValue == 0.0;
          if (_volumeValue > 0) {
            _previousVolumeValue = _volumeValue;
          }
        }
      });
    } catch (_) {
      // If native calls fail, keep current UI values.
    }
  }

  Future<void> _setDeviceBrightness(double value) async {
    if (!_isAndroid) return;
    try {
      await _deviceChannel.invokeMethod('setBrightness', value);
    } catch (_) {
      // Ignore native errors for now.
    }
  }

  Future<void> _setDeviceVolume(double value) async {
    if (!_isAndroid) return;
    try {
      await _deviceChannel.invokeMethod('setVolume', value);
    } catch (_) {
      // Ignore native errors for now.
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        // Muting: store current volume and set to 0
        _previousVolumeValue = _volumeValue;
        _volumeValue = 0.0;
      } else {
        // Unmuting: restore previous volume
        _volumeValue = _previousVolumeValue;
      }
    });
    _setDeviceVolume(_volumeValue);
  }

  // void _toggleLanguage() {
  //   setState(() {
  //     _isEnglish = !_isEnglish;
  //   });
  // }

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
              SizedBox(width: 10),
              Container(
                width: 120,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey[800]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            /// 🔥 Sliding highlight
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              left: _isEnglish ? 0 : 50,
                              child: Container(
                                width: 50,
                                height: 45,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2A1481),
                                      Color(0xFF9E2BFF),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// Buttons row (on top)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _langButton('EN', true),
                                _langButton('TH', false),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Brightness, silenced, and Volumn
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Brightness icon and slider
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900]!.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFF9E2BFF),
                                  inactiveTrackColor: Colors.grey[600],
                                  thumbColor: Colors.white,
                                  overlayColor: const Color(
                                    0xFF9E2BFF,
                                  ).withOpacity(0.2),
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: _brightnessValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _brightnessValue = value;
                                    });
                                    _setDeviceBrightness(value);
                                  },
                                  min: 0.0,
                                  max: 1.0,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.wb_sunny,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Silenced button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isMuted
                            ? Colors.grey[100]!.withValues(alpha: 0.9)
                            : Colors.grey[900]!.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: IconButton(
                        onPressed: _toggleMute,
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: _isMuted ? Colors.black : Colors.white,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                    ),
                  ),

                  // Volume icon and slider
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900]!.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.volume_down,
                              color: Colors.white,
                              size: 24,
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFF9E2BFF),
                                  inactiveTrackColor: Colors.grey[600],
                                  thumbColor: Colors.white,
                                  overlayColor: const Color(
                                    0xFF9E2BFF,
                                  ).withOpacity(0.2),
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: _volumeValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _volumeValue = value;
                                      _isMuted = value == 0.0;
                                      if (value > 0) {
                                        _previousVolumeValue = value;
                                      }
                                    });
                                    _setDeviceVolume(value);
                                  },
                                  min: 0.0,
                                  max: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                        onPressed: widget.onCloseTap,
                        icon: const Icon(Icons.close, color: Colors.white),
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

  Widget _langButton(String label, bool isEnglishButton) {
    final selected = _isEnglish == isEnglishButton;

    return SizedBox(
      width: 50,
      height: 45,
      child: TextButton(
        onPressed: () {
          setState(() {
            _isEnglish = isEnglishButton;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[400],
            fontFamily: 'BoundedVariable',
            fontVariations: [FontVariation('wght', 560)],
          ),
        ),
      ),
    );
  }
}
