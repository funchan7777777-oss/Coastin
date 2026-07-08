import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/wallet/shore_shell_wallet_store.dart';
import '../../my_coast/wallet/shore_shell_reef.dart';
import '../../safety/shore_safety_reef.dart';

enum ShoreReleaseKind { video, post }

class ShoreReleasePage extends StatefulWidget {
  const ShoreReleasePage({
    super.key,
    this.initialReleaseKind = ShoreReleaseKind.video,
  });

  final ShoreReleaseKind initialReleaseKind;

  @override
  State<ShoreReleasePage> createState() => _ShoreReleasePageState();
}

class _ShoreReleasePageState extends State<ShoreReleasePage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _copyController = TextEditingController();

  late ShoreReleaseKind _releaseKind;
  String _selectedPostTopic = 'Seaside dressing';
  XFile? _pickedHarborFile;

  @override
  void initState() {
    super.initState();
    _releaseKind = widget.initialReleaseKind;
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
                        _ReleaseKindPicker(
                          releaseKind: _releaseKind,
                          onChanged: (kind) {
                            setState(() {
                              _releaseKind = kind;
                              _pickedHarborFile = null;
                            });
                          },
                        ),
                        const SizedBox(height: 38),
                        _HarborMediaDropZone(
                          pickedFile: _pickedHarborFile,
                          releaseKind: _releaseKind,
                          onPickTap: _pickHarborFile,
                          onClearTap: () {
                            setState(() => _pickedHarborFile = null);
                          },
                        ),
                        if (_releaseKind == ShoreReleaseKind.post) ...[
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
                            'Copywriting',
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
                          placeholder: 'Please enter...',
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
    final nextFile = _releaseKind == ShoreReleaseKind.video
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 86,
          );
    if (!mounted || nextFile == null) {
      return;
    }
    setState(() => _pickedHarborFile = nextFile);
  }

  Future<void> _releaseMoment() async {
    final hasCopy = _copyController.text.trim().isNotEmpty;
    if (_pickedHarborFile == null || !hasCopy) {
      _showReleaseNote(
        title: 'Shore draft needs more',
        message: 'Please add a video or picture and a short caption first.',
      );
      return;
    }
    final expense = _releaseKind == ShoreReleaseKind.video
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
        return CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(message),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                onDone?.call();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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

class _ReleaseKindPicker extends StatelessWidget {
  const _ReleaseKindPicker({
    required this.releaseKind,
    required this.onChanged,
  });

  final ShoreReleaseKind releaseKind;
  final ValueChanged<ShoreReleaseKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ReleaseKindButton(
          asset: releaseKind == ShoreReleaseKind.video
              ? CoastinAssetRegistry.videosTabActive
              : CoastinAssetRegistry.videosTabResting,
          onTap: () => onChanged(ShoreReleaseKind.video),
        ),
        const SizedBox(width: 44),
        _ReleaseKindButton(
          asset: releaseKind == ShoreReleaseKind.post
              ? CoastinAssetRegistry.postsTabActive
              : CoastinAssetRegistry.postsTabResting,
          onTap: () => onChanged(ShoreReleaseKind.post),
        ),
      ],
    );
  }
}

class _ReleaseKindButton extends StatelessWidget {
  const _ReleaseKindButton({required this.asset, required this.onTap});

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
              topicLabel: _postTopics[index],
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
    required this.topicLabel,
    required this.isSelected,
    required this.onTap,
  });

  final String topicLabel;
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
          topicLabel,
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
    required this.releaseKind,
    required this.onPickTap,
    required this.onClearTap,
  });

  final XFile? pickedFile;
  final ShoreReleaseKind releaseKind;
  final VoidCallback onPickTap;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
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
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF56E4DD).withValues(alpha: 0.66),
                width: 1.4,
                style: BorderStyle.solid,
              ),
            ),
            child: pickedFile == null
                ? _EmptyReleaseCue(releaseKind: releaseKind)
                : _PickedReleasePreview(
                    pickedFile: pickedFile!,
                    releaseKind: releaseKind,
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
  const _EmptyReleaseCue({required this.releaseKind});

  final ShoreReleaseKind releaseKind;

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
          releaseKind == ShoreReleaseKind.video
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
    required this.releaseKind,
  });

  final XFile pickedFile;
  final ShoreReleaseKind releaseKind;

  @override
  Widget build(BuildContext context) {
    if (releaseKind == ShoreReleaseKind.post) {
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
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 60,
            child: Image.asset(
              CoastinAssetRegistry.releaseButtonPlate,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            right: -6,
            top: -18,
            child: Image.asset(
              CoastinAssetRegistry.redReleaseCorner,
              width: 64,
              height: 38,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}
