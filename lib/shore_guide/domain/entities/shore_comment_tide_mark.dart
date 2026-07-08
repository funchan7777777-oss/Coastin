import 'shoreline_persona.dart';

class ShoreCommentTideMark {
  const ShoreCommentTideMark({
    required this.commentMarker,
    required this.commentHarbor,
    required this.commentClock,
    required this.commentText,
    required this.hasFreshSignal,
  });

  final String commentMarker;
  final ShorelinePersona commentHarbor;
  final String commentClock;
  final String commentText;
  final bool hasFreshSignal;
}
