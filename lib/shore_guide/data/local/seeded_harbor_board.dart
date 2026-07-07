import '../../domain/entities/cove_pause.dart';
import '../../domain/entities/harbor_readiness_note.dart';
import '../../domain/entities/shoreline_day_plan.dart';
import '../../domain/value_objects/cove_pause_kind.dart';
import '../../domain/value_objects/tide_window_slot.dart';

class SeededHarborBoard {
  const SeededHarborBoard._();

  static const ShorelineDayPlan pacificMorningBoard = ShorelineDayPlan(
    boardTitle: 'Coastin',
    datelineLabel: 'Morning drift board',
    currentStretchName: 'Seabright to Harbor Walk',
    greetingLine: 'A calm route for a bright shoreline day.',
    saltAirSummary: 'Light breeze, open sand, and a steady late-morning tide.',
    weatherTexture: 'Clear with soft coastal haze',
    preferredPace: 'Easy walk, coffee stop, sunset view',
    shorelineEaseScore: 86,
    breezeKnots: 7.4,
    tideSlots: [
      TideWindowSlot(
        shorelineCue: 'Low wash',
        readableSpan: '7:10 - 8:40',
        waterlineBehavior: 'Wide sand shelves near the harbor mouth.',
        confidenceNotches: 4,
        favorsBarefootWalk: true,
      ),
      TideWindowSlot(
        shorelineCue: 'Rising shine',
        readableSpan: '10:20 - 12:15',
        waterlineBehavior: 'Best light for photos by the outer rail.',
        confidenceNotches: 5,
        favorsBarefootWalk: false,
      ),
      TideWindowSlot(
        shorelineCue: 'Evening gloss',
        readableSpan: '17:30 - 19:05',
        waterlineBehavior: 'Gentle reflections along the boardwalk edge.',
        confidenceNotches: 4,
        favorsBarefootWalk: false,
      ),
    ],
    covePauses: [
      CovePause(
        pauseKind: CovePauseKind.boardwalk,
        coveName: 'Twin Palms Rail',
        approachHint: 'Enter from the quiet lane behind the bakery.',
        locallyKnownFor: 'Long shade, good benches, steady surf sound.',
        unhurriedArrival: '9:30',
        strollingMinutes: 28,
        pocketNote: 'Keep this first while the path is still open.',
        keepsSunsetView: false,
      ),
      CovePause(
        pauseKind: CovePauseKind.marketStop,
        coveName: 'Harbor Crate Stand',
        approachHint: 'Use the side gate near the blue loading doors.',
        locallyKnownFor: 'Cold fruit cups and simple picnic wraps.',
        unhurriedArrival: '11:45',
        strollingMinutes: 18,
        pocketNote: 'Pick up water before the warmer stretch.',
        keepsSunsetView: false,
      ),
      CovePause(
        pauseKind: CovePauseKind.overlook,
        coveName: 'Pelican Step View',
        approachHint: 'Climb the short stairs after the last mooring post.',
        locallyKnownFor: 'Open horizon and low wind after late afternoon.',
        unhurriedArrival: '18:10',
        strollingMinutes: 34,
        pocketNote: 'Stay through the first color shift if the sky is clear.',
        keepsSunsetView: true,
      ),
    ],
    readinessNotes: [
      HarborReadinessNote(
        laneMarker: 'Sun',
        readinessLine: 'Pack the mineral stick and a brimmed cap.',
        tuckAwayHint: 'Shade starts late near the outer rail.',
        checkWeight: 3,
      ),
      HarborReadinessNote(
        laneMarker: 'Tide',
        readinessLine: 'Keep the beach walk before the noon rise.',
        tuckAwayHint: 'Dry sand narrows after lunch.',
        checkWeight: 4,
      ),
      HarborReadinessNote(
        laneMarker: 'Snack',
        readinessLine: 'Market stop sits before the longest open stretch.',
        tuckAwayHint: 'Easy to skip if breakfast runs late.',
        checkWeight: 2,
      ),
    ],
  );
}
