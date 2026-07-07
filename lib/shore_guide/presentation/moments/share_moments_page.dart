import 'package:flutter/cupertino.dart';

import '../../data/local/safety/shore_safety_store.dart';
import '../../data/local/seeded_shore_moment_deck.dart';
import '../../domain/entities/shore_video_moment.dart';
import 'overlays/reef_comment_sheet.dart';
import '../people/shore_persona_detail_page.dart';
import '../safety/shore_safety_action.dart';
import '../safety/shore_safety_reef.dart';
import 'release/shore_release_page.dart';
import 'widgets/moment_action_rail.dart';
import 'widgets/moment_caption_panel.dart';
import 'widgets/share_moment_header.dart';
import 'widgets/shore_video_stage.dart';

class ShareMomentsPage extends StatefulWidget {
  const ShareMomentsPage({super.key, required this.bottomDockClearance});

  final double bottomDockClearance;

  @override
  State<ShareMomentsPage> createState() => _ShareMomentsPageState();
}

class _ShareMomentsPageState extends State<ShareMomentsPage> {
  final PageController _momentController = PageController();
  final List<ShoreVideoMoment> _moments =
      SeededShoreMomentDeck.shoreVideoMoments;
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();

  late final Map<String, bool> _likedMoments;
  late final Map<String, bool> _pausedMoments;
  ShoreSafetySnapshot _safetySnapshot = const ShoreSafetySnapshot(
    blockedHandles: {},
    reportedContentIds: {},
    followingHandles: {},
    approvedFollowerHandles: {},
  );

  int _currentMomentIndex = 0;
  bool _commentsOpen = false;
  bool _guardOpen = false;

  @override
  void initState() {
    super.initState();
    _likedMoments = {
      for (final moment in _moments) moment.momentKey: moment.isInitiallyLiked,
    };
    _pausedMoments = {for (final moment in _moments) moment.momentKey: false};
    _restoreSafety();
  }

  @override
  void dispose() {
    _momentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleMoments = _visibleMoments;
    if (_currentMomentIndex >= visibleMoments.length &&
        visibleMoments.isNotEmpty) {
      _currentMomentIndex = visibleMoments.length - 1;
    }
    final activeMoment = visibleMoments.isEmpty
        ? null
        : visibleMoments[_currentMomentIndex];

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF061821),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            if (visibleMoments.isEmpty)
              const Center(
                child: Text(
                  'No content',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              PageView.builder(
                controller: _momentController,
                scrollDirection: Axis.vertical,
                physics: _commentsOpen || _guardOpen
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemCount: visibleMoments.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentMomentIndex = index;
                    _commentsOpen = false;
                    _guardOpen = false;
                  });
                },
                itemBuilder: (context, index) {
                  final moment = visibleMoments[index];
                  return _ShareMomentPane(
                    shoreMoment: moment,
                    isActive: index == _currentMomentIndex,
                    isLiked: _likedMoments[moment.momentKey] ?? false,
                    isFollowed: _safetySnapshot.isFollowing(
                      moment.creatorPersona.tideHandle,
                    ),
                    isPaused: _pausedMoments[moment.momentKey] ?? false,
                    bottomDockClearance: widget.bottomDockClearance,
                    onLikeTap: () => _toggleLike(moment),
                    onPlayTap: () => _togglePlayback(moment),
                    onFollowTap: () => _toggleFollow(moment),
                    onCommentTap: () {
                      setState(() {
                        _commentsOpen = true;
                        _guardOpen = false;
                      });
                    },
                    onInfoTap: () => _openMomentSafety(moment),
                    onReleaseTap: _openReleasePage,
                    onPersonaTap: () => _openPersona(moment),
                  );
                },
              ),
            IgnorePointer(
              ignoring: !_commentsOpen,
              child: AnimatedOpacity(
                opacity: _commentsOpen ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _commentsOpen = false),
                  child: Container(color: const Color(0x66000000)),
                ),
              ),
            ),
            if (activeMoment != null)
              ReefCommentSheet(
                isOpen: _commentsOpen,
                commentDrifts: activeMoment.replyDrifts,
                viewerPersona: SeededShoreMomentDeck.shorelinePeople[36],
                onClose: () => setState(() => _commentsOpen = false),
                onChanged: _restoreSafety,
              ),
          ],
        ),
      ),
    );
  }

  List<ShoreVideoMoment> get _visibleMoments {
    return _moments
        .where(
          (moment) => _safetySnapshot.isVisibleContent(
            'moment:${moment.momentKey}',
            moment.creatorPersona.tideHandle,
          ),
        )
        .toList();
  }

  Future<void> _restoreSafety() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    if (!mounted) {
      return;
    }
    setState(() => _safetySnapshot = snapshot);
  }

  void _toggleLike(ShoreVideoMoment moment) {
    setState(() {
      _likedMoments[moment.momentKey] =
          !(_likedMoments[moment.momentKey] ?? false);
    });
  }

  void _togglePlayback(ShoreVideoMoment moment) {
    setState(() {
      _pausedMoments[moment.momentKey] =
          !(_pausedMoments[moment.momentKey] ?? false);
    });
  }

  Future<void> _toggleFollow(ShoreVideoMoment moment) async {
    final handle = moment.creatorPersona.tideHandle;
    if (_safetySnapshot.isFollowing(handle)) {
      await _safetyStore.unfollow(handle);
    } else {
      await _safetyStore.follow(handle);
    }
    await _restoreSafety();
  }

  void _openReleasePage() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute<void>(builder: (_) => const ShoreReleasePage()));
  }

  void _openPersona(ShoreVideoMoment moment) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: moment.creatorPersona,
          placeRibbon: moment.placeRibbon,
        ),
      ),
    );
  }

  Future<void> _openMomentSafety(ShoreVideoMoment moment) async {
    setState(() => _commentsOpen = false);
    await ShoreSafetyReef.showGuard(
      context: context,
      contentId: 'moment:${moment.momentKey}',
      contentKind: ShoreSafetyContentKind.moment,
      ownerName: moment.creatorPersona.displayHarborName,
      ownerHandle: moment.creatorPersona.tideHandle,
    );
    await _restoreSafety();
  }
}

class _ShareMomentPane extends StatelessWidget {
  const _ShareMomentPane({
    required this.shoreMoment,
    required this.isActive,
    required this.isLiked,
    required this.isFollowed,
    required this.isPaused,
    required this.bottomDockClearance,
    required this.onLikeTap,
    required this.onPlayTap,
    required this.onFollowTap,
    required this.onCommentTap,
    required this.onInfoTap,
    required this.onReleaseTap,
    required this.onPersonaTap,
  });

  final ShoreVideoMoment shoreMoment;
  final bool isActive;
  final bool isLiked;
  final bool isFollowed;
  final bool isPaused;
  final double bottomDockClearance;
  final VoidCallback onLikeTap;
  final VoidCallback onPlayTap;
  final VoidCallback onFollowTap;
  final VoidCallback onCommentTap;
  final VoidCallback onInfoTap;
  final VoidCallback onReleaseTap;
  final VoidCallback onPersonaTap;

  @override
  Widget build(BuildContext context) {
    final likeDelta = isLiked == shoreMoment.isInitiallyLiked
        ? 0
        : isLiked
        ? 1
        : -1;
    final adjustedLikeCount = shoreMoment.likeTally + likeDelta;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPlayTap,
          child: ShoreVideoStage(
            videoAsset: shoreMoment.videoAsset,
            shouldDrift: isActive,
            isPausedByViewer: isPaused,
          ),
        ),
        const _VideoReadabilityScrim(),
        ShareMomentHeader(onReleaseTap: onReleaseTap),
        MomentActionRail(
          creatorPersona: shoreMoment.creatorPersona,
          isLiked: isLiked,
          isPaused: isPaused,
          likeCount: adjustedLikeCount,
          replyCount: shoreMoment.replyTally,
          infoCount: shoreMoment.infoTally,
          onLikeTap: onLikeTap,
          onPlayTap: onPlayTap,
          onCommentTap: onCommentTap,
          onInfoTap: onInfoTap,
          onPersonaTap: onPersonaTap,
        ),
        MomentCaptionPanel(
          shoreMoment: shoreMoment,
          isFollowed: isFollowed,
          bottomDockClearance: bottomDockClearance,
          onFollowTap: onFollowTap,
          onPersonaTap: onPersonaTap,
        ),
      ],
    );
  }
}

class _VideoReadabilityScrim extends StatelessWidget {
  const _VideoReadabilityScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x66000000),
            Color(0x11000000),
            Color(0x11000000),
            Color(0x88000000),
          ],
          stops: [0, 0.28, 0.62, 1],
        ),
      ),
    );
  }
}
