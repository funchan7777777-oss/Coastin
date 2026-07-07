import 'shore_reply_drift.dart';
import 'shoreline_persona.dart';

class ShoreVideoMoment {
  const ShoreVideoMoment({
    required this.momentKey,
    required this.creatorPersona,
    required this.videoAsset,
    required this.placeRibbon,
    required this.clockRibbon,
    required this.captionTide,
    required this.likeTally,
    required this.replyTally,
    required this.infoTally,
    required this.isInitiallyFollowed,
    required this.isInitiallyLiked,
    required this.replyDrifts,
  });

  final String momentKey;
  final ShorelinePersona creatorPersona;
  final String videoAsset;
  final String placeRibbon;
  final String clockRibbon;
  final String captionTide;
  final int likeTally;
  final int replyTally;
  final int infoTally;
  final bool isInitiallyFollowed;
  final bool isInitiallyLiked;
  final List<ShoreReplyDrift> replyDrifts;
}
