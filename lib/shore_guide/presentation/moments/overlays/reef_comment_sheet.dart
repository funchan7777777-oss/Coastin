import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show TextInputAction;

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/buddies/shore_system_notice_store.dart';
import '../../../data/local/safety/shore_safety_store.dart';
import '../../../domain/entities/shore_reply_drift.dart';
import '../../../domain/entities/shoreline_persona.dart';
import '../../../domain/value_objects/shore_profile_current.dart';
import '../../people/shore_persona_detail_page.dart';
import '../../safety/shore_safety_action.dart';
import '../../safety/shore_safety_reef.dart';

class ReefCommentSheet extends StatefulWidget {
  const ReefCommentSheet({
    super.key,
    required this.isOpen,
    required this.commentDrifts,
    required this.viewerPersona,
    required this.bottomDockClearance,
    required this.onClose,
    required this.onChanged,
    required this.onVisibleCountChanged,
  });

  final bool isOpen;
  final List<ShoreReplyDrift> commentDrifts;
  final ShorelinePersona viewerPersona;
  final double bottomDockClearance;
  final VoidCallback onClose;
  final VoidCallback onChanged;
  final ValueChanged<int> onVisibleCountChanged;

  @override
  State<ReefCommentSheet> createState() => _ReefCommentSheetState();
}

class _ReefCommentSheetState extends State<ReefCommentSheet> {
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  final ShoreSystemNoticeStore _noticeStore = const ShoreSystemNoticeStore();
  late List<ShoreReplyDrift> _visibleComments;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _visibleComments = List.of(widget.commentDrifts);
    _restoreVisibleComments();
  }

  @override
  void didUpdateWidget(covariant ReefCommentSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commentDrifts != widget.commentDrifts) {
      _visibleComments = List.of(widget.commentDrifts);
      _commentController.clear();
      _restoreVisibleComments();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewportSize = MediaQuery.sizeOf(context);
    const sheetSize = Size(420, 522);
    final sheetWidth = viewportSize.width < sheetSize.width
        ? viewportSize.width
        : sheetSize.width;
    final sheetHeight = viewportSize.height < sheetSize.height
        ? viewportSize.height
        : sheetSize.height;
    const contentDrop = 28.0;
    final inputBottom = widget.bottomDockClearance + 10;
    const inputHeight = 46.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      left: (viewportSize.width - sheetWidth) / 2,
      bottom: widget.isOpen ? 0 : -sheetHeight,
      width: sheetWidth,
      height: sheetHeight,
      child: IgnorePointer(
        ignoring: !widget.isOpen,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.asset(
                CoastinAssetRegistry.wavePanelBackdrop,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              top: 38 + contentDrop,
              right: 38,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onClose,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.96),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF095B81).withValues(alpha: 0.24),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: Color(0xFF2F68D3),
                    size: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(34, 54 + contentDrop, 78, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    CoastinAssetRegistry.commentSectionWordmark,
                    width: 150,
                    height: 19,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 36,
              right: 36,
              top: 112 + contentDrop,
              bottom: inputBottom + inputHeight + 16,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _visibleComments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _ReefCommentRow(
                    commentDrift: _visibleComments[index],
                    onPersonaTap: () => _openPersona(_visibleComments[index]),
                    onReportTap: () => _reportComment(_visibleComments[index]),
                  );
                },
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: inputBottom,
              height: inputHeight,
              child: _CommentComposer(
                controller: _commentController,
                onSubmit: _releaseComment,
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
    widget.onVisibleCountChanged(_visibleComments.length);
    _noticeStore.recordCommentNotice(
      actorHandle: widget.viewerPersona.tideHandle,
      noticeLine: 'Your comment was added to the Coastin discussion.',
    );
  }

  Future<void> _restoreVisibleComments() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    if (!mounted) {
      return;
    }
    final visibleComments = widget.commentDrifts
        .where(
          (comment) => snapshot.isVisibleContent(
            'comment:${comment.replyMarker}',
            comment.replyAuthor.tideHandle,
          ),
        )
        .toList();
    setState(() {
      _visibleComments = visibleComments;
    });
    widget.onVisibleCountChanged(visibleComments.length);
  }

  void _openPersona(ShoreReplyDrift commentDrift) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: commentDrift.replyAuthor,
          placeRibbon: 'Shared shore note',
        ),
      ),
    );
  }

  Future<void> _reportComment(ShoreReplyDrift commentDrift) async {
    final outcome = await ShoreSafetyReef.showGuard(
      context: context,
      contentId: 'comment:${commentDrift.replyMarker}',
      contentKind: ShoreSafetyContentKind.comment,
      ownerName: commentDrift.replyAuthor.displayHarborName,
      ownerHandle: commentDrift.replyAuthor.tideHandle,
    );
    if (!mounted || outcome == null) {
      return;
    }
    setState(() {
      _visibleComments.removeWhere(
        (comment) => comment.replyMarker == commentDrift.replyMarker,
      );
    });
    widget.onVisibleCountChanged(_visibleComments.length);
    widget.onChanged();
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A6F84).withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Please enter...',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: const BoxDecoration(color: Color(0x00000000)),
              style: const TextStyle(
                color: TidewashPalette.inkBlue,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              placeholderStyle: TextStyle(
                color: TidewashPalette.harborSlate.withValues(alpha: 0.42),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSubmit,
            child: SizedBox(
              width: 72,
              height: 44,
              child: Image.asset(
                CoastinAssetRegistry.commentButtonPlate,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _ReefCommentRow extends StatelessWidget {
  const _ReefCommentRow({
    required this.commentDrift,
    required this.onPersonaTap,
    required this.onReportTap,
  });

  final ShoreReplyDrift commentDrift;
  final VoidCallback onPersonaTap;
  final VoidCallback onReportTap;

  @override
  Widget build(BuildContext context) {
    final genderGlyph =
        commentDrift.replyAuthor.profileCurrent == ShoreProfileCurrent.feminine
        ? CoastinAssetRegistry.feminineTideGlyph
        : CoastinAssetRegistry.masculineTideGlyph;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPersonaTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  commentDrift.replyAuthor.avatarAsset,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                right: -3,
                bottom: -2,
                child: Image.asset(genderGlyph, width: 14, height: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onPersonaTap,
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
                  ),
                  const SizedBox(width: 6),
                  Text(
                    commentDrift.tideMinute,
                    style: TextStyle(
                      color: TidewashPalette.harborSlate.withValues(
                        alpha: 0.64,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onReportTap,
                    child: Image.asset(
                      CoastinAssetRegistry.aquaInfoGlyph,
                      width: 14,
                      height: 14,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                commentDrift.replyText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: TidewashPalette.inkBlue,
                  fontSize: 13,
                  height: 1.24,
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
