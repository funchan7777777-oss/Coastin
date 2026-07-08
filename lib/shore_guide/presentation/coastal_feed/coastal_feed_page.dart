import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../../shared/ui/tokens/shore_spacing.dart';
import '../../data/local/feed/coastal_dispatch_harbor_catalog.dart';
import '../../data/local/harbor_readiness_tide_catalog.dart';
import '../../data/local/safety/shore_safety_store.dart';
import '../../data/local/wallet/shore_shell_wallet_store.dart';
import '../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../domain/entities/feed/coastal_topic_lane.dart';
import '../moments/release/shore_release_page.dart';
import '../my_coast/wallet/shore_shell_reef.dart';
import '../people/shore_persona_detail_page.dart';
import '../safety/shore_safety_action.dart';
import '../safety/shore_safety_reef.dart';
import 'details/coastal_post_details_page.dart';
import 'guide/sun_guard_guide_page.dart';
import 'planner/cove_route_planner_page.dart';
import 'widgets/coastal_post_card.dart';
import 'widgets/coastal_post_meta.dart';

class CoastalFeedPage extends StatefulWidget {
  const CoastalFeedPage({super.key, required this.bottomDockClearance});

  final double bottomDockClearance;

  @override
  State<CoastalFeedPage> createState() => _CoastalFeedPageState();
}

class _CoastalFeedPageState extends State<CoastalFeedPage> {
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  final Map<String, bool> _lovedDispatches = {
    for (final post in CoastalDispatchHarborCatalog.coastalDispatches)
      post.shoreDispatchMarker: post.startsShellLiked,
  };
  final Map<String, int> _commentCounts = {
    for (final post in CoastalDispatchHarborCatalog.coastalDispatches)
      post.shoreDispatchMarker: coastalPostCommentCount(post),
  };
  ShoreSafetySnapshot _safetySnapshot = const ShoreSafetySnapshot(
    blockedHandles: {},
    reportedContentIds: {},
    followingHandles: {},
    approvedFollowerHandles: {},
  );

  String? _selectedTopicKey;

  List<CoastalPostDispatch> get _visibleDispatches {
    return CoastalDispatchHarborCatalog.coastalDispatches
        .where(
          (post) =>
              _selectedTopicKey == null ||
              post.tideTopicMarker == _selectedTopicKey,
        )
        .where(
          (post) => _safetySnapshot.isVisibleContent(
            'post:${post.shoreDispatchMarker}',
            post.shorelineKeeper.tideHandle,
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    ShoreSafetyStore.safetyRevision.addListener(_handleSafetyRevision);
    _restoreSafety();
  }

  @override
  void dispose() {
    ShoreSafetyStore.safetyRevision.removeListener(_handleSafetyRevision);
    super.dispose();
  }

  void _handleSafetyRevision() {
    _restoreSafety();
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
            const Positioned.fill(child: _CoastalFeedWash()),
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    ShoreSpacing.tideLg,
                    58,
                    ShoreSpacing.tideLg,
                    widget.bottomDockClearance + ShoreSpacing.tideLg,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _FeedHeader(onReleaseTap: _openPostRelease),
                      const SizedBox(height: 22),
                      _SunGuideBanner(onTap: _openSunGuide),
                      const SizedBox(height: 12),
                      _RoutePlannerBanner(onTap: _openRoutePlanner),
                      const SizedBox(height: 22),
                      _TopicShelf(
                        selectedTopicKey: _selectedTopicKey,
                        harborParticipationLines: _topicParticipationLines,
                        onTopicTap: _toggleTopic,
                      ),
                      const SizedBox(height: 20),
                      for (final post in _visibleDispatches)
                        CoastalPostCard(
                          shoreDispatch: post,
                          isLoved:
                              _lovedDispatches[post.shoreDispatchMarker] ??
                              false,
                          isFollowed: _safetySnapshot.isFollowing(
                            post.shorelineKeeper.tideHandle,
                          ),
                          commentCount:
                              _commentCounts[post.shoreDispatchMarker] ??
                              coastalPostCommentCount(post),
                          onOpen: () => _openPostDetails(post),
                          onLoveTap: () => _toggleLove(post),
                          onFollowTap: () => _toggleFollow(post),
                          onMoreTap: () => _showPostHarborMenu(post),
                          onAuthorTap: () => _openAuthor(post),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTopic(CoastalTopicLane topicLane) {
    setState(() {
      _selectedTopicKey = _selectedTopicKey == topicLane.tideTopicMarker
          ? null
          : topicLane.tideTopicMarker;
    });
  }

  void _toggleLove(CoastalPostDispatch post) {
    setState(() {
      _lovedDispatches[post.shoreDispatchMarker] =
          !(_lovedDispatches[post.shoreDispatchMarker] ?? false);
    });
  }

  Map<String, String> get _topicParticipationLines {
    return {
      for (final topicLane in CoastalDispatchHarborCatalog.topicLanes)
        topicLane.tideTopicMarker: _topicParticipationLine(
          topicLane.tideTopicMarker,
        ),
    };
  }

  String _topicParticipationLine(String tideTopicMarker) {
    final count = _topicParticipationCount(tideTopicMarker);
    return count == 1 ? '1 person' : '$count people';
  }

  int _topicParticipationCount(String tideTopicMarker) {
    final authorHandles = <String>{};
    var commentSignals = 0;
    var localLoveSignals = 0;
    var relaySignals = 0;

    for (final post in CoastalDispatchHarborCatalog.coastalDispatches) {
      if (post.tideTopicMarker != tideTopicMarker ||
          !_safetySnapshot.isVisibleContent(
            'post:${post.shoreDispatchMarker}',
            post.shorelineKeeper.tideHandle,
          )) {
        continue;
      }
      authorHandles.add(post.shorelineKeeper.tideHandle);
      commentSignals +=
          _commentCounts[post.shoreDispatchMarker] ??
          coastalPostCommentCount(post);
      if (_lovedDispatches[post.shoreDispatchMarker] == true) {
        localLoveSignals += 1;
      }
      relaySignals += post.shoreShareCount > 0 ? 1 : 0;
    }

    return authorHandles.length +
        commentSignals +
        localLoveSignals +
        relaySignals;
  }

  Future<void> _toggleFollow(CoastalPostDispatch post) async {
    final handle = post.shorelineKeeper.tideHandle;
    if (_safetySnapshot.isFollowing(handle)) {
      await _safetyStore.unfollow(handle);
    } else {
      await _safetyStore.follow(handle);
    }
    await _restoreSafety();
  }

  void _openPostRelease() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => const ShoreReleasePage(
          initialReleaseChannel: ShoreReleaseChannel.post,
        ),
      ),
    );
  }

  void _openPostDetails(CoastalPostDispatch post) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => CoastalPostDetailsPage(
          shoreDispatch: post,
          isLoved: _lovedDispatches[post.shoreDispatchMarker] ?? false,
          isFollowed: _safetySnapshot.isFollowing(
            post.shorelineKeeper.tideHandle,
          ),
          onLoveChanged: (isLoved) {
            setState(
              () => _lovedDispatches[post.shoreDispatchMarker] = isLoved,
            );
          },
          onFollowChanged: (_) => _restoreSafety(),
          onCommentCountChanged: (commentCount) {
            setState(
              () => _commentCounts[post.shoreDispatchMarker] = commentCount,
            );
          },
        ),
      ),
    );
  }

  Future<void> _openSunGuide() async {
    final canOpen = await ShoreShellReef.confirmAndSpend(
      context: context,
      expense: ShoreShellExpense.sunGuideAccess,
    );
    if (!canOpen || !mounted) {
      return;
    }
    Navigator.of(
      context,
    ).push(CupertinoPageRoute<void>(builder: (_) => const SunGuardGuidePage()));
  }

  Future<void> _openRoutePlanner() async {
    final canOpen = await ShoreShellReef.confirmAndSpend(
      context: context,
      expense: ShoreShellExpense.coveRoutePlanner,
    );
    if (!canOpen || !mounted) {
      return;
    }
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => const CoveRoutePlannerPage(
          harborBoard: HarborReadinessTideCatalog.pacificMorningBoard,
        ),
      ),
    );
  }

  void _openAuthor(CoastalPostDispatch post) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: post.shorelineKeeper,
          localApproachRibbon: post.localApproachRibbon,
        ),
      ),
    );
  }

  Future<void> _restoreSafety() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    if (!mounted) {
      return;
    }
    setState(() => _safetySnapshot = snapshot);
  }

  Future<void> _showPostHarborMenu(CoastalPostDispatch post) async {
    await ShoreSafetyReef.showGuard(
      context: context,
      contentId: 'post:${post.shoreDispatchMarker}',
      contentChannel: ShoreSafetyContentChannel.post,
      ownerName: post.shorelineKeeper.displayHarborName,
      ownerHandle: post.shorelineKeeper.tideHandle,
    );
    await _restoreSafety();
  }
}

class _CoastalFeedWash extends StatelessWidget {
  const _CoastalFeedWash();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF7DA),
            const Color(0xFFE9F7E7),
            const Color(0xFFBDF8F3).withValues(alpha: 0.96),
          ],
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.onReleaseTap});

  final VoidCallback onReleaseTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          CoastinAssetRegistry.coastalFeedWordmark,
          width: 168,
          height: 26,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onReleaseTap,
          child: SizedBox(
            width: 54,
            height: 40,
            child: Image.asset(
              CoastinAssetRegistry.postReleaseGlyph,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}

class _SunGuideBanner extends StatelessWidget {
  const _SunGuideBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              CoastinAssetRegistry.sunGuideBanner,
              width: double.infinity,
              height: 104,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            left: 18,
            bottom: 13,
            child: Image.asset(
              CoastinAssetRegistry.viewNowPill,
              width: 74,
              height: 25,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePlannerBanner extends StatelessWidget {
  const _RoutePlannerBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEFFFFB), Color(0xFFD7F0FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFEFE8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F68D3).withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2F68D3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.map,
                color: Color(0xFFFFFFFF),
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Cove route planner',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TidewashPalette.inkBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tune tide, shade, and cove pauses before you go.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TidewashPalette.harborSlate.withValues(
                        alpha: 0.76,
                      ),
                      fontSize: 12,
                      height: 1.22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '45 once',
                style: TextStyle(
                  color: Color(0xFF2F68D3),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicShelf extends StatelessWidget {
  const _TopicShelf({
    required this.selectedTopicKey,
    required this.harborParticipationLines,
    required this.onTopicTap,
  });

  final String? selectedTopicKey;
  final Map<String, String> harborParticipationLines;
  final ValueChanged<CoastalTopicLane> onTopicTap;

  @override
  Widget build(BuildContext context) {
    final topics = CoastalDispatchHarborCatalog.topicLanes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hot topic',
          style: TextStyle(
            color: TidewashPalette.inkBlue,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TopicCard(
                topicLane: topics[0],
                harborParticipationLine:
                    harborParticipationLines[topics[0].tideTopicMarker] ??
                    topics[0].harborParticipationLine,
                isSelected: selectedTopicKey == topics[0].tideTopicMarker,
                isLarge: true,
                onTap: () => onTopicTap(topics[0]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _TopicCard(
                    topicLane: topics[1],
                    harborParticipationLine:
                        harborParticipationLines[topics[1].tideTopicMarker] ??
                        topics[1].harborParticipationLine,
                    isSelected: selectedTopicKey == topics[1].tideTopicMarker,
                    onTap: () => onTopicTap(topics[1]),
                  ),
                  const SizedBox(height: 10),
                  _TopicCard(
                    topicLane: topics[2],
                    harborParticipationLine:
                        harborParticipationLines[topics[2].tideTopicMarker] ??
                        topics[2].harborParticipationLine,
                    isSelected: selectedTopicKey == topics[2].tideTopicMarker,
                    onTap: () => onTopicTap(topics[2]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topicLane,
    required this.harborParticipationLine,
    required this.isSelected,
    required this.onTap,
    this.isLarge = false,
  });

  final CoastalTopicLane topicLane;
  final String harborParticipationLine;
  final bool isSelected;
  final bool isLarge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(14);
    final borderColor = isSelected
        ? const Color(0xFF2F68D3)
        : const Color(0x00FFFFFF);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: isLarge ? 168 : 78,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Color(topicLane.topicWashTint),
          borderRadius: cardRadius,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: cardRadius,
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                topicLane.topicHarborCardAsset,
                fit: BoxFit.cover,
                alignment: isLarge ? Alignment.bottomCenter : Alignment.center,
                filterQuality: FilterQuality.high,
              ),
            ),
            if (isLarge) ...[
              Positioned(
                left: 14,
                top: 22,
                right: 12,
                child: Text(
                  topicLane.tideTopicLabel,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xFF2B333B),
                    fontSize: 16,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                left: 14,
                top: 60,
                child: _TopicPeopleBadge(
                  harborParticipationLine: harborParticipationLine,
                ),
              ),
            ] else
              Positioned(
                left: 12,
                top: 44,
                right: 68,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _TopicPeopleText(
                    harborParticipationLine: harborParticipationLine,
                  ),
                ),
              ),
            if (isLarge)
              Positioned(
                left: 16,
                bottom: 18,
                child: Image.asset(
                  CoastinAssetRegistry.topicArrowPill,
                  width: 48,
                  height: 30,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopicPeopleBadge extends StatelessWidget {
  const _TopicPeopleBadge({required this.harborParticipationLine});

  final String harborParticipationLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: _TopicPeopleText(harborParticipationLine: harborParticipationLine),
    );
  }
}

class _TopicPeopleText extends StatelessWidget {
  const _TopicPeopleText({required this.harborParticipationLine});

  final String harborParticipationLine;

  @override
  Widget build(BuildContext context) {
    return Text(
      harborParticipationLine,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: TidewashPalette.harborSlate.withValues(alpha: 0.58),
        fontSize: 10,
        height: 1,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
