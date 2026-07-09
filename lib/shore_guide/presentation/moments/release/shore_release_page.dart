import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/wallet/shore_shell_wallet_store.dart';
import '../../../domain/value_objects/shore_content_safety_gate.dart';
import '../../my_coast/wallet/shore_shell_reef.dart';
import '../../safety/shore_safety_reef.dart';

enum ShoreReleaseChannel { video, post }

class ShoreReleasePage extends StatefulWidget {
  const ShoreReleasePage({
    super.key,
    this.initialReleaseChannel = ShoreReleaseChannel.video,
  });

  final ShoreReleaseChannel initialReleaseChannel;

  @override
  State<ShoreReleasePage> createState() => _ShoreReleasePageState();
}

class _ShoreReleasePageState extends State<ShoreReleasePage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _copyController = TextEditingController();

  late ShoreReleaseChannel _releaseChannel;
  String _selectedPostTopic = 'Seaside dressing';
  XFile? _pickedHarborFile;

  @override
  void initState() {
    super.initState();
    _releaseChannel = widget.initialReleaseChannel;
  }

  @override
  void dispose() {
    _copyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFDF7DC),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFDF7DC),
                      const Color(0xFFE7F8E6),
                      const Color(0xFFBDF8F3).withValues(alpha: 0.94),
                    ],
                  ),
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 54, 24, 30),
                    child: Column(
                      children: [
                        _ReleaseTopBar(
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 44),
                        _ReleaseChannelPicker(
                          releaseChannel: _releaseChannel,
                          onChanged: (releaseChannel) {
                            setState(() {
                              _releaseChannel = releaseChannel;
                              _pickedHarborFile = null;
                            });
                          },
                        ),
                        const SizedBox(height: 38),
                        _HarborMediaDropZone(
                          pickedFile: _pickedHarborFile,
                          releaseChannel: _releaseChannel,
                          onPickTap: _pickHarborFile,
                          onClearTap: () {
                            setState(() => _pickedHarborFile = null);
                          },
                        ),
                        if (_releaseChannel == ShoreReleaseChannel.post) ...[
                          const SizedBox(height: 28),
                          _ReleaseTopicChips(
                            selectedTopic: _selectedPostTopic,
                            onChanged: (topic) {
                              setState(() => _selectedPostTopic = topic);
                            },
                          ),
                        ],
                        const SizedBox(height: 32),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Shore note',
                            style: TextStyle(
                              color: TidewashPalette.harborSlate,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CupertinoTextField(
                          controller: _copyController,
                          placeholder:
                              'Add a calm caption for this shoreline moment',
                          minLines: 4,
                          maxLines: 5,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFFFFF,
                            ).withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          style: const TextStyle(
                            color: TidewashPalette.inkBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 92),
                        _ReleaseButton(onTap: _releaseMoment),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickHarborFile() async {
    XFile? nextFile;
    try {
      nextFile = _releaseChannel == ShoreReleaseChannel.video
          ? await _pickVideoFile()
          : await _pickPostImageFile();
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showReleaseNote(
        title: 'Media was not added',
        message:
            'Allow camera or photo library access, then choose a shoreline file again.',
      );
      return;
    }
    if (!mounted || nextFile == null) {
      return;
    }
    setState(() => _pickedHarborFile = nextFile);
  }

  Future<XFile?> _pickVideoFile() async {
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return CupertinoActionSheet(
          title: const Text('Shoreline video'),
          message: const Text(
            'Pick a library video or record a new shoreline clip.',
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(sheetContext).pop(ImageSource.gallery),
              child: const Text('Choose from Library'),
            ),
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(sheetContext).pop(ImageSource.camera),
              child: const Text('Record Video'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
    if (!mounted || source == null) {
      return null;
    }
    return _picker.pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 60),
    );
  }

  Future<XFile?> _pickPostImageFile() async {
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return CupertinoActionSheet(
          title: const Text('Shoreline picture'),
          message: const Text(
            'Pick a library image or take a new shoreline photo.',
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(sheetContext).pop(ImageSource.gallery),
              child: const Text('Choose from Library'),
            ),
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(sheetContext).pop(ImageSource.camera),
              child: const Text('Take Photo'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
    if (!mounted || source == null) {
      return null;
    }
    return _picker.pickImage(source: source, imageQuality: 86);
  }

  Future<void> _releaseMoment() async {
    final caption = _copyController.text.trim();
    if (_pickedHarborFile == null || caption.isEmpty) {
      _showReleaseNote(
        title: 'Shore draft needs more',
        message: 'Add shoreline media and a short caption before sharing.',
      );
      return;
    }
    final safetyDecision = ShoreContentSafetyGate.inspect(
      caption,
      surface: ShoreContentSurface.publicCaption,
    );
    if (!safetyDecision.isAllowed) {
      _showReleaseNote(
        title: safetyDecision.title,
        message: safetyDecision.message,
      );
      return;
    }
    final expense = _releaseChannel == ShoreReleaseChannel.video
        ? ShoreShellExpense.publishVideo
        : ShoreShellExpense.publishPost;
    final canRelease = await ShoreShellReef.confirmAndSpend(
      context: context,
      expense: expense,
    );
    if (!canRelease || !mounted) {
      return;
    }
    ShoreSafetyReef.showModerationQueued(
      context: context,
      onDone: () => Navigator.of(context).pop(),
    );
  }

  void _showReleaseNote({
    required String title,
    required String message,
    VoidCallback? onDone,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return _ReleaseNoticeDialog(
          title: title,
          message: message,
          onDone: () {
            Navigator.of(context).pop();
            onDone?.call();
          },
        );
      },
    );
  }
}

class _ReleaseNoticeDialog extends StatelessWidget {
  const _ReleaseNoticeDialog({
    required this.title,
    required this.message,
    required this.onDone,
  });

  final String title;
  final String message;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoPopupSurface(
        isSurfacePainted: false,
        child: Container(
          width: 318,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFEFFFF9)],
            ),
            border: Border.all(
              color: const Color(0xFF9CECE6).withValues(alpha: 0.78),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B6E92).withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE9F9FF),
                  border: Border.all(
                    color: const Color(0xFF68D8E1).withValues(alpha: 0.54),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    CoastinAssetRegistry.warningBlueBadge,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TidewashPalette.inkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TidewashPalette.harborSlate.withValues(alpha: 0.82),
                  fontSize: 15,
                  height: 1.38,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDone,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F68D3),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2F68D3).withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReleaseTopBar extends StatelessWidget {
  const _ReleaseTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              CupertinoIcons.chevron_left,
              color: TidewashPalette.inkBlue,
              size: 27,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Share',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }
}

class _ReleaseChannelPicker extends StatelessWidget {
  const _ReleaseChannelPicker({
    required this.releaseChannel,
    required this.onChanged,
  });

  final ShoreReleaseChannel releaseChannel;
  final ValueChanged<ShoreReleaseChannel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ReleaseChannelButton(
          asset: releaseChannel == ShoreReleaseChannel.video
              ? CoastinAssetRegistry.videosTabActive
              : CoastinAssetRegistry.videosTabResting,
          onTap: () => onChanged(ShoreReleaseChannel.video),
        ),
        const SizedBox(width: 44),
        _ReleaseChannelButton(
          asset: releaseChannel == ShoreReleaseChannel.post
              ? CoastinAssetRegistry.postsTabActive
              : CoastinAssetRegistry.postsTabResting,
          onTap: () => onChanged(ShoreReleaseChannel.post),
        ),
      ],
    );
  }
}

class _ReleaseChannelButton extends StatelessWidget {
  const _ReleaseChannelButton({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 88,
        height: 34,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _ReleaseTopicChips extends StatelessWidget {
  const _ReleaseTopicChips({
    required this.selectedTopic,
    required this.onChanged,
  });

  final String selectedTopic;
  final ValueChanged<String> onChanged;

  static const List<String> _postTopics = [
    'Seaside dressing',
    'Seaside games',
    'Seaside cuisine',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < _postTopics.length; index++) ...[
          Expanded(
            child: _ReleaseTopicChip(
              tideTopicLabel: _postTopics[index],
              isSelected: selectedTopic == _postTopics[index],
              onTap: () => onChanged(_postTopics[index]),
            ),
          ),
          if (index != _postTopics.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _ReleaseTopicChip extends StatelessWidget {
  const _ReleaseTopicChip({
    required this.tideTopicLabel,
    required this.isSelected,
    required this.onTap,
  });

  final String tideTopicLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFE894).withValues(alpha: 0.82)
              : const Color(0xFFFFFFFF).withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE8B329)
                : const Color(0x00FFFFFF),
            width: 1.2,
          ),
        ),
        child: Text(
          tideTopicLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFE3A520)
                : TidewashPalette.harborSlate.withValues(alpha: 0.38),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HarborMediaDropZone extends StatelessWidget {
  const _HarborMediaDropZone({
    required this.pickedFile,
    required this.releaseChannel,
    required this.onPickTap,
    required this.onClearTap,
  });

  final XFile? pickedFile;
  final ShoreReleaseChannel releaseChannel;
  final VoidCallback onPickTap;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
    final dropZoneRadius = BorderRadius.circular(30);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPickTap,
          child: Container(
            width: 250,
            height: 250,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.8),
              borderRadius: dropZoneRadius,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: dropZoneRadius,
              border: Border.all(
                color: const Color(0xFF56E4DD).withValues(alpha: 0.66),
                width: 1.4,
                style: BorderStyle.solid,
              ),
            ),
            child: pickedFile == null
                ? _EmptyReleaseCue(releaseChannel: releaseChannel)
                : _PickedReleasePreview(
                    pickedFile: pickedFile!,
                    releaseChannel: releaseChannel,
                  ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClearTap,
            child: Image.asset(
              CoastinAssetRegistry.clearEntryBadge,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyReleaseCue extends StatelessWidget {
  const _EmptyReleaseCue({required this.releaseChannel});

  final ShoreReleaseChannel releaseChannel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          CoastinAssetRegistry.beachClubPlus,
          width: 70,
          height: 70,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 34),
        Text(
          releaseChannel == ShoreReleaseChannel.video
              ? 'Please add a shoreline video'
              : 'Please add a shoreline picture',
          style: TextStyle(
            color: TidewashPalette.harborSlate.withValues(alpha: 0.42),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PickedReleasePreview extends StatelessWidget {
  const _PickedReleasePreview({
    required this.pickedFile,
    required this.releaseChannel,
  });

  final XFile pickedFile;
  final ShoreReleaseChannel releaseChannel;

  @override
  Widget build(BuildContext context) {
    if (releaseChannel == ShoreReleaseChannel.post) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          File(pickedFile.path),
          width: 230,
          height: 230,
          fit: BoxFit.cover,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          CoastinAssetRegistry.playRoundBadge,
          width: 76,
          height: 76,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            pickedFile.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReleaseButton extends StatelessWidget {
  const _ReleaseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 280,
        height: 60,
        child: Image.asset(
          CoastinAssetRegistry.releaseButtonPlate,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
