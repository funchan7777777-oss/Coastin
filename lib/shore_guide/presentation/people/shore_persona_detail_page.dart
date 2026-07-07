import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../data/local/buddies/sea_buddy_message_store.dart';
import '../../data/local/feed/seeded_coastal_feed_deck.dart';
import '../../data/local/safety/shore_safety_store.dart';
import '../../data/local/seeded_shore_moment_deck.dart';
import '../../data/local/shore_persona_catalog.dart';
import '../../domain/entities/feed/coastal_post_dispatch.dart';
import '../../domain/entities/shore_video_moment.dart';
import '../../domain/entities/shoreline_persona.dart';
import '../../domain/value_objects/shore_profile_current.dart';
import '../sea_buddies/call/sea_buddy_call_page.dart';
import '../sea_buddies/chat/sea_buddy_chat_page.dart';
import '../safety/shore_safety_action.dart';
import '../safety/shore_safety_reef.dart';

class ShorePersonaDetailPage extends StatefulWidget {
  const ShorePersonaDetailPage({
    super.key,
    required this.persona,
    this.placeRibbon,
  });

  final ShorelinePersona persona;
  final String? placeRibbon;

  @override
  State<ShorePersonaDetailPage> createState() => _ShorePersonaDetailPageState();
}

class _ShorePersonaDetailPageState extends State<ShorePersonaDetailPage> {
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  final SeaBuddyMessageStore _messageStore = const SeaBuddyMessageStore();
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
    final placeRibbon = widget.placeRibbon ??
        (persona.profileCurrent == ShoreProfileCurrent.feminine
            ? '23 - Australia'
            : 'Reef Rail');

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
                          placeRibbon: placeRibbon,
                          isFollowing: isFollowing,
                          onFollowTap: _toggleFollow,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _ImageActionPlate(
                                asset: CoastinAssetRegistry.detailVideoCallPlate,
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

  Future<void> _openChat() async {
    if (!await _canStartPrivateAction() || !mounted) {
      return;
    }
    final thread = ShorePersonaCatalog.threadForPersona(widget.persona);
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => SeaBuddyChatPage(thread: thread)),
    );
  }

  Future<void> _openVideoCall() async {
    if (!await _canStartPrivateAction() || !mounted) {
      return;
    }
    final confirmed = await ShoreSafetyReef.showCallChargeConfirm(
      context: context,
      displayName: widget.persona.displayHarborName,
    );
    if (!confirmed || !mounted) {
      return;
    }
    final thread = ShorePersonaCatalog.threadForPersona(widget.persona);
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => SeaBuddyCallPage(thread: thread)),
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
    if (outcome == ShoreSafetyOutcome.blocked) {
      await _messageStore.clearThread(
        ShorePersonaCatalog.threadForPersona(widget.persona).threadKey,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
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
    required this.placeRibbon,
    required this.isFollowing,
    required this.onFollowTap,
  });

  final ShorelinePersona persona;
  final String placeRibbon;
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
                      placeRibbon,
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
    (CoastinAssetRegistry.summerMedal, 'Summer Lover', '1/5 posts'),
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
  });

  final ShorelinePersona persona;
  final bool showVideos;
  final ShoreSafetySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final videoMoments = SeededShoreMomentDeck.shoreVideoMoments
        .where(
          (moment) =>
              moment.creatorPersona.tideHandle == persona.tideHandle &&
              snapshot.isVisibleContent(
                'moment:${moment.momentKey}',
                persona.tideHandle,
              ),
        )
        .toList();
    final posts = SeededCoastalFeedDeck.coastalDispatches
        .where(
          (post) =>
              post.authorHarbor.tideHandle == persona.tideHandle &&
              snapshot.isVisibleContent(
                'post:${post.dispatchKey}',
                persona.tideHandle,
              ),
        )
        .toList();

    final tiles = showVideos
        ? _tilesForMoments(videoMoments)
        : _tilesForPosts(posts);

    if (tiles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 34),
        child: Center(
          child: Text(
            'No content',
            style: TextStyle(
              color: TidewashPalette.harborSlate.withValues(alpha: 0.38),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
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
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                tiles[index],
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              if (showVideos)
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
      },
    );
  }

  List<String> _tilesForMoments(List<ShoreVideoMoment> moments) {
    if (moments.isNotEmpty) {
      return const [
        CoastinAssetRegistry.sunwearMood1,
        CoastinAssetRegistry.sunwearMood2,
        CoastinAssetRegistry.sunwearMood3,
        CoastinAssetRegistry.tideplayArc4,
        CoastinAssetRegistry.harborBite2,
        CoastinAssetRegistry.sunwearMood8,
      ].take(moments.length.clamp(1, 6)).toList();
    }
    return const [];
  }

  List<String> _tilesForPosts(List<CoastalPostDispatch> posts) {
    return [
      for (final post in posts)
        if (post.frameAssets.isNotEmpty) post.frameAssets.first,
    ].take(6).toList();
  }
}

const Shadow _profileShadow = Shadow(
  color: Color(0x880A2231),
  blurRadius: 6,
  offset: Offset(0, 1),
);
