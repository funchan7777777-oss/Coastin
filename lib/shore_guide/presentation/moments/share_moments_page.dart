import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../shared/ui/coastin_empty_state.dart';
import '../../data/local/safety/shore_safety_store.dart';
import '../../data/local/shore_moment_harbor_catalog.dart';
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
  const ShareMomentsPage({
    super.key,
    required this.bottomDockClearance,
    this.initialMomentKey,
    this.showBackButton = false,
    this.showReleaseButton = true,
  });

  final double bottomDockClearance;
  final String? initialMomentKey;
  final bool showBackButton;
  final bool showReleaseButton;

  @override
  State<ShareMomentsPage> createState() => _ShareMomentsPageState();
}

class _ShareMomentsPageState extends State<ShareMomentsPage> {
  late final PageController _momentController;
  final List<ShoreVideoMoment> _moments =
      ShoreMomentHarborCatalog.shoreVideoMoments;
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();

  late final Map<String, bool> _likedMoments;
  late final Map<String, bool> _pausedMoments;
  final Map<String, int> _commentCountOverrides = {};
  ShoreSafetySnapshot _safetySnapshot = const ShoreSafetySnapshot(
    blockedHandles: {},
    reportedContentIds: {},
    followingHandles: {},
    approvedFollowerHandles: {},
  );

  int _currentMomentIndex = 0;
  bool _commentsOpen = false;
  bool _guardOpen = false;
  bool _didSyncInitialMoment = false;

  @override
  void initState() {
    super.initState();
    ShoreSafetyStore.safetyRevision.addListener(_handleSafetyRevision);
    _currentMomentIndex = _initialMomentIndex();
    _momentController = PageController(initialPage: _currentMomentIndex);
    _likedMoments = {for (final moment in _moments) moment.shoreMomentMarker: false};
    _pausedMoments = {for (final moment in _moments) moment.shoreMomentMarker: false};
    _restoreSafety();
  }

  int _initialMomentIndex() {
    final shoreMomentMarker = widget.initialMomentKey;
    if (shoreMomentMarker == null) {
      return 0;
    }
    final index = _moments.indexWhere(
      (moment) => moment.shoreMomentMarker == shoreMomentMarker,
    );
    return index < 0 ? 0 : index;
  }

  @override
  void dispose() {
    ShoreSafetyStore.safetyRevision.removeListener(_handleSafetyRevision);
    _momentController.dispose();
    super.dispose();
  }

  void _handleSafetyRevision() {
    _restoreSafety();
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
              const Center(child: CoastinEmptyState(width: 112))
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
                    key: ValueKey(moment.shoreMomentMarker),
                    shoreMoment: moment,
                    isActive: index == _currentMomentIndex,
                    isLiked: _likedMoments[moment.shoreMomentMarker] ?? false,
                    isFollowed: _safetySnapshot.isFollowing(
                      moment.shorelineKeeper.tideHandle,
                    ),
                    isPaused: _pausedMoments[moment.shoreMomentMarker] ?? false,
                    commentCount:
                        _commentCountOverrides[moment.shoreMomentMarker] ??
                        _visibleCommentCount(moment),
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
                    onBackTap: widget.showBackButton
                        ? () => Navigator.of(context).pop()
                        : null,
                    showReleaseButton: widget.showReleaseButton,
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
                commentDrifts: activeMoment.commentTideMarks,
                viewerPersona: ShoreMomentHarborCatalog.shorelinePeople[36],
                bottomDockClearance: widget.bottomDockClearance,
                onClose: () => setState(() => _commentsOpen = false),
                onChanged: _restoreSafety,
                onVisibleCountChanged: (count) {
                  setState(() {
                    _commentCountOverrides[activeMoment.shoreMomentMarker] = count;
                  });
                },
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
            'moment:${moment.shoreMomentMarker}',
            moment.shorelineKeeper.tideHandle,
          ),
        )
        .toList();
  }

  int _visibleCommentCount(ShoreVideoMoment moment) {
    return moment.commentTideMarks
        .where(
          (comment) => _safetySnapshot.isVisibleContent(
            'comment:${comment.commentMarker}',
            comment.commentHarbor.tideHandle,
          ),
        )
        .length;
  }

  Future<void> _restoreSafety() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    if (!mounted) {
      return;
    }
    var shouldJumpToInitialMoment = false;
    setState(() {
      _safetySnapshot = snapshot;
      if (!_didSyncInitialMoment && widget.initialMomentKey != null) {
        _currentMomentIndex = _initialVisibleMomentIndex(snapshot);
        _didSyncInitialMoment = true;
        shouldJumpToInitialMoment = true;
      }
    });
    if (!shouldJumpToInitialMoment) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_momentController.hasClients ||
          _visibleMoments.isEmpty) {
        return;
      }
      _momentController.jumpToPage(_currentMomentIndex);
    });
  }

  int _initialVisibleMomentIndex(ShoreSafetySnapshot snapshot) {
    final shoreMomentMarker = widget.initialMomentKey;
    if (shoreMomentMarker == null) {
      return 0;
    }
    final visibleMoments = _moments
        .where(
          (moment) => snapshot.isVisibleContent(
            'moment:${moment.shoreMomentMarker}',
            moment.shorelineKeeper.tideHandle,
          ),
        )
        .toList();
    final index = visibleMoments.indexWhere(
      (moment) => moment.shoreMomentMarker == shoreMomentMarker,
    );
    return index < 0 ? _boundedMomentIndex(snapshot) : index;
  }

  Future<void> _restoreSafetyAndSyncMomentPage() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _safetySnapshot = snapshot;
      _currentMomentIndex = _boundedMomentIndex(snapshot);
      _commentsOpen = false;
      _guardOpen = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_momentController.hasClients ||
          _visibleMoments.isEmpty) {
        return;
      }
      _momentController.jumpToPage(_currentMomentIndex);
    });
  }

  int _boundedMomentIndex(ShoreSafetySnapshot snapshot) {
    final visibleCount = _moments
        .where(
          (moment) => snapshot.isVisibleContent(
            'moment:${moment.shoreMomentMarker}',
            moment.shorelineKeeper.tideHandle,
          ),
        )
        .length;
    if (visibleCount == 0) {
      return 0;
    }
    return _currentMomentIndex >= visibleCount
        ? visibleCount - 1
        : _currentMomentIndex;
  }

  void _toggleLike(ShoreVideoMoment moment) {
    setState(() {
      _likedMoments[moment.shoreMomentMarker] =
          !(_likedMoments[moment.shoreMomentMarker] ?? false);
    });
  }

  void _togglePlayback(ShoreVideoMoment moment) {
    setState(() {
      _pausedMoments[moment.shoreMomentMarker] =
          !(_pausedMoments[moment.shoreMomentMarker] ?? false);
    });
  }

  Future<void> _toggleFollow(ShoreVideoMoment moment) async {
    final handle = moment.shorelineKeeper.tideHandle;
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
          persona: moment.shorelineKeeper,
          localApproachRibbon: moment.localApproachRibbon,
        ),
      ),
    );
  }

  Future<void> _openMomentSafety(ShoreVideoMoment moment) async {
    setState(() {
      _commentsOpen = false;
      _guardOpen = true;
    });
    final outcome = await ShoreSafetyReef.showGuard(
      context: context,
      contentId: 'moment:${moment.shoreMomentMarker}',
      contentChannel: ShoreSafetyContentChannel.moment,
      ownerName: moment.shorelineKeeper.displayHarborName,
      ownerHandle: moment.shorelineKeeper.tideHandle,
    );
    if (!mounted) {
      return;
    }
    if (outcome == null) {
      setState(() => _guardOpen = false);
      return;
    }
    await _restoreSafetyAndSyncMomentPage();
  }
}

class _ShareMomentPane extends StatelessWidget {
  const _ShareMomentPane({
    super.key,
    required this.shoreMoment,
    required this.isActive,
    required this.isLiked,
    required this.isFollowed,
    required this.isPaused,
    required this.commentCount,
    required this.bottomDockClearance,
    required this.onLikeTap,
    required this.onPlayTap,
    required this.onFollowTap,
    required this.onCommentTap,
    required this.onInfoTap,
    required this.onReleaseTap,
    required this.onBackTap,
    required this.showReleaseButton,
    required this.onPersonaTap,
  });

  final ShoreVideoMoment shoreMoment;
  final bool isActive;
  final bool isLiked;
  final bool isFollowed;
  final bool isPaused;
  final int commentCount;
  final double bottomDockClearance;
  final VoidCallback onLikeTap;
  final VoidCallback onPlayTap;
  final VoidCallback onFollowTap;
  final VoidCallback onCommentTap;
  final VoidCallback onInfoTap;
  final VoidCallback onReleaseTap;
  final VoidCallback? onBackTap;
  final bool showReleaseButton;
  final VoidCallback onPersonaTap;

  @override
  Widget build(BuildContext context) {
    final adjustedLikeCount = shoreMoment.shellLikeCount + (isLiked ? 1 : 0);

    return Stack(
      fit: StackFit.expand,
      children: [
        ShoreVideoStage(
          tideClipAsset: shoreMoment.tideClipAsset,
          shouldDrift: isActive,
          isPausedByViewer: isPaused,
        ),
        const _VideoReadabilityScrim(),
        _CenterPlaybackToggle(isPaused: isPaused, onTap: onPlayTap),
        ShareMomentHeader(
          onReleaseTap: onReleaseTap,
          onBackTap: onBackTap,
          showReleaseAction: showReleaseButton,
        ),
        MomentActionRail(
          shorelineKeeper: shoreMoment.shorelineKeeper,
          isLiked: isLiked,
          likeCount: adjustedLikeCount,
          commentCount: commentCount,
          bottomDockClearance: bottomDockClearance,
          onLikeTap: onLikeTap,
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

class _CenterPlaybackToggle extends StatefulWidget {
  const _CenterPlaybackToggle({required this.isPaused, required this.onTap});

  final bool isPaused;
  final VoidCallback onTap;

  @override
  State<_CenterPlaybackToggle> createState() => _CenterPlaybackToggleState();
}

class _CenterPlaybackToggleState extends State<_CenterPlaybackToggle> {
  Timer? _hideCueTimer;
  bool _showPlaybackCue = false;

  @override
  void initState() {
    super.initState();
    _showPlaybackCue = widget.isPaused;
  }

  @override
  void didUpdateWidget(covariant _CenterPlaybackToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused == widget.isPaused) {
      return;
    }

    _hideCueTimer?.cancel();
    setState(() => _showPlaybackCue = true);
    if (!widget.isPaused) {
      _hideCueTimer = Timer(const Duration(milliseconds: 560), () {
        if (mounted) {
          setState(() => _showPlaybackCue = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _hideCueTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        button: true,
        label: widget.isPaused ? 'Play video' : 'Pause video',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: SizedBox(
            width: 168,
            height: 168,
            child: Center(
              child: AnimatedOpacity(
                opacity: widget.isPaused || _showPlaybackCue ? 0.94 : 0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Image.asset(
                    widget.isPaused
                        ? CoastinAssetRegistry.playRoundBadge
                        : CoastinAssetRegistry.pauseRoundBadge,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
