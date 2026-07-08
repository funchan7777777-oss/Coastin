import '../shoreline_persona.dart';
import 'sea_buddy_signal_note.dart';

class SeaBuddyHarborThread {
  const SeaBuddyHarborThread({
    required this.harborThreadMarker,
    required this.buddyHarbor,
    required this.localApproachRibbon,
    required this.lastSignalTime,
    required this.lastSignalPreview,
    required this.unreadSignalCount,
    required this.callWarmupLine,
    required this.signalNotes,
  });

  final String harborThreadMarker;
  final ShorelinePersona buddyHarbor;
  final String localApproachRibbon;
  final String lastSignalTime;
  final String lastSignalPreview;
  final int unreadSignalCount;
  final String callWarmupLine;
  final List<SeaBuddySignalNote> signalNotes;
}
