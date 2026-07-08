import '../value_objects/cove_pause_berth.dart';

class CovePause {
  const CovePause({
    required this.pauseBerth,
    required this.coveName,
    required this.approachHint,
    required this.locallyKnownFor,
    required this.unhurriedArrival,
    required this.strollingMinutes,
    required this.pocketNote,
    required this.keepsSunsetView,
  });

  final CovePauseBerth pauseBerth;
  final String coveName;
  final String approachHint;
  final String locallyKnownFor;
  final String unhurriedArrival;
  final int strollingMinutes;
  final String pocketNote;
  final bool keepsSunsetView;
}
