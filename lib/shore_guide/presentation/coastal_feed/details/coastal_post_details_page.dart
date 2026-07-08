import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/buddies/shore_system_notice_store.dart';
import '../../../data/local/safety/shore_safety_store.dart';
import '../../../data/local/seeded_shore_moment_deck.dart';
import '../../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../../domain/entities/shore_reply_drift.dart';
import '../../../domain/value_objects/shore_profile_current.dart';
import '../../people/shore_persona_detail_page.dart';
import '../../safety/shore_safety_action.dart';
import '../../safety/shore_safety_reef.dart';
import '../widgets/coastal_post_meta.dart';

class CoastalPostDetailsPage extends StatefulWidget {
  const CoastalPostDetailsPage({
    super.key,
    required this.postDispatch,
    required this.isLoved,
    required this.isFollowed,
    required this.onLoveChanged,
    required this.onFollowChanged,
    required this.onReplyCountChanged,
  });

  final CoastalPostDispatch postDispatch;
  final bool isLoved;
  final bool isFollowed;
  final ValueChanged<bool> onLoveChanged;
  final ValueChanged<bool> onFollowChanged;
  final ValueChanged<int> onReplyCountChanged;

  @override
  State<CoastalPostDetailsPage> createState() => _CoastalPostDetailsPageState();
}

class _CoastalPostDetailsPageState extends State<CoastalPostDetailsPage> {
  static const MethodChannel _shareChannel = MethodChannel('coastin/share');

  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  final ShoreSystemNoticeStore _noticeStore = const ShoreSystemNoticeStore();
  late bool _isLoved = widget.isLoved;
  late bool _isFollowed = widget.isFollowed;
  late final List<ShoreReplyDrift> _visibleReplies = List.of(
    widget.postDispatch.replyDrifts,
  );
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ShoreSafetyStore.safetyRevision.addListener(_handleSafetyRevision);
    _restoreSafety();
  }

  @override
  void dispose() {
    ShoreSafetyStore.safetyRevision.removeListener(_handleSafetyRevision);
    _replyController.dispose();
    super.dispose();
  }

  void _handleSafetyRevision() {
    _restoreSafety();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.postDispatch;
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
                          postDispatch: post,
                          isFollowed: _isFollowed,
                          onFollowTap: _toggleFollow,
                          onAuthorTap: _openAuthor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          post.captionCurrent,
                          style: const TextStyle(
                            color: TidewashPalette.inkBlue,
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailFrameStrip(
                          frameAssets: post.frameAssets,
                          onFrameTap: _openFramePreview,
                        ),
                        const SizedBox(height: 12),
                        _DetailActionRow(
                          isLoved: _isLoved,
                          heartCount: post.heartTally + (_isLoved ? 1 : 0),
                          replyCount: _visibleReplies.length,
                          relayTally: post.relayTally,
                          topicLabel: post.topicLabel,
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
                        for (final reply in _visibleReplies) ...[
                          _DetailReplyRow(
                            replyDrift: reply,
                            onPersonaTap: () => _openReplyAuthor(reply),
                            onReportTap: () => _reportReply(reply),
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
              child: _ReplyComposer(
                controller: _replyController,
                onSend: _sendReply,
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
    final handle = widget.postDispatch.authorHarbor.tideHandle;
    if (_isFollowed) {
      await _safetyStore.unfollow(handle);
    } else {
      await _safetyStore.follow(handle);
    }
    setState(() => _isFollowed = !_isFollowed);
    widget.onFollowChanged(_isFollowed);
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _visibleReplies.insert(
        0,
        ShoreReplyDrift(
          replyMarker: 'detail-${DateTime.now().microsecondsSinceEpoch}',
          replyAuthor: SeededShoreMomentDeck.shorelinePeople[36],
          tideMinute: 'now',
          replyText: text,
          hasFreshSignal: true,
        ),
      );
      _replyController.clear();
    });
    widget.onReplyCountChanged(_visibleReplies.length);
    _noticeStore.recordCommentNotice(
      actorHandle: widget.postDispatch.authorHarbor.tideHandle,
      noticeLine: 'Your comment was added under this Coastin post.',
    );
  }

  void _openAuthor() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: widget.postDispatch.authorHarbor,
          placeRibbon: widget.postDispatch.placeRibbon,
        ),
      ),
    );
  }

  void _openReplyAuthor(ShoreReplyDrift reply) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: reply.replyAuthor,
          placeRibbon: '23 - Australia',
        ),
      ),
    );
  }

  Future<void> _reportReply(ShoreReplyDrift reply) async {
    final outcome = await ShoreSafetyReef.showGuard(
      context: context,
      contentId: 'comment:${reply.replyMarker}',
      contentKind: ShoreSafetyContentKind.comment,
      ownerName: reply.replyAuthor.displayHarborName,
      ownerHandle: reply.replyAuthor.tideHandle,
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
        widget.postDispatch.authorHarbor.tideHandle,
      );
      _visibleReplies
        ..clear()
        ..addAll(
          widget.postDispatch.replyDrifts.where(
            (reply) => snapshot.isVisibleContent(
              'comment:${reply.replyMarker}',
              reply.replyAuthor.tideHandle,
            ),
          ),
        );
    });
    widget.onReplyCountChanged(_visibleReplies.length);
  }

  void _openFramePreview(int initialIndex) {
    showCupertinoModalPopup<void>(
      context: context,
      barrierColor: const Color(0xE6000000),
      builder: (context) {
        return _FramePreviewOverlay(
          frameAssets: widget.postDispatch.frameAssets,
          initialIndex: initialIndex,
        );
      },
    );
  }

  Future<void> _sharePost() async {
    final post = widget.postDispatch;
    final shareText =
        '${post.authorHarbor.displayHarborName} on Coastin\n'
        '${post.captionCurrent}\n'
        '${coastalPostOriginLine(post)} · ${post.topicLabel}';
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
      contentId: 'post:${widget.postDispatch.dispatchKey}',
      contentKind: ShoreSafetyContentKind.post,
      ownerName: widget.postDispatch.authorHarbor.displayHarborName,
      ownerHandle: widget.postDispatch.authorHarbor.tideHandle,
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
    required this.frameAssets,
    required this.initialIndex,
  });

  final List<String> frameAssets;
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
              itemCount: widget.frameAssets.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.asset(
                      widget.frameAssets[index],
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
            if (widget.frameAssets.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 42,
                child: Text(
                  '${_currentIndex + 1}/${widget.frameAssets.length}',
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
    required this.postDispatch,
    required this.isFollowed,
    required this.onFollowTap,
    required this.onAuthorTap,
  });

  final CoastalPostDispatch postDispatch;
  final bool isFollowed;
  final VoidCallback onFollowTap;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final author = postDispatch.authorHarbor;
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
                    postDispatch.clockRibbon,
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
                      coastalPostOriginLine(postDispatch),
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
    required this.frameAssets,
    required this.onFrameTap,
  });

  final List<String> frameAssets;
  final ValueChanged<int> onFrameTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < frameAssets.length; index++) ...[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onFrameTap(index),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    frameAssets[index],
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
          if (index != frameAssets.length - 1) const SizedBox(width: 7),
        ],
      ],
    );
  }
}

class _DetailActionRow extends StatelessWidget {
  const _DetailActionRow({
    required this.isLoved,
    required this.heartCount,
    required this.replyCount,
    required this.relayTally,
    required this.topicLabel,
    required this.onLoveTap,
    required this.onShareTap,
    required this.onMoreTap,
  });

  final bool isLoved;
  final int heartCount;
  final int replyCount;
  final int relayTally;
  final String topicLabel;
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
            topicLabel,
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
          count: replyCount,
        ),
        const SizedBox(width: 22),
        _DetailCountGlyph(
          asset: CoastinAssetRegistry.feedShareGlyph,
          count: relayTally,
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

class _DetailReplyRow extends StatelessWidget {
  const _DetailReplyRow({
    required this.replyDrift,
    required this.onPersonaTap,
    required this.onReportTap,
  });

  final ShoreReplyDrift replyDrift;
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
              replyDrift.replyAuthor.avatarAsset,
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
                        replyDrift.replyAuthor.displayHarborName,
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
                    replyDrift.tideMinute,
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
                replyDrift.replyText,
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

class _ReplyComposer extends StatelessWidget {
  const _ReplyComposer({required this.controller, required this.onSend});

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
