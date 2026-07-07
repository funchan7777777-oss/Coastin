import '../shore_reply_drift.dart';
import '../shoreline_persona.dart';

class CoastalPostDispatch {
  const CoastalPostDispatch({
    required this.dispatchKey,
    required this.authorHarbor,
    required this.topicKey,
    required this.topicLabel,
    required this.placeRibbon,
    required this.clockRibbon,
    required this.captionCurrent,
    required this.frameAssets,
    required this.heartTally,
    required this.replyTally,
    required this.relayTally,
    required this.isInitiallyLoved,
    required this.isInitiallyFollowed,
    required this.replyDrifts,
  });

  final String dispatchKey;
  final ShorelinePersona authorHarbor;
  final String topicKey;
  final String topicLabel;
  final String placeRibbon;
  final String clockRibbon;
  final String captionCurrent;
  final List<String> frameAssets;
  final int heartTally;
  final int replyTally;
  final int relayTally;
  final bool isInitiallyLoved;
  final bool isInitiallyFollowed;
  final List<ShoreReplyDrift> replyDrifts;
}
