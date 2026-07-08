import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/buddies/shore_system_notice_store.dart';
import '../../../data/local/safety/shore_safety_store.dart';
import '../../../data/local/shore_moment_harbor_catalog.dart';
import '../../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../../domain/entities/shore_comment_tide_mark.dart';
import '../../../domain/value_objects/shore_content_safety_gate.dart';
import '../../../domain/value_objects/shore_profile_current.dart';
import '../../people/shore_persona_detail_page.dart';
import '../../safety/shore_safety_action.dart';
import '../../safety/shore_safety_reef.dart';
import '../widgets/coastal_post_meta.dart';

class CoastalPostDetailsPage extends StatefulWidget {
  const CoastalPostDetailsPage({
    super.key,
    required this.shoreDispatch,
    required this.isLoved,
    required this.isFollowed,
    required this.onLoveChanged,
    required this.onFollowChanged,
    required this.onCommentCountChanged,
  });

  final CoastalPostDispatch shoreDispatch;
  final bool isLoved;
  final bool isFollowed;
  final ValueChanged<bool> onLoveChanged;
  final ValueChanged<bool> onFollowChanged;
  final ValueChanged<int> onCommentCountChanged;

  @override
  State<CoastalPostDetailsPage> createState() => _CoastalPostDetailsPageState();
}

class _CoastalPostDetailsPageState extends State<CoastalPostDetailsPage> {
  static const MethodChannel _shareChannel = MethodChannel('coastin/share');

  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  final ShoreSystemNoticeStore _noticeStore = const ShoreSystemNoticeStore();
  late bool _isLoved = widget.isLoved;
  late bool _isFollowed = widget.isFollowed;
  late final List<ShoreCommentTideMark> _visibleCommentTideMarks = List.of(
    widget.shoreDispatch.commentTideMarks,
  );
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ShoreSafetyStore.safetyRevision.addListener(_handleSafetyRevision);
    _restoreSafety();
  }

  @override
  void dispose() {
    ShoreSafetyStore.safetyRevision.removeListener(_handleSafetyRevision);
    _commentController.dispose();
    super.dispose();
  }

  void _handleSafetyRevision() {
    _restoreSafety();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.shoreDispatch;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFDF7DC),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            const Positioned.fill(child: _DetailWash()),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 122),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailTopBar(
                          onBack: () => Navigator.of(context).pop(),
                          onInfo: _showPostInfo,
                        ),
                        const SizedBox(height: 26),
                        _DetailAuthorRow(
                          shoreDispatch: post,
                          isFollowed: _isFollowed,
                          onFollowTap: _toggleFollow,
                          onAuthorTap: _openAuthor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          post.shorelineCaption,
                          style: const TextStyle(
                            color: TidewashPalette.inkBlue,
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailFrameStrip(
                          shorelineFrameAssets: post.shorelineFrameAssets,
                          onFrameTap: _openFramePreview,
                        ),
                        const SizedBox(height: 12),
                        _DetailActionRow(
                          isLoved: _isLoved,
                          heartCount: post.shellLikeCount + (_isLoved ? 1 : 0),
                          commentCount: _visibleCommentTideMarks.length,
                          shoreShareCount: post.shoreShareCount,
                          tideTopicLabel: post.tideTopicLabel,
                          onLoveTap: _toggleLove,
                          onShareTap: _sharePost,
                          onMoreTap: _showPostInfo,
                        ),
                        const SizedBox(height: 26),
                        Image.asset(
                          CoastinAssetRegistry.commentSectionWordmark,
                          width: 188,
                          height: 26,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 18),
                        for (final commentTideMark in _visibleCommentTideMarks) ...[
                          _DetailCommentRow(
                            commentTideMark: commentTideMark,
                            onPersonaTap: () => _openCommentHarbor(commentTideMark),
                            onReportTap: () => _reportComment(commentTideMark),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: _CommentComposer(
                controller: _commentController,
                onSend: _sendComment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLove() {
    setState(() => _isLoved = !_isLoved);
    widget.onLoveChanged(_isLoved);
  }

  Future<void> _toggleFollow() async {
    final handle = widget.shoreDispatch.shorelineKeeper.tideHandle;
    if (_isFollowed) {
      await _safetyStore.unfollow(handle);
    } else {
      await _safetyStore.follow(handle);
    }
    setState(() => _isFollowed = !_isFollowed);
    widget.onFollowChanged(_isFollowed);
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final safetyDecision = ShoreContentSafetyGate.inspect(
      text,
      surface: ShoreContentSurface.publicComment,
    );
    if (!safetyDecision.isAllowed) {
      await ShoreSafetyReef.showAccountDone(
        context: context,
        title: safetyDecision.title,
        message: safetyDecision.message,
      );
      return;
    }
    setState(() {
      _visibleCommentTideMarks.insert(
        0,
        ShoreCommentTideMark(
          commentMarker: 'detail-${DateTime.now().microsecondsSinceEpoch}',
          commentHarbor: ShoreMomentHarborCatalog.shorelinePeople[36],
          commentClock: 'now',
          commentText: text,
          hasFreshSignal: true,
        ),
      );
      _commentController.clear();
    });
    widget.onCommentCountChanged(_visibleCommentTideMarks.length);
    _noticeStore.recordCommentNotice(
      actorHandle: widget.shoreDispatch.shorelineKeeper.tideHandle,
      noticeLine: 'Your comment was added under this Coastin post.',
    );
  }

  void _openAuthor() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: widget.shoreDispatch.shorelineKeeper,
          localApproachRibbon: widget.shoreDispatch.localApproachRibbon,
        ),
      ),
    );
  }

  void _openCommentHarbor(ShoreCommentTideMark commentTideMark) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: commentTideMark.commentHarbor,
          localApproachRibbon: '23 - Australia',
        ),
      ),
    );
  }

  Future<void> _reportComment(ShoreCommentTideMark commentTideMark) async {
    final outcome = await ShoreSafetyReef.showGuard(
      context: context,
      contentId: 'comment:${commentTideMark.commentMarker}',
      contentChannel: ShoreSafetyContentChannel.comment,
      ownerName: commentTideMark.commentHarbor.displayHarborName,
      ownerHandle: commentTideMark.commentHarbor.tideHandle,
    );
    if (!mounted || outcome == null) {
      return;
    }
    await _restoreSafety();
  }

  Future<void> _restoreSafety() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _isFollowed = snapshot.isFollowing(
        widget.shoreDispatch.shorelineKeeper.tideHandle,
      );
      _visibleCommentTideMarks
        ..clear()
        ..addAll(
          widget.shoreDispatch.commentTideMarks.where(
            (commentTideMark) => snapshot.isVisibleContent(
              'comment:${commentTideMark.commentMarker}',
              commentTideMark.commentHarbor.tideHandle,
            ),
          ),
        );
    });
    widget.onCommentCountChanged(_visibleCommentTideMarks.length);
  }

  void _openFramePreview(int initialIndex) {
    showCupertinoModalPopup<void>(
      context: context,
      barrierColor: const Color(0xE6000000),
      builder: (context) {
        return _FramePreviewOverlay(
          shorelineFrameAssets: widget.shoreDispatch.shorelineFrameAssets,
          initialIndex: initialIndex,
        );
      },
    );
  }

  Future<void> _sharePost() async {
    final post = widget.shoreDispatch;
    final shareText =
        '${post.shorelineKeeper.displayHarborName} on Coastin\n'
        '${post.shorelineCaption}\n'
        '${coastalPostOriginLine(post)} · ${post.tideTopicLabel}';
    try {
      await _shareChannel.invokeMethod<void>('shareText', {'text': shareText});
    } catch (_) {
      if (!mounted) {
        return;
      }
      await ShoreSafetyReef.showAccountDone(
        context: context,
        title: 'Share unavailable',
        message:
            'The system share sheet could not open right now. Please try again later.',
      );
    }
  }

  Future<void> _showPostInfo() async {
    final outcome = await ShoreSafetyReef.showGuard(
      context: context,
      contentId: 'post:${widget.shoreDispatch.shoreDispatchMarker}',
      contentChannel: ShoreSafetyContentChannel.post,
      ownerName: widget.shoreDispatch.shorelineKeeper.displayHarborName,
      ownerHandle: widget.shoreDispatch.shorelineKeeper.tideHandle,
    );
    if (!mounted || outcome == null) {
      return;
    }
    await _restoreSafety();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _DetailWash extends StatelessWidget {
  const _DetailWash();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF7DA),
            const Color(0xFFEAF8E5),
            const Color(0xFFC4F8F1).withValues(alpha: 0.98),
          ],
        ),
      ),
    );
  }
}

class _FramePreviewOverlay extends StatefulWidget {
  const _FramePreviewOverlay({
    required this.shorelineFrameAssets,
    required this.initialIndex,
  });

  final List<String> shorelineFrameAssets;
  final int initialIndex;

  @override
  State<_FramePreviewOverlay> createState() => _FramePreviewOverlayState();
}

class _FramePreviewOverlayState extends State<_FramePreviewOverlay> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: const Color(0xF2000000),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.shorelineFrameAssets.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.asset(
                      widget.shorelineFrameAssets[index],
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 18,
              top: 54,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.28),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: Color(0xFFFFFFFF),
                    size: 22,
                  ),
                ),
              ),
            ),
            if (widget.shorelineFrameAssets.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 42,
                child: Text(
                  '${_currentIndex + 1}/${widget.shorelineFrameAssets.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({required this.onBack, required this.onInfo});

  final VoidCallback onBack;
  final VoidCallback onInfo;

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
              size: 28,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onInfo,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: Image.asset(
                CoastinAssetRegistry.aquaInfoGlyph,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailAuthorRow extends StatelessWidget {
  const _DetailAuthorRow({
    required this.shoreDispatch,
    required this.isFollowed,
    required this.onFollowTap,
    required this.onAuthorTap,
  });

  final CoastalPostDispatch shoreDispatch;
  final bool isFollowed;
  final VoidCallback onFollowTap;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final author = shoreDispatch.shorelineKeeper;
    final genderGlyph = author.profileCurrent == ShoreProfileCurrent.feminine
        ? CoastinAssetRegistry.feminineTideGlyph
        : CoastinAssetRegistry.masculineTideGlyph;

    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onAuthorTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  author.avatarAsset,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -3,
                child: Image.asset(genderGlyph, width: 18, height: 18),
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
                      onTap: onAuthorTap,
                      child: Text(
                        author.displayHarborName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TidewashPalette.inkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    shoreDispatch.postedAtRibbon,
                    style: const TextStyle(
                      color: TidewashPalette.harborSlate,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.location_solid,
                    color: Color(0xFFFF62AC),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      coastalPostOriginLine(shoreDispatch),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF22A9D8),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onFollowTap,
          child: SizedBox(
            width: 72,
            height: 30,
            child: Image.asset(
              isFollowed
                  ? CoastinAssetRegistry.followedBadge
                  : CoastinAssetRegistry.followBadge,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailFrameStrip extends StatelessWidget {
  const _DetailFrameStrip({
    required this.shorelineFrameAssets,
    required this.onFrameTap,
  });

  final List<String> shorelineFrameAssets;
  final ValueChanged<int> onFrameTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < shorelineFrameAssets.length; index++) ...[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onFrameTap(index),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    shorelineFrameAssets[index],
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
          if (index != shorelineFrameAssets.length - 1) const SizedBox(width: 7),
        ],
      ],
    );
  }
}

class _DetailActionRow extends StatelessWidget {
  const _DetailActionRow({
    required this.isLoved,
    required this.heartCount,
    required this.commentCount,
    required this.shoreShareCount,
    required this.tideTopicLabel,
    required this.onLoveTap,
    required this.onShareTap,
    required this.onMoreTap,
  });

  final bool isLoved;
  final int heartCount;
  final int commentCount;
  final int shoreShareCount;
  final String tideTopicLabel;
  final VoidCallback onLoveTap;
  final VoidCallback onShareTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4C8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            tideTopicLabel,
            style: const TextStyle(
              color: Color(0xFFE9A72D),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Spacer(),
        _DetailCountGlyph(
          asset: isLoved
              ? CoastinAssetRegistry.feedHeartFilled
              : CoastinAssetRegistry.feedHeartOutline,
          count: heartCount,
          onTap: onLoveTap,
        ),
        const SizedBox(width: 22),
        _DetailCountGlyph(
          asset: CoastinAssetRegistry.feedCommentGlyph,
          count: commentCount,
        ),
        const SizedBox(width: 22),
        _DetailCountGlyph(
          asset: CoastinAssetRegistry.feedShareGlyph,
          count: shoreShareCount,
          onTap: onShareTap,
        ),
        const SizedBox(width: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onMoreTap,
          child: Image.asset(
            CoastinAssetRegistry.feedMoreGlyph,
            width: 21,
            height: 21,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _DetailCountGlyph extends StatelessWidget {
  const _DetailCountGlyph({
    required this.asset,
    required this.count,
    this.onTap,
  });

  final String asset;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, width: 20, height: 20, fit: BoxFit.contain),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: const TextStyle(
              color: TidewashPalette.harborSlate,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCommentRow extends StatelessWidget {
  const _DetailCommentRow({
    required this.commentTideMark,
    required this.onPersonaTap,
    required this.onReportTap,
  });

  final ShoreCommentTideMark commentTideMark;
  final VoidCallback onPersonaTap;
  final VoidCallback onReportTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPersonaTap,
          child: ClipOval(
            child: Image.asset(
              commentTideMark.commentHarbor.avatarAsset,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
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
                        commentTideMark.commentHarbor.displayHarborName,
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
                  Text(
                    commentTideMark.commentClock,
                    style: const TextStyle(
                      color: TidewashPalette.harborSlate,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onReportTap,
                    child: const Icon(
                      CupertinoIcons.exclamationmark_circle,
                      color: Color(0xFF41C7D2),
                      size: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                commentTideMark.commentText,
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

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Please enter...',
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(24),
            ),
            style: const TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSend,
          child: SizedBox(
            width: 82,
            height: 44,
            child: Image.asset(
              CoastinAssetRegistry.commentButtonPlate,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}
