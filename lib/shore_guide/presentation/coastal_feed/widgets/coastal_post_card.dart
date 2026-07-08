import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../../domain/value_objects/shore_profile_current.dart';
import 'coastal_post_meta.dart';

class CoastalPostCard extends StatelessWidget {
  const CoastalPostCard({
    super.key,
    required this.shoreDispatch,
    required this.isLoved,
    required this.isFollowed,
    required this.commentCount,
    required this.onOpen,
    required this.onLoveTap,
    required this.onFollowTap,
    required this.onMoreTap,
    required this.onAuthorTap,
  });

  final CoastalPostDispatch shoreDispatch;
  final bool isLoved;
  final bool isFollowed;
  final int commentCount;
  final VoidCallback onOpen;
  final VoidCallback onLoveTap;
  final VoidCallback onFollowTap;
  final VoidCallback onMoreTap;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final adjustedHeart = shoreDispatch.shellLikeCount + (isLoved ? 1 : 0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuthorRow(
              shoreDispatch: shoreDispatch,
              isFollowed: isFollowed,
              onFollowTap: onFollowTap,
              onAuthorTap: onAuthorTap,
            ),
            const SizedBox(height: 12),
            Text(
              shoreDispatch.shorelineCaption,
              style: const TextStyle(
                color: TidewashPalette.inkBlue,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _PostFrameGrid(
              shorelineFrameAssets: shoreDispatch.shorelineFrameAssets,
            ),
            const SizedBox(height: 12),
            _TopicPill(tideTopicLabel: shoreDispatch.tideTopicLabel),
            const SizedBox(height: 10),
            _ActionCountRow(
              isLoved: isLoved,
              heartCount: adjustedHeart,
              commentCount: commentCount,
              relayCount: shoreDispatch.shoreShareCount,
              onLoveTap: onLoveTap,
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
                    size: 14,
                    color: Color(0xFFFF62AC),
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
  const _PostFrameGrid({required this.shorelineFrameAssets});

  final List<String> shorelineFrameAssets;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < shorelineFrameAssets.length; index++) ...[
          Expanded(
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
          if (index != shorelineFrameAssets.length - 1)
            const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _TopicPill extends StatelessWidget {
  const _TopicPill({required this.tideTopicLabel});

  final String tideTopicLabel;

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
            tideTopicLabel,
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
    required this.isLoved,
    required this.heartCount,
    required this.commentCount,
    required this.relayCount,
    required this.onLoveTap,
    required this.onMoreTap,
  });

  final bool isLoved;
  final int heartCount;
  final int commentCount;
  final int relayCount;
  final VoidCallback onLoveTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FeedActionCount(
          asset: isLoved
              ? CoastinAssetRegistry.feedHeartFilled
              : CoastinAssetRegistry.feedHeartOutline,
          count: heartCount,
          onTap: onLoveTap,
        ),
        const SizedBox(width: 26),
        _FeedActionCount(
          asset: CoastinAssetRegistry.feedCommentGlyph,
          count: commentCount,
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
  const _FeedActionCount({
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
      ),
    );
  }
}
