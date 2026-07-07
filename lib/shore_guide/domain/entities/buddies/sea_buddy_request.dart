import '../shoreline_persona.dart';

class SeaBuddyRequest {
  const SeaBuddyRequest({
    required this.requestKey,
    required this.requestPersona,
    required this.placeRibbon,
    required this.requestLine,
    required this.isInitiallyFollowed,
  });

  final String requestKey;
  final ShorelinePersona requestPersona;
  final String placeRibbon;
  final String requestLine;
  final bool isInitiallyFollowed;
}
