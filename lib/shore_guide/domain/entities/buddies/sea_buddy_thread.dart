import '../shoreline_persona.dart';
import 'sea_buddy_note.dart';

class SeaBuddyThread {
  const SeaBuddyThread({
    required this.threadKey,
    required this.buddyPersona,
    required this.placeRibbon,
    required this.lastHarborTime,
    required this.previewLine,
    required this.unreadCount,
    required this.callGreeting,
    required this.notes,
  });

  final String threadKey;
  final ShorelinePersona buddyPersona;
  final String placeRibbon;
  final String lastHarborTime;
  final String previewLine;
  final int unreadCount;
  final String callGreeting;
  final List<SeaBuddyNote> notes;
}
