import 'shore_comment_tide_mark.dart';
import 'shoreline_persona.dart';

class ShoreVideoMoment {
  const ShoreVideoMoment({
    required this.shoreMomentMarker,
    required this.shorelineKeeper,
    required this.tideClipAsset,
    required this.localApproachRibbon,
    required this.postedAtRibbon,
    required this.shorelineCaption,
    required this.shellLikeCount,
    required this.commentCount,
    required this.guidePingCount,
    required this.startsFollowed,
    required this.startsShellLiked,
    required this.commentTideMarks,
  });

  final String shoreMomentMarker;
  final ShorelinePersona shorelineKeeper;
  final String tideClipAsset;
  final String localApproachRibbon;
  final String postedAtRibbon;
  final String shorelineCaption;
  final int shellLikeCount;
  final int commentCount;
  final int guidePingCount;
  final bool startsFollowed;
  final bool startsShellLiked;
  final List<ShoreCommentTideMark> commentTideMarks;
}
