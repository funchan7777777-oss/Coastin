import '../value_objects/tide_window_slot.dart';
import 'cove_pause.dart';
import 'harbor_readiness_note.dart';

class ShorelineDayPlan {
  const ShorelineDayPlan({
    required this.boardTitle,
    required this.datelineLabel,
    required this.currentStretchName,
    required this.greetingLine,
    required this.saltAirSummary,
    required this.weatherTexture,
    required this.preferredPace,
    required this.shorelineEaseScore,
    required this.breezeKnots,
    required this.tideSlots,
    required this.covePauses,
    required this.readinessNotes,
  });

  final String boardTitle;
  final String datelineLabel;
  final String currentStretchName;
  final String greetingLine;
  final String saltAirSummary;
  final String weatherTexture;
  final String preferredPace;
  final int shorelineEaseScore;
  final double breezeKnots;
  final List<TideWindowSlot> tideSlots;
  final List<CovePause> covePauses;
  final List<HarborReadinessNote> readinessNotes;
}
