import 'package:MotionReach/providers/banner_entry_provider.dart';
import 'package:MotionReach/providers/bundle_provider.dart';
import 'package:MotionReach/providers/command_provider.dart';
import 'package:MotionReach/providers/help_provider.dart';
import 'package:MotionReach/views/pages/default_page.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Key on the top-level RepaintBoundary so the screenshot service can capture
/// whatever is currently rendered (bundle video, sleep screen, overlays, etc.).
final GlobalKey screenshotBoundaryKey = GlobalKey();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    CommandProvider.instance.start(navigatorKey);
    BundleProvider.instance.start();
    BannerEntryProvider.instance.start();
    HelpProvider.instance.start();
  }

  @override
  void dispose() {
    CommandProvider.instance.stop();
    BundleProvider.instance.stop();
    BannerEntryProvider.instance.stop();
    HelpProvider.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Bounded',
      ),
      // Wrap every rendered route in a RepaintBoundary so the screenshot
      // service can grab a PNG of the current UI on demand (Feature 3).
      builder: (context, child) {
        return RepaintBoundary(
          key: screenshotBoundaryKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const DefaultPage(),
    );
  }
}
