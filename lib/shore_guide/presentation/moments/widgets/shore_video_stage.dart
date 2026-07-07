import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class ShoreVideoStage extends StatefulWidget {
  const ShoreVideoStage({
    super.key,
    required this.videoAsset,
    required this.shouldDrift,
    required this.isPausedByViewer,
  });

  final String videoAsset;
  final bool shouldDrift;
  final bool isPausedByViewer;

  @override
  State<ShoreVideoStage> createState() => _ShoreVideoStageState();
}

class _ShoreVideoStageState extends State<ShoreVideoStage> {
  late final VideoPlayerController _videoController;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(widget.videoAsset);
    _videoController
      ..setLooping(true)
      ..setVolume(0);
    _videoController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() => _isReady = true);
      _syncPlayback();
    });
  }

  @override
  void didUpdateWidget(covariant ShoreVideoStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldDrift != widget.shouldDrift ||
        oldWidget.isPausedByViewer != widget.isPausedByViewer) {
      _syncPlayback();
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _syncPlayback() {
    if (!_isReady) {
      return;
    }
    if (widget.shouldDrift && !widget.isPausedByViewer) {
      _videoController.play();
    } else {
      _videoController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const ColoredBox(
        color: Color(0xFF0B1F29),
        child: Center(
          child: CupertinoActivityIndicator(color: Color(0xFFFFFFFF)),
        ),
      );
    }

    final videoSize = _videoController.value.size;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(_videoController),
        ),
      ),
    );
  }
}
