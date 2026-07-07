import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/seeded_shore_moment_deck.dart';
import '../../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../../domain/entities/shore_reply_drift.dart';
import '../../../domain/value_objects/shore_profile_current.dart';

class CoastalPostDetailsPage extends StatefulWidget {
  const CoastalPostDetailsPage({
    super.key,
    required this.postDispatch,
    required this.isLoved,
    required this.isFollowed,
    required this.onLoveChanged,
    required this.onFollowChanged,
  });

  final CoastalPostDispatch postDispatch;
  final bool isLoved;
  final bool isFollowed;
  final ValueChanged<bool> onLoveChanged;
  final ValueChanged<bool> onFollowChanged;

  @override
  State<CoastalPostDetailsPage> createState() => _CoastalPostDetailsPageState();
}

class _CoastalPostDetailsPageState extends State<CoastalPostDetailsPage> {
  late bool _isLoved = widget.isLoved;
  late bool _isFollowed = widget.isFollowed;
  late final List<ShoreReplyDrift> _visibleReplies = List.of(
    widget.postDispatch.replyDrifts,
  );
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
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
                        _DetailFrameStrip(frameAssets: post.frameAssets),
                        const SizedBox(height: 12),
                        _DetailActionRow(
                          isLoved: _isLoved,
                          heartTally: post.heartTally,
                          replyTally: post.replyTally,
                          relayTally: post.relayTally,
                          topicLabel: post.topicLabel,
                          onLoveTap: _toggleLove,
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
                          _DetailReplyRow(replyDrift: reply),
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

  void _toggleFollow() {
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
  }

  void _showPostInfo() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(widget.postDispatch.topicLabel),
          message: Text(widget.postDispatch.authorHarbor.coastalStamp),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save post'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Report post'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
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
  });

  final CoastalPostDispatch postDispatch;
  final bool isFollowed;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final author = postDispatch.authorHarbor;
    final genderGlyph = author.profileCurrent == ShoreProfileCurrent.feminine
        ? CoastinAssetRegistry.feminineTideGlyph
        : CoastinAssetRegistry.masculineTideGlyph;

    return Row(
      children: [
        Stack(
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
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
                      postDispatch.placeRibbon,
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
  const _DetailFrameStrip({required this.frameAssets});

  final List<String> frameAssets;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < frameAssets.length; index++) ...[
          Expanded(
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
          if (index != frameAssets.length - 1) const SizedBox(width: 7),
        ],
      ],
    );
  }
}

class _DetailActionRow extends StatelessWidget {
  const _DetailActionRow({
    required this.isLoved,
    required this.heartTally,
    required this.replyTally,
    required this.relayTally,
    required this.topicLabel,
    required this.onLoveTap,
  });

  final bool isLoved;
  final int heartTally;
  final int replyTally;
  final int relayTally;
  final String topicLabel;
  final VoidCallback onLoveTap;

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
          count: heartTally,
          onTap: onLoveTap,
        ),
        const SizedBox(width: 22),
        _DetailCountGlyph(
          asset: CoastinAssetRegistry.feedCommentGlyph,
          count: replyTally,
        ),
        const SizedBox(width: 22),
        _DetailCountGlyph(
          asset: CoastinAssetRegistry.feedShareGlyph,
          count: relayTally,
        ),
        const SizedBox(width: 12),
        Image.asset(
          CoastinAssetRegistry.feedMoreGlyph,
          width: 21,
          height: 21,
          fit: BoxFit.contain,
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
  const _DetailReplyRow({required this.replyDrift});

  final ShoreReplyDrift replyDrift;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.asset(
            replyDrift.replyAuthor.avatarAsset,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
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
                  Text(
                    replyDrift.tideMinute,
                    style: const TextStyle(
                      color: TidewashPalette.harborSlate,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (replyDrift.hasFreshSignal) ...[
                    const SizedBox(width: 5),
                    Image.asset(
                      CoastinAssetRegistry.aquaInfoGlyph,
                      width: 13,
                      height: 13,
                    ),
                  ],
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
