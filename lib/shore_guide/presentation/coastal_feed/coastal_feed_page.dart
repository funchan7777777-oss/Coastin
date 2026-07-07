import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../../shared/ui/tokens/shore_spacing.dart';
import '../../data/local/feed/seeded_coastal_feed_deck.dart';
import '../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../domain/entities/feed/coastal_topic_lane.dart';
import '../moments/release/shore_release_page.dart';
import 'details/coastal_post_details_page.dart';
import 'guide/sun_guard_guide_page.dart';
import 'widgets/coastal_post_card.dart';

class CoastalFeedPage extends StatefulWidget {
  const CoastalFeedPage({super.key, required this.bottomDockClearance});

  final double bottomDockClearance;

  @override
  State<CoastalFeedPage> createState() => _CoastalFeedPageState();
}

class _CoastalFeedPageState extends State<CoastalFeedPage> {
  final Map<String, bool> _lovedDispatches = {
    for (final post in SeededCoastalFeedDeck.coastalDispatches)
      post.dispatchKey: post.isInitiallyLoved,
  };
  final Map<String, bool> _followedAuthors = {
    for (final post in SeededCoastalFeedDeck.coastalDispatches)
      post.authorHarbor.tideHandle: post.isInitiallyFollowed,
  };

  String? _selectedTopicKey;

  List<CoastalPostDispatch> get _visibleDispatches {
    if (_selectedTopicKey == null) {
      return SeededCoastalFeedDeck.coastalDispatches;
    }
    return SeededCoastalFeedDeck.coastalDispatches
        .where((post) => post.topicKey == _selectedTopicKey)
        .toList();
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
                      const SizedBox(height: 22),
                      _TopicShelf(
                        selectedTopicKey: _selectedTopicKey,
                        onTopicTap: _toggleTopic,
                      ),
                      const SizedBox(height: 20),
                      for (final post in _visibleDispatches)
                        CoastalPostCard(
                          postDispatch: post,
                          isLoved: _lovedDispatches[post.dispatchKey] ?? false,
                          isFollowed:
                              _followedAuthors[post.authorHarbor.tideHandle] ??
                              false,
                          onOpen: () => _openPostDetails(post),
                          onLoveTap: () => _toggleLove(post),
                          onFollowTap: () => _toggleFollow(post),
                          onMoreTap: () => _showPostHarborMenu(post),
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
      _selectedTopicKey = _selectedTopicKey == topicLane.laneKey
          ? null
          : topicLane.laneKey;
    });
  }

  void _toggleLove(CoastalPostDispatch post) {
    setState(() {
      _lovedDispatches[post.dispatchKey] =
          !(_lovedDispatches[post.dispatchKey] ?? false);
    });
  }

  void _toggleFollow(CoastalPostDispatch post) {
    setState(() {
      final handle = post.authorHarbor.tideHandle;
      _followedAuthors[handle] = !(_followedAuthors[handle] ?? false);
    });
  }

  void _openPostRelease() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) =>
            const ShoreReleasePage(initialReleaseKind: ShoreReleaseKind.post),
      ),
    );
  }

  void _openPostDetails(CoastalPostDispatch post) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => CoastalPostDetailsPage(
          postDispatch: post,
          isLoved: _lovedDispatches[post.dispatchKey] ?? false,
          isFollowed: _followedAuthors[post.authorHarbor.tideHandle] ?? false,
          onLoveChanged: (isLoved) {
            setState(() => _lovedDispatches[post.dispatchKey] = isLoved);
          },
          onFollowChanged: (isFollowed) {
            setState(
              () => _followedAuthors[post.authorHarbor.tideHandle] = isFollowed,
            );
          },
        ),
      ),
    );
  }

  void _openSunGuide() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute<void>(builder: (_) => const SunGuardGuidePage()));
  }

  void _showPostHarborMenu(CoastalPostDispatch post) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(post.authorHarbor.displayHarborName),
          message: Text(post.authorHarbor.coastalStamp),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _openPostDetails(post);
              },
              child: const Text('View details'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _toggleFollow(post);
              },
              child: Text(
                (_followedAuthors[post.authorHarbor.tideHandle] ?? false)
                    ? 'Unfollow'
                    : 'Follow creator',
              ),
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

class _TopicShelf extends StatelessWidget {
  const _TopicShelf({required this.selectedTopicKey, required this.onTopicTap});

  final String? selectedTopicKey;
  final ValueChanged<CoastalTopicLane> onTopicTap;

  @override
  Widget build(BuildContext context) {
    final topics = SeededCoastalFeedDeck.topicLanes;
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
                isSelected: selectedTopicKey == topics[0].laneKey,
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
                    isSelected: selectedTopicKey == topics[1].laneKey,
                    onTap: () => onTopicTap(topics[1]),
                  ),
                  const SizedBox(height: 10),
                  _TopicCard(
                    topicLane: topics[2],
                    isSelected: selectedTopicKey == topics[2].laneKey,
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
    required this.isSelected,
    required this.onTap,
    this.isLarge = false,
  });

  final CoastalTopicLane topicLane;
  final bool isSelected;
  final bool isLarge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: isLarge ? 168 : 78,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Color(topicLane.highlightTint),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F68D3)
                : const Color(0x00FFFFFF),
            width: 1.4,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                topicLane.topicCardAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
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
