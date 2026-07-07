import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../../domain/value_objects/shore_profile_current.dart';

class CoastalPostCard extends StatelessWidget {
  const CoastalPostCard({
    super.key,
    required this.postDispatch,
    required this.isLoved,
    required this.isFollowed,
    required this.onOpen,
    required this.onLoveTap,
    required this.onFollowTap,
    required this.onMoreTap,
    required this.onAuthorTap,
  });

  final CoastalPostDispatch postDispatch;
  final bool isLoved;
  final bool isFollowed;
  final VoidCallback onOpen;
  final VoidCallback onLoveTap;
  final VoidCallback onFollowTap;
  final VoidCallback onMoreTap;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final adjustedHeart =
        postDispatch.heartTally +
        (isLoved == postDispatch.isInitiallyLoved
            ? 0
            : isLoved
            ? 1
            : -1);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuthorRow(
              postDispatch: postDispatch,
              isFollowed: isFollowed,
              onFollowTap: onFollowTap,
              onAuthorTap: onAuthorTap,
            ),
            const SizedBox(height: 12),
            Text(
              postDispatch.captionCurrent,
              style: const TextStyle(
                color: TidewashPalette.inkBlue,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _PostFrameGrid(frameAssets: postDispatch.frameAssets),
            const SizedBox(height: 12),
            Row(
              children: [
                _TopicPill(topicLabel: postDispatch.topicLabel),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLoveTap,
                  child: Image.asset(
                    isLoved
                        ? CoastinAssetRegistry.feedHeartFilled
                        : CoastinAssetRegistry.feedHeartOutline,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _ActionCountRow(
              heartCount: adjustedHeart,
              replyCount: postDispatch.replyTally,
              relayCount: postDispatch.relayTally,
              onMoreTap: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -3,
                child: Image.asset(genderGlyph, width: 17, height: 17),
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
                  const SizedBox(width: 8),
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
                    size: 14,
                    color: Color(0xFFFF62AC),
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
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onFollowTap,
          child: SizedBox(
            width: 68,
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

class _PostFrameGrid extends StatelessWidget {
  const _PostFrameGrid({required this.frameAssets});

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
          if (index != frameAssets.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _TopicPill extends StatelessWidget {
  const _TopicPill({required this.topicLabel});

  final String topicLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4C8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.circle_grid_hex_fill,
            size: 13,
            color: Color(0xFFE9A72D),
          ),
          const SizedBox(width: 4),
          Text(
            topicLabel,
            style: const TextStyle(
              color: Color(0xFFE9A72D),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCountRow extends StatelessWidget {
  const _ActionCountRow({
    required this.heartCount,
    required this.replyCount,
    required this.relayCount,
    required this.onMoreTap,
  });

  final int heartCount;
  final int replyCount;
  final int relayCount;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FeedActionCount(
          asset: CoastinAssetRegistry.feedHeartOutline,
          count: heartCount,
        ),
        const SizedBox(width: 26),
        _FeedActionCount(
          asset: CoastinAssetRegistry.feedCommentGlyph,
          count: replyCount,
        ),
        const SizedBox(width: 26),
        _FeedActionCount(
          asset: CoastinAssetRegistry.feedShareGlyph,
          count: relayCount,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onMoreTap,
          child: Image.asset(
            CoastinAssetRegistry.feedMoreGlyph,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ],
    );
  }
}

class _FeedActionCount extends StatelessWidget {
  const _FeedActionCount({required this.asset, required this.count});

  final String asset;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          asset,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
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
    );
  }
}
