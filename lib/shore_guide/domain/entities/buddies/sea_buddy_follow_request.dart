import '../shoreline_persona.dart';

class SeaBuddyFollowRequest {
  const SeaBuddyFollowRequest({
    required this.followRequestMarker,
    required this.requestHarbor,
    required this.localApproachRibbon,
    required this.approachNote,
    required this.startsFollowed,
  });

  final String followRequestMarker;
  final ShorelinePersona requestHarbor;
  final String localApproachRibbon;
  final String approachNote;
  final bool startsFollowed;
}
