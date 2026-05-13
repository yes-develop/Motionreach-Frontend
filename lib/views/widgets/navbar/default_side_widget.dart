import 'package:MotionReach/providers/bundle_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shows the current bundle's side image (paired with the main video).
/// Re-renders whenever [BundleProvider] advances or refreshes.
class DefaultSideContentWidget extends StatefulWidget {
  const DefaultSideContentWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<DefaultSideContentWidget> createState() => _DefaultSideContentWidgetState();
}

class _DefaultSideContentWidgetState extends State<DefaultSideContentWidget> {
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

    return InkWell(
      onTap: widget.onTap,
      child: SizedBox.expand(
        child: (url == null || url.isEmpty)
            ? const Center(child: Icon(Icons.image, size: 48, color: Colors.white24))
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, _, __) =>
                    const Center(child: Icon(Icons.broken_image, size: 48)),
              ),
      ),
    );
  }
}
