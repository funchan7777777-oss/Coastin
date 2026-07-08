import '../shore_comment_tide_mark.dart';
import '../shoreline_persona.dart';

class CoastalPostDispatch {
  const CoastalPostDispatch({
    required this.shoreDispatchMarker,
    required this.shorelineKeeper,
    required this.tideTopicMarker,
    required this.tideTopicLabel,
    required this.localApproachRibbon,
    required this.postedAtRibbon,
    required this.shorelineCaption,
    required this.shorelineFrameAssets,
    required this.shellLikeCount,
    required this.commentCount,
    required this.shoreShareCount,
    required this.startsShellLiked,
    required this.startsFollowed,
    required this.commentTideMarks,
  });

  final String shoreDispatchMarker;
  final ShorelinePersona shorelineKeeper;
  final String tideTopicMarker;
  final String tideTopicLabel;
  final String localApproachRibbon;
  final String postedAtRibbon;
  final String shorelineCaption;
  final List<String> shorelineFrameAssets;
  final int shellLikeCount;
  final int commentCount;
  final int shoreShareCount;
  final bool startsShellLiked;
  final bool startsFollowed;
  final List<ShoreCommentTideMark> commentTideMarks;
}
