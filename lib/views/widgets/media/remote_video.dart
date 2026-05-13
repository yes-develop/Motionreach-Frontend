import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Plays a video from a URL. When [looping] is false, [onEnded] fires once
/// when playback reaches the end. Used by the bundle player to advance to the
/// next bundle when a video finishes.
class NetworkVideoPlayer extends StatefulWidget {
  const NetworkVideoPlayer({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.looping = true,
    this.onEnded,
  });

  final String url;
  final BoxFit fit;
  final bool looping;
  final VoidCallback? onEnded;

  @override
  State<NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<NetworkVideoPlayer> {
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _endedFired = false;
  Timer? _endPoller;

  Duration _lastPosition = Duration.zero;
  int _stableCount = 0;
  DateTime? _playStartTime;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _videoController.addListener(_onVideoUpdate);
    _videoController.initialize().then((_) {
      if (!mounted) return;
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: widget.looping,
        showControls: false,
        allowFullScreen: false,
        allowPlaybackSpeedChanging: false,
        allowMuting: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.white,
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
          handleColor: Colors.white,
        ),
        placeholder: const Center(child: CircularProgressIndicator()),
      );
      _videoController.play();

      if (!widget.looping) {
        _endPoller = Timer.periodic(const Duration(milliseconds: 500), (t) {
          if (!mounted || _endedFired) {
            t.cancel();
            return;
          }
          _checkForEnd();
        });
      }

      setState(() {});
    }).catchError((e) {
      if (!mounted) return;
      setState(() => _hasError = true);
    });
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    _checkForEnd();
    setState(() {});
  }

  void _checkForEnd() {
    if (widget.looping || _endedFired) return;
    final value = _videoController.value;
    if (!value.isInitialized) return;

    final position = value.position;
    final isPlaying = value.isPlaying;
    final positionMs = position.inMilliseconds;
    final durationMs = value.duration.inMilliseconds;

    // Track when playback actually started (first tick with isPlaying=true).
    if (isPlaying && _playStartTime == null) {
      _playStartTime = DateTime.now();
    }

    // Track position stability when playback is stopped (position unchanged
    // between ticks while !isPlaying = likely reached the end).
    if (!isPlaying && position == _lastPosition) {
      _stableCount++;
    } else if (position != _lastPosition) {
      _stableCount = 0;
    }
    _lastPosition = position;

    // ── Strategy 1: reported duration is trustworthy (> 1s) and we reached it.
    final reachedReportedEnd = durationMs > 1000 &&
        positionMs >= durationMs - 300 &&
        positionMs > 500;

    // ── Strategy 2: fallback for videos with bad duration metadata.
    // Playback stopped, not buffering, position stable, and we played for 2s+.
    final playedLongEnough = _playStartTime != null &&
        DateTime.now().difference(_playStartTime!).inSeconds >= 2;
    final stoppedAndStable = !isPlaying &&
        !value.isBuffering &&
        _stableCount >= 3 && // ~1.5 seconds of stable position
        playedLongEnough;

    if (reachedReportedEnd || stoppedAndStable) {
      _endedFired = true;
      _endPoller?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onEnded?.call();
      });
    }
  }

  @override
  void dispose() {
    _endPoller?.cancel();
    _videoController.removeListener(_onVideoUpdate);
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(child: Icon(Icons.broken_image, size: 48));
    }
    if (_chewieController == null || !_videoController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return FittedBox(
      fit: widget.fit,
      child: SizedBox(
        width: _videoController.value.size.width,
        height: _videoController.value.size.height,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}
