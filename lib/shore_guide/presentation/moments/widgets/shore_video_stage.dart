import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class ShoreVideoStage extends StatefulWidget {
  const ShoreVideoStage({
    super.key,
    required this.tideClipAsset,
    required this.shouldDrift,
    required this.isPausedByViewer,
  });

  final String tideClipAsset;
  final bool shouldDrift;
  final bool isPausedByViewer;

  @override
  State<ShoreVideoStage> createState() => _ShoreVideoStageState();
}

class _ShoreVideoStageState extends State<ShoreVideoStage> {
  late VideoPlayerController _videoController;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _prepareVideoController();
  }

  @override
  void didUpdateWidget(covariant ShoreVideoStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tideClipAsset != widget.tideClipAsset) {
      _videoController.dispose();
      _isReady = false;
      _prepareVideoController();
      return;
    }
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

  void _prepareVideoController() {
    final controller = VideoPlayerController.asset(widget.tideClipAsset);
    _videoController = controller;
    controller
      ..setLooping(true)
      ..setVolume(0);
    controller
        .initialize()
        .then((_) {
          if (!mounted || !identical(controller, _videoController)) {
            return;
          }
          setState(() => _isReady = true);
          _syncPlayback();
        })
        .catchError((Object _) {});
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
