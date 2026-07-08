class HarborPassageRecord {
  const HarborPassageRecord({
    required this.passageMarker,
    required this.displayName,
    required this.mailCurrent,
    required this.entryChannel,
    required this.settledAtIso,
    this.avatarImagePath = '',
    this.profileWake = '',
    this.signatureLine = '',
    this.countryLine = '',
    this.birthLine = '',
  });

  final String passageMarker;
  final String displayName;
  final String mailCurrent;
  final String entryChannel;
  final String settledAtIso;
  final String avatarImagePath;
  final String profileWake;
  final String signatureLine;
  final String countryLine;
  final String birthLine;

  bool get canRestoreHarbor =>
      passageMarker.isNotEmpty && displayName.isNotEmpty;
}
