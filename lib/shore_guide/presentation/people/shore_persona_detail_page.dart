import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../../shared/ui/coastin_empty_state.dart';
import '../../data/local/buddies/sea_buddy_message_store.dart';
import '../../data/local/feed/coastal_dispatch_harbor_catalog.dart';
import '../../data/local/safety/shore_safety_store.dart';
import '../../data/local/shore_moment_harbor_catalog.dart';
import '../../data/local/shore_persona_catalog.dart';
import '../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../domain/entities/shore_video_moment.dart';
import '../../domain/entities/shoreline_persona.dart';
import '../../domain/value_objects/coastin_country_label.dart';
import '../../domain/value_objects/shore_profile_current.dart';
import '../coastal_feed/details/coastal_post_details_page.dart';
import '../moments/share_moments_page.dart';
import '../sea_buddies/call/sea_buddy_call_page.dart';
import '../sea_buddies/chat/sea_buddy_chat_page.dart';
import '../safety/shore_safety_action.dart';
import '../safety/shore_safety_reef.dart';

class ShorePersonaDetailPage extends StatefulWidget {
  const ShorePersonaDetailPage({
    super.key,
    required this.persona,
    this.localApproachRibbon,
  });

  final ShorelinePersona persona;
  final String? localApproachRibbon;

  @override
  State<ShorePersonaDetailPage> createState() => _ShorePersonaDetailPageState();
}

class _ShorePersonaDetailPageState extends State<ShorePersonaDetailPage> {
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  final SeaBuddyMessageStore _messageStore = const SeaBuddyMessageStore();
  final Map<String, bool> _lovedDispatches = {
    for (final post in CoastalDispatchHarborCatalog.coastalDispatches)
      post.shoreDispatchMarker: post.startsShellLiked,
  };
  ShoreSafetySnapshot _snapshot = const ShoreSafetySnapshot(
    blockedHandles: {},
    reportedContentIds: {},
    followingHandles: {},
    approvedFollowerHandles: {},
  );
  bool _showVideos = true;

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

  Future<void> _restoreSafety() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    if (!mounted) {
      return;
    }
    setState(() => _snapshot = snapshot);
  }

  @override
  Widget build(BuildContext context) {
    final persona = widget.persona;
    final isFollowing = _snapshot.isFollowing(persona.tideHandle);
    final profileOriginLine = _profileOriginLine(persona, widget.localApproachRibbon);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFBDF8F3),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                CoastinAssetRegistry.myCoastBackdrop,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 54, 22, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailTopLine(
                          onBack: () => Navigator.of(context).pop(),
                          onMore: _openSafety,
                        ),
                        const SizedBox(height: 48),
                        _ProfileBand(
                          persona: persona,
                          localApproachRibbon: profileOriginLine,
                          isFollowing: isFollowing,
                          onFollowTap: _toggleFollow,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _ImageActionPlate(
                                asset:
                                    CoastinAssetRegistry.detailVideoCallPlate,
                                onTap: _openVideoCall,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _ImageActionPlate(
                                asset: CoastinAssetRegistry.detailChatPlate,
                                onTap: _openChat,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _PublicMedalShelf(),
                        const SizedBox(height: 22),
                        _ProfileSwitch(
                          showVideos: _showVideos,
                          onChanged: (showVideos) {
                            setState(() => _showVideos = showVideos);
                          },
                        ),
                        const SizedBox(height: 12),
                        _PersonaWorkGrid(
                          persona: persona,
                          showVideos: _showVideos,
                          snapshot: _snapshot,
                          lovedDispatches: _lovedDispatches,
                          onPostLoveChanged: (post, isLoved) {
                            setState(
                              () =>
                                  _lovedDispatches[post.shoreDispatchMarker] = isLoved,
                            );
                          },
                          onPostFollowChanged: (_) => _restoreSafety(),
                        ),
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

  Future<void> _toggleFollow() async {
    final handle = widget.persona.tideHandle;
    if (_snapshot.isFollowing(handle)) {
      await _safetyStore.unfollow(handle);
    } else {
      await _safetyStore.follow(handle);
    }
    await _restoreSafety();
  }

  Future<bool> _canStartPrivateAction() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    if (snapshot.isMutualWith(widget.persona.tideHandle)) {
      return true;
    }
    if (!mounted) {
      return false;
    }
    await ShoreSafetyReef.showFollowRequired(
      context: context,
      displayName: widget.persona.displayHarborName,
      onGoFollow: () async {
        await _safetyStore.follow(widget.persona.tideHandle);
        await _restoreSafety();
      },
    );
    return false;
  }

  void _openChat() {
    final thread = ShorePersonaCatalog.threadForPersona(widget.persona);
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => SeaBuddyChatPage(buddyThread: thread),
      ),
    );
  }

  Future<void> _openVideoCall() async {
    if (!await _canStartPrivateAction() || !mounted) {
      return;
    }
    final thread = ShorePersonaCatalog.threadForPersona(widget.persona);
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => SeaBuddyCallPage(buddyThread: thread),
      ),
    );
  }

  Future<void> _openSafety() async {
    final outcome = await ShoreSafetyReef.showGuard(
      context: context,
      contentId: 'profile:${widget.persona.tideHandle}',
      contentKind: ShoreSafetyContentKind.profile,
      ownerName: widget.persona.displayHarborName,
      ownerHandle: widget.persona.tideHandle,
    );
    if (!mounted) {
      return;
    }
    await _restoreSafety();
    if (outcome == null) {
      return;
    }
    if (outcome == ShoreSafetyOutcome.blocked) {
      await _messageStore.clearThread(
        ShorePersonaCatalog.threadForPersona(widget.persona).harborThreadMarker,
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _DetailTopLine extends StatelessWidget {
  const _DetailTopLine({required this.onBack, required this.onMore});

  final VoidCallback onBack;
  final VoidCallback onMore;

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
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onMore,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: Image.asset(
                CoastinAssetRegistry.detailInfoGlyph,
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileBand extends StatelessWidget {
  const _ProfileBand({
    required this.persona,
    required this.localApproachRibbon,
    required this.isFollowing,
    required this.onFollowTap,
  });

  final ShorelinePersona persona;
  final String localApproachRibbon;
  final bool isFollowing;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.76),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              persona.avatarAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      persona.displayHarborName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        shadows: [_profileShadow],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onFollowTap,
                    child: SizedBox(
                      width: 82,
                      height: 34,
                      child: Image.asset(
                        isFollowing
                            ? CoastinAssetRegistry.followedBadge
                            : CoastinAssetRegistry.followBadge,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.location_solid,
                    color: Color(0xFFFF62AC),
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      localApproachRibbon,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF48B9FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        shadows: [_profileShadow],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                persona.coastalStamp,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  shadows: [_profileShadow],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageActionPlate extends StatelessWidget {
  const _ImageActionPlate({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 62,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _PublicMedalShelf extends StatelessWidget {
  const _PublicMedalShelf();

  static const _medals = [
    (CoastinAssetRegistry.medalNewbie, 'Newbie', '1/3 posts'),
    (CoastinAssetRegistry.summerMedal, 'Sun Keeper', '1/5 posts'),
    (CoastinAssetRegistry.medalSurfer, 'Pro Surfer', '1/10 videos'),
    (CoastinAssetRegistry.medalPhotographer, 'Photographer', '1/20 photos'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My medal',
            style: TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var index = 0; index < _medals.length; index++) ...[
                Expanded(
                  child: Column(
                    children: [
                      Image.asset(
                        _medals[index].$1,
                        width: 52,
                        height: 62,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _medals[index].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TidewashPalette.inkBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _medals[index].$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8EA2A0),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != _medals.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSwitch extends StatelessWidget {
  const _ProfileSwitch({required this.showVideos, required this.onChanged});

  final bool showVideos;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(true),
          child: Image.asset(
            showVideos
                ? CoastinAssetRegistry.videosTabActive
                : CoastinAssetRegistry.videosTabResting,
            width: 92,
            height: 34,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 18),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(false),
          child: Image.asset(
            showVideos
                ? CoastinAssetRegistry.postsTabResting
                : CoastinAssetRegistry.postsTabActive,
            width: 92,
            height: 34,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _PersonaWorkGrid extends StatelessWidget {
  const _PersonaWorkGrid({
    required this.persona,
    required this.showVideos,
    required this.snapshot,
    required this.lovedDispatches,
    required this.onPostLoveChanged,
    required this.onPostFollowChanged,
  });

  final ShorelinePersona persona;
  final bool showVideos;
  final ShoreSafetySnapshot snapshot;
  final Map<String, bool> lovedDispatches;
  final void Function(CoastalPostDispatch post, bool isLoved) onPostLoveChanged;
  final ValueChanged<bool> onPostFollowChanged;

  @override
  Widget build(BuildContext context) {
    final videoMoments = ShoreMomentHarborCatalog.shoreVideoMoments
        .where(
          (moment) =>
              moment.shorelineKeeper.tideHandle == persona.tideHandle &&
              snapshot.isVisibleContent(
                'moment:${moment.shoreMomentMarker}',
                persona.tideHandle,
              ),
        )
        .toList();
    final posts = CoastalDispatchHarborCatalog.coastalDispatches
        .where(
          (post) =>
              post.shorelineKeeper.tideHandle == persona.tideHandle &&
              snapshot.isVisibleContent(
                'post:${post.shoreDispatchMarker}',
                persona.tideHandle,
              ),
        )
        .toList();

    final postTiles = posts
        .where((post) => post.shorelineFrameAssets.isNotEmpty)
        .take(6)
        .toList();
    final tileCount = showVideos ? videoMoments.length : postTiles.length;

    if (tileCount == 0) {
      return const Padding(
        padding: EdgeInsets.only(top: 34),
        child: Center(child: CoastinEmptyState(width: 104)),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: tileCount,
      itemBuilder: (context, index) {
        if (!showVideos) {
          final post = postTiles[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (_) => CoastalPostDetailsPage(
                    shoreDispatch: post,
                    isLoved:
                        lovedDispatches[post.shoreDispatchMarker] ??
                        post.startsShellLiked,
                    isFollowed: snapshot.isFollowing(
                      post.shorelineKeeper.tideHandle,
                    ),
                    onLoveChanged: (isLoved) =>
                        onPostLoveChanged(post, isLoved),
                    onFollowChanged: onPostFollowChanged,
                    onReplyCountChanged: (_) {},
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                post.shorelineFrameAssets.first,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          );
        }
        final moment = videoMoments[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (_) => ShareMomentsPage(
                  bottomDockClearance: 0,
                  initialMomentKey: moment.shoreMomentMarker,
                  showBackButton: true,
                  showReleaseButton: false,
                ),
              ),
            );
          },
          child: _MomentFirstFrameTile(moment: moment),
        );
      },
    );
  }
}

class _MomentFirstFrameTile extends StatefulWidget {
  const _MomentFirstFrameTile({required this.moment});

  final ShoreVideoMoment moment;

  @override
  State<_MomentFirstFrameTile> createState() => _MomentFirstFrameTileState();
}

class _MomentFirstFrameTileState extends State<_MomentFirstFrameTile> {
  late VideoPlayerController _videoController;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _prepareVideoController();
  }

  @override
  void didUpdateWidget(covariant _MomentFirstFrameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moment.tideClipAsset == widget.moment.tideClipAsset) {
      return;
    }
    _videoController.dispose();
    _isReady = false;
    _prepareVideoController();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _prepareVideoController() {
    final controller = VideoPlayerController.asset(widget.moment.tideClipAsset);
    _videoController = controller;
    controller
      ..setLooping(false)
      ..setVolume(0);
    controller
        .initialize()
        .then((_) => controller.seekTo(Duration.zero))
        .then((_) {
          if (!mounted || !identical(controller, _videoController)) {
            return;
          }
          controller.pause();
          setState(() => _isReady = true);
        })
        .catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isReady)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
          else
            const ColoredBox(color: Color(0xFF0B1F29)),
          Center(
            child: Image.asset(
              CoastinAssetRegistry.playRoundBadge,
              width: 34,
              height: 34,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

String _profileOriginLine(ShorelinePersona persona, String? localApproachRibbon) {
  return coastinCountryForPersona(persona, localApproachRibbon: localApproachRibbon);
}

const Shadow _profileShadow = Shadow(
  color: Color(0x880A2231),
  blurRadius: 6,
  offset: Offset(0, 1),
);
