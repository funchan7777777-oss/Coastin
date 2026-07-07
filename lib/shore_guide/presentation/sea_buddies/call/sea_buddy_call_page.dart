import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/seeded_shore_moment_deck.dart';
import '../../../domain/entities/buddies/sea_buddy_thread.dart';

class SeaBuddyCallPage extends StatefulWidget {
  const SeaBuddyCallPage({super.key, required this.thread});

  final SeaBuddyThread thread;

  @override
  State<SeaBuddyCallPage> createState() => _SeaBuddyCallPageState();
}

class _SeaBuddyCallPageState extends State<SeaBuddyCallPage> {
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = const [];
  bool _cameraOn = true;
  bool _microphoneOn = true;
  bool _speakerOn = true;
  bool _frontCamera = true;

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
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
    if (_availableCameras.isEmpty) {
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
      ResolutionPreset.medium,
      enableAudio: true,
    );
    _cameraController = controller;
    await controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final viewerPersona = SeededShoreMomentDeck.shorelinePeople[37];
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF061821),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.thread.buddyPersona.avatarAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x11000000),
                    Color(0x66000000),
                  ],
                  stops: [0, 0.46, 1],
                ),
              ),
            ),
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
                    color: TidewashPalette.inkBlue,
                    size: 28,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 24,
              top: 116,
              child: Container(
                width: 120,
                height: 168,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFF2F68D3), width: 3),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    _cameraOn &&
                        _cameraController != null &&
                        _cameraController!.value.isInitialized
                    ? CameraPreview(_cameraController!)
                    : Image.asset(
                        viewerPersona.avatarAsset,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
              ),
            ),
            Positioned(
              left: 36,
              right: 36,
              bottom: 118,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallRoundControl(
                        asset: _frontCamera
                            ? CoastinAssetRegistry.cameraFlipLive
                            : CoastinAssetRegistry.cameraFlipMuted,
                        onTap: _flipCamera,
                      ),
                      _CallRoundControl(
                        asset: _cameraOn
                            ? CoastinAssetRegistry.cameraVideoLive
                            : CoastinAssetRegistry.cameraVideoMuted,
                        onTap: () => setState(() => _cameraOn = !_cameraOn),
                      ),
                      _CallRoundControl(
                        asset: _speakerOn
                            ? CoastinAssetRegistry.speakerLive
                            : CoastinAssetRegistry.speakerMuted,
                        onTap: () => setState(() => _speakerOn = !_speakerOn),
                      ),
                      _CallRoundControl(
                        asset: _microphoneOn
                            ? CoastinAssetRegistry.microphoneLive
                            : CoastinAssetRegistry.microphoneMuted,
                        onTap: () {
                          setState(() => _microphoneOn = !_microphoneOn);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallRoundControl(
                        asset: CoastinAssetRegistry.cameraFlipMuted,
                        onTap: () => setState(() => _frontCamera = false),
                        isDim: true,
                      ),
                      _CallRoundControl(
                        asset: CoastinAssetRegistry.cameraVideoMuted,
                        onTap: () => setState(() => _cameraOn = false),
                        isDim: true,
                      ),
                      _CallRoundControl(
                        asset: CoastinAssetRegistry.speakerMuted,
                        onTap: () => setState(() => _speakerOn = false),
                        isDim: true,
                      ),
                      _CallRoundControl(
                        asset: CoastinAssetRegistry.microphoneMuted,
                        onTap: () => setState(() => _microphoneOn = false),
                        isDim: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 46,
              right: 46,
              bottom: 52,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset(
                  CoastinAssetRegistry.endCallPlate,
                  height: 62,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _flipCamera() async {
    setState(() => _frontCamera = !_frontCamera);
    await _startCamera(isFront: _frontCamera);
  }
}

class _CallRoundControl extends StatelessWidget {
  const _CallRoundControl({
    required this.asset,
    required this.onTap,
    this.isDim = false,
  });

  final String asset;
  final VoidCallback onTap;
  final bool isDim;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: isDim ? 0.72 : 1,
        child: SizedBox(
          width: 58,
          height: 58,
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
