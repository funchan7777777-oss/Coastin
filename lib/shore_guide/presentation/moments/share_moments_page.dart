import 'package:flutter/cupertino.dart';

import '../../data/local/seeded_shore_moment_deck.dart';
import '../../domain/entities/shore_video_moment.dart';
import 'overlays/reef_comment_sheet.dart';
import 'overlays/undertow_guard_sheet.dart';
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

  late final Map<String, bool> _likedMoments;
  late final Map<String, bool> _followedCreators;
  late final Map<String, bool> _pausedMoments;

  int _currentMomentIndex = 0;
  bool _commentsOpen = false;
  bool _guardOpen = false;

  @override
  void initState() {
    super.initState();
    _likedMoments = {
      for (final moment in _moments) moment.momentKey: moment.isInitiallyLiked,
    };
    _followedCreators = {
      for (final moment in _moments)
        moment.creatorPersona.tideHandle: moment.isInitiallyFollowed,
    };
    _pausedMoments = {for (final moment in _moments) moment.momentKey: false};
  }

  @override
  void dispose() {
    _momentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMoment = _moments[_currentMomentIndex];

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF061821),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            PageView.builder(
              controller: _momentController,
              scrollDirection: Axis.vertical,
              physics: _commentsOpen || _guardOpen
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: _moments.length,
              onPageChanged: (index) {
                setState(() {
                  _currentMomentIndex = index;
                  _commentsOpen = false;
                  _guardOpen = false;
                });
              },
              itemBuilder: (context, index) {
                final moment = _moments[index];
                return _ShareMomentPane(
                  shoreMoment: moment,
                  isActive: index == _currentMomentIndex,
                  isLiked: _likedMoments[moment.momentKey] ?? false,
                  isFollowed:
                      _followedCreators[moment.creatorPersona.tideHandle] ??
                      false,
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
                  onInfoTap: () {
                    setState(() {
                      _guardOpen = true;
                      _commentsOpen = false;
                    });
                  },
                  onReleaseTap: _openReleasePage,
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
            ReefCommentSheet(
              isOpen: _commentsOpen,
              commentDrifts: activeMoment.replyDrifts,
              viewerPersona: SeededShoreMomentDeck.shorelinePeople[36],
              onClose: () => setState(() => _commentsOpen = false),
            ),
            UndertowGuardSheet(
              isOpen: _guardOpen,
              onClose: () => setState(() => _guardOpen = false),
              onConfirmed: _confirmGuardChoice,
            ),
          ],
        ),
      ),
    );
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

  void _toggleFollow(ShoreVideoMoment moment) {
    setState(() {
      final handle = moment.creatorPersona.tideHandle;
      _followedCreators[handle] = !(_followedCreators[handle] ?? false);
    });
  }

  void _openReleasePage() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute<void>(builder: (_) => const ShoreReleasePage()));
  }

  void _confirmGuardChoice(UndertowGuardChoice choice) {
    setState(() => _guardOpen = false);
    showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        final isReport = choice == UndertowGuardChoice.report;
        return CupertinoAlertDialog(
          title: Text(isReport ? 'Report received' : 'Profile hidden'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              isReport
                  ? 'Thanks. This shoreline moment has been marked for review.'
                  : 'This creator will stay out of your Coastin feed.',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
        ),
        MomentCaptionPanel(
          shoreMoment: shoreMoment,
          isFollowed: isFollowed,
          bottomDockClearance: bottomDockClearance,
          onFollowTap: onFollowTap,
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
