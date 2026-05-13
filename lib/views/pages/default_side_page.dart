import 'package:MotionReach/providers/bundle_provider.dart';
import 'package:MotionReach/views/pages/default_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Full-screen display of the current bundle's side image. Tapping navigates
/// back to [DefaultPage]. Listens to [BundleProvider] so the image stays in
/// sync with the bundle currently playing in the main area.
class DefaultSidePage extends StatefulWidget {
  const DefaultSidePage({super.key});

  @override
  State<DefaultSidePage> createState() => _DefaultSidePageState();
}

class _DefaultSidePageState extends State<DefaultSidePage> {
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
    final url = bundle?.sideImageUrl;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const DefaultPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: SizedBox.expand(
          child: (url == null || url.isEmpty)
              ? const Center(child: Icon(Icons.image, size: 64, color: Colors.white24))
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, _) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, _, __) =>
                      const Center(child: Icon(Icons.broken_image, size: 64)),
                ),
        ),
      ),
    );
  }
}
