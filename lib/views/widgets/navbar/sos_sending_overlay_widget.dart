import 'package:flutter/material.dart';
import 'package:MotionReach/models/driver_info.dart';

class SosSendingOverlayWidget extends StatefulWidget {
  const SosSendingOverlayWidget({
    super.key,
    required this.onClose,
    this.driverInfo,
    this.passengerPhone,
  });

  final VoidCallback onClose;
  final DriverInfo? driverInfo;
  final String? passengerPhone;

  @override
  State<SosSendingOverlayWidget> createState() => _SosSendingOverlayWidgetState();
}

class _SosSendingOverlayWidgetState extends State<SosSendingOverlayWidget> {
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final driver = widget.driverInfo;

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
                      'SOS Alert',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    'The help is coming on your way.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  /// driver & passenger details
                  if (driver != null || widget.passengerPhone != null)
                    Container(
                      width: 400,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (driver != null) ...[
                            _infoRow(Icons.person, 'Driver', driver.name),
                            const SizedBox(height: 8),
                            _infoRow(Icons.directions_car, 'Vehicle',
                                '${driver.vehicleType}  ${driver.vehiclePlate}'),
                            const SizedBox(height: 8),
                            _infoRow(Icons.phone, 'Driver Phone', driver.phone),
                          ],
                          if (driver != null && widget.passengerPhone != null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(color: Colors.white24),
                            ),
                          if (widget.passengerPhone != null)
                            _infoRow(Icons.phone_callback, 'Your Phone',
                                widget.passengerPhone!),
                        ],
                      ),
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
                    // OUTER DIRECTIONAL GLOW
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

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
