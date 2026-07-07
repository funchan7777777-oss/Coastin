import 'shoreline_persona.dart';

class ShoreReplyDrift {
  const ShoreReplyDrift({
    required this.replyMarker,
    required this.replyAuthor,
    required this.tideMinute,
    required this.replyText,
    required this.hasFreshSignal,
  });

  final String replyMarker;
  final ShorelinePersona replyAuthor;
  final String tideMinute;
  final String replyText;
  final bool hasFreshSignal;
}
