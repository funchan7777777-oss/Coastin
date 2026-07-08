import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

import '../../../../app/theme/tidewash_palette.dart';
import '../../../domain/entities/buddies/sea_buddy_thread.dart';
import 'sea_buddy_call_permissions.dart';

class SeaBuddyCallPage extends StatefulWidget {
  const SeaBuddyCallPage({super.key, required this.thread});

  final SeaBuddyThread thread;

  @override
  State<SeaBuddyCallPage> createState() => _SeaBuddyCallPageState();
}

class _SeaBuddyCallPageState extends State<SeaBuddyCallPage> {
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = const [];
  bool _isPreparingAccess = true;
  bool _cameraAllowed = false;
  bool _microphoneAllowed = false;
  bool _cameraOn = true;
  bool _microphoneOn = true;
  bool _speakerOn = true;
  bool _frontCamera = true;

  @override
  void initState() {
    super.initState();
    _prepareCallAccess();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _prepareCallAccess() async {
    final access = await SeaBuddyCallPermissions.requestAccess();
    if (!mounted) {
      return;
    }
    setState(() {
      _cameraAllowed = access.cameraAllowed;
      _microphoneAllowed = access.microphoneAllowed;
      _cameraOn = access.cameraAllowed;
      _microphoneOn = access.microphoneAllowed;
      _isPreparingAccess = false;
    });
    if (access.cameraAllowed) {
      await _prepareCamera();
    }
  }

  Future<void> _prepareCamera() async {
    try {
      _availableCameras = await availableCameras();
      await _startCamera(isFront: _frontCamera);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _cameraOn = false);
    }
  }

  Future<void> _startCamera({required bool isFront}) async {
    if (_availableCameras.isEmpty || !_cameraAllowed) {
      return;
    }
    final selectedCamera = _availableCameras.firstWhere(
      (camera) =>
          camera.lensDirection ==
          (isFront ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => _availableCameras.first,
    );
    await _cameraController?.dispose();
    final controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: _microphoneAllowed && _microphoneOn,
    );
    _cameraController = controller;
    try {
      await controller.initialize();
    } catch (_) {
      if (_cameraController == controller) {
        await controller.dispose();
        _cameraController = null;
      }
      if (!mounted) {
        return;
      }
      setState(() => _cameraOn = false);
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.thread.buddyPersona.displayHarborName
        .split(' ')
        .first;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF061821),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _CallWaitingBackdrop(),
            Positioned(
              left: 18,
              top: 54,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    color: Color(0xFFEAFBFF),
                    size: 28,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 24,
              top: 60,
              child: _CallStatusPill(
                text: _isPreparingAccess ? 'Preparing' : 'Waiting',
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              top: 108,
              child: _RemoteWaitingCard(
                name: widget.thread.buddyPersona.displayHarborName,
                stamp: widget.thread.buddyPersona.coastalStamp,
                avatarAsset: widget.thread.buddyPersona.avatarAsset,
                statusText: _isPreparingAccess
                    ? 'Checking camera and microphone access'
                    : 'Waiting for $firstName to answer',
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: 284,
              bottom: 206,
              child: _LocalPreviewPanel(
                controller: _cameraController,
                isPreparingAccess: _isPreparingAccess,
                cameraAllowed: _cameraAllowed,
                microphoneAllowed: _microphoneAllowed,
                cameraOn: _cameraOn,
                microphoneOn: _microphoneOn,
              ),
            ),
            Positioned(
              left: 30,
              right: 30,
              bottom: 118,
              child: _CallControlDock(
                cameraAllowed: _cameraAllowed,
                microphoneAllowed: _microphoneAllowed,
                cameraOn: _cameraOn,
                microphoneOn: _microphoneOn,
                speakerOn: _speakerOn,
                onFlipTap: _flipCamera,
                onCameraTap: _toggleCamera,
                onSpeakerTap: () => setState(() => _speakerOn = !_speakerOn),
                onMicrophoneTap: _toggleMicrophone,
              ),
            ),
            Positioned(
              left: 46,
              right: 46,
              bottom: 42,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F68D3),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.phone_down_fill,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'End call',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _flipCamera() async {
    if (!_cameraAllowed || !_cameraOn) {
      return;
    }
    final nextFrontCamera = !_frontCamera;
    setState(() => _frontCamera = nextFrontCamera);
    await _startCamera(isFront: nextFrontCamera);
  }

  Future<void> _toggleCamera() async {
    if (!_cameraAllowed) {
      return;
    }
    if (_cameraOn) {
      await _cameraController?.dispose();
      _cameraController = null;
      if (!mounted) {
        return;
      }
      setState(() => _cameraOn = false);
      return;
    }
    setState(() => _cameraOn = true);
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await _prepareCamera();
    }
  }

  void _toggleMicrophone() {
    if (!_microphoneAllowed) {
      return;
    }
    setState(() => _microphoneOn = !_microphoneOn);
  }
}

class _CallWaitingBackdrop extends StatelessWidget {
  const _CallWaitingBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D3852), Color(0xFF123E55), Color(0xFF0A1C27)],
        ),
      ),
    );
  }
}

class _CallStatusPill extends StatelessWidget {
  const _CallStatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xAAFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x55FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(radius: 7),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoteWaitingCard extends StatelessWidget {
  const _RemoteWaitingCard({
    required this.name,
    required this.stamp,
    required this.avatarAsset,
    required this.statusText,
  });

  final String name;
  final String stamp;
  final String avatarAsset;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xDDF7FFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x66FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              avatarAsset,
              width: 78,
              height: 78,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TidewashPalette.inkBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stamp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF667987),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  statusText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2F68D3),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalPreviewPanel extends StatelessWidget {
  const _LocalPreviewPanel({
    required this.controller,
    required this.isPreparingAccess,
    required this.cameraAllowed,
    required this.microphoneAllowed,
    required this.cameraOn,
    required this.microphoneOn,
  });

  final CameraController? controller;
  final bool isPreparingAccess;
  final bool cameraAllowed;
  final bool microphoneAllowed;
  final bool cameraOn;
  final bool microphoneOn;

  @override
  Widget build(BuildContext context) {
    final isCameraReady =
        cameraOn && controller != null && controller!.value.isInitialized;
    final panelRadius = BorderRadius.circular(34);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B2431),
        borderRadius: panelRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: panelRadius,
        border: Border.all(color: const Color(0xAAFFFFFF), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isCameraReady)
            _CameraPreviewCover(controller: controller!)
          else
            _PreviewPlaceholder(
              icon: _placeholderIcon,
              title: _placeholderTitle,
              detail: _placeholderDetail,
            ),
          const Positioned(
            left: 16,
            top: 16,
            child: _PreviewBadge(text: 'Your preview'),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PreviewBadge(text: cameraOn ? 'Camera on' : 'Camera off'),
                const SizedBox(height: 8),
                _PreviewBadge(
                  text: microphoneAllowed
                      ? (microphoneOn ? 'Mic on' : 'Mic off')
                      : 'Mic blocked',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData get _placeholderIcon {
    if (isPreparingAccess) {
      return CupertinoIcons.camera_viewfinder;
    }
    if (!cameraAllowed) {
      return CupertinoIcons.lock_slash_fill;
    }
    if (!cameraOn) {
      return CupertinoIcons.video_camera;
    }
    return CupertinoIcons.camera_fill;
  }

  String get _placeholderTitle {
    if (isPreparingAccess) {
      return 'Preparing preview';
    }
    if (!cameraAllowed) {
      return 'Camera access needed';
    }
    if (!cameraOn) {
      return 'Camera paused';
    }
    return 'Opening camera';
  }

  String get _placeholderDetail {
    if (isPreparingAccess) {
      return 'Coastin is asking for camera and microphone access.';
    }
    if (!cameraAllowed) {
      return 'Allow camera access to preview yourself before the call.';
    }
    if (!cameraOn) {
      return 'Turn the camera back on when you are ready.';
    }
    return 'Your local preview will appear here.';
  }
}

class _CameraPreviewCover extends StatelessWidget {
  const _CameraPreviewCover({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxHeight >= constraints.maxWidth;
        final previewWidth = isPortrait
            ? previewSize.height
            : previewSize.width;
        final previewHeight = isPortrait
            ? previewSize.width
            : previewSize.height;
        return SizedBox.expand(
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: previewWidth,
                height: previewHeight,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF154D65), Color(0xFF071923)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFEAFBFF), size: 44),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xBFEAFBFF),
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xB3000000),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CallControlDock extends StatelessWidget {
  const _CallControlDock({
    required this.cameraAllowed,
    required this.microphoneAllowed,
    required this.cameraOn,
    required this.microphoneOn,
    required this.speakerOn,
    required this.onFlipTap,
    required this.onCameraTap,
    required this.onSpeakerTap,
    required this.onMicrophoneTap,
  });

  final bool cameraAllowed;
  final bool microphoneAllowed;
  final bool cameraOn;
  final bool microphoneOn;
  final bool speakerOn;
  final VoidCallback onFlipTap;
  final VoidCallback onCameraTap;
  final VoidCallback onSpeakerTap;
  final VoidCallback onMicrophoneTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xAA071923),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CallControlButton(
            label: 'Flip camera',
            icon: CupertinoIcons.camera_rotate_fill,
            isActive: cameraAllowed && cameraOn,
            isDisabled: !cameraAllowed || !cameraOn,
            onTap: onFlipTap,
          ),
          _CallControlButton(
            label: cameraOn ? 'Turn camera off' : 'Turn camera on',
            icon: cameraOn
                ? CupertinoIcons.video_camera_solid
                : CupertinoIcons.video_camera,
            isActive: cameraAllowed && cameraOn,
            isDisabled: !cameraAllowed,
            onTap: onCameraTap,
          ),
          _CallControlButton(
            label: speakerOn ? 'Turn speaker off' : 'Turn speaker on',
            icon: speakerOn
                ? CupertinoIcons.speaker_2_fill
                : CupertinoIcons.speaker_slash_fill,
            isActive: speakerOn,
            onTap: onSpeakerTap,
          ),
          _CallControlButton(
            label: microphoneOn ? 'Mute microphone' : 'Unmute microphone',
            icon: microphoneOn
                ? CupertinoIcons.mic_fill
                : CupertinoIcons.mic_slash_fill,
            isActive: microphoneAllowed && microphoneOn,
            isDisabled: !microphoneAllowed,
            onTap: onMicrophoneTap,
          ),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.isDisabled = false,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isDisabled ? null : onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isDisabled ? 0.42 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFEAFBFF)
                  : const Color(0x5527313A),
              borderRadius: BorderRadius.circular(29),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF2F68D3) : CupertinoColors.white,
              size: 27,
            ),
          ),
        ),
      ),
    );
  }
}
