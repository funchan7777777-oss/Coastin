import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../domain/entities/shore_reply_drift.dart';
import '../../../domain/entities/shoreline_persona.dart';
import '../../../domain/value_objects/shore_profile_current.dart';

class ReefCommentSheet extends StatefulWidget {
  const ReefCommentSheet({
    super.key,
    required this.isOpen,
    required this.commentDrifts,
    required this.viewerPersona,
    required this.onClose,
  });

  final bool isOpen;
  final List<ShoreReplyDrift> commentDrifts;
  final ShorelinePersona viewerPersona;
  final VoidCallback onClose;

  @override
  State<ReefCommentSheet> createState() => _ReefCommentSheetState();
}

class _ReefCommentSheetState extends State<ReefCommentSheet> {
  late List<ShoreReplyDrift> _visibleComments;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _visibleComments = List.of(widget.commentDrifts);
  }

  @override
  void didUpdateWidget(covariant ReefCommentSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentDrifts != widget.commentDrifts) {
      _visibleComments = List.of(widget.commentDrifts);
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.54;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      left: 0,
      right: 0,
      bottom: widget.isOpen ? 0 : -sheetHeight,
      height: sheetHeight,
      child: IgnorePointer(
        ignoring: !widget.isOpen,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                CoastinAssetRegistry.wavePanelBackdrop,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              top: 8,
              right: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onClose,
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: Color(0xFFFFFFFF),
                    size: 28,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 34, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    CoastinAssetRegistry.commentSectionWordmark,
                    width: 178,
                    height: 24,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _visibleComments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _ReefCommentRow(
                          commentDrift: _visibleComments[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _commentController,
                          placeholder: 'Please enter...',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF).withValues(
                              alpha: 0.94,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          style: const TextStyle(
                            color: TidewashPalette.inkBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _releaseComment,
                        child: SizedBox(
                          width: 84,
                          height: 44,
                          child: Image.asset(
                            CoastinAssetRegistry.commentButtonPlate,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _releaseComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _visibleComments.insert(
        0,
        ShoreReplyDrift(
          replyMarker: 'viewer-${DateTime.now().millisecondsSinceEpoch}',
          replyAuthor: widget.viewerPersona,
          tideMinute: 'now',
          replyText: text,
          hasFreshSignal: true,
        ),
      );
      _commentController.clear();
    });
  }
}

class _ReefCommentRow extends StatelessWidget {
  const _ReefCommentRow({required this.commentDrift});

  final ShoreReplyDrift commentDrift;

  @override
  Widget build(BuildContext context) {
    final genderGlyph =
        commentDrift.replyAuthor.profileCurrent == ShoreProfileCurrent.feminine
            ? CoastinAssetRegistry.feminineTideGlyph
            : CoastinAssetRegistry.masculineTideGlyph;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: Image.asset(
                commentDrift.replyAuthor.avatarAsset,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              right: -3,
              bottom: -2,
              child: Image.asset(genderGlyph, width: 16, height: 16),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      commentDrift.replyAuthor.displayHarborName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TidewashPalette.inkBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    commentDrift.tideMinute,
                    style: const TextStyle(
                      color: TidewashPalette.harborSlate,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (commentDrift.hasFreshSignal) ...[
                    const SizedBox(width: 6),
                    Image.asset(
                      CoastinAssetRegistry.aquaInfoGlyph,
                      width: 13,
                      height: 13,
                      fit: BoxFit.contain,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                commentDrift.replyText,
                style: const TextStyle(
                  color: TidewashPalette.inkBlue,
                  fontSize: 14,
                  height: 1.32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
