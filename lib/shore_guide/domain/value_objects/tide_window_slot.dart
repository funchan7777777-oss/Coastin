class TideWindowSlot {
  const TideWindowSlot({
    required this.shorelineCue,
    required this.readableSpan,
    required this.waterlineBehavior,
    required this.confidenceNotches,
    required this.favorsBarefootWalk,
  });

  final String shorelineCue;
  final String readableSpan;
  final String waterlineBehavior;
  final int confidenceNotches;
  final bool favorsBarefootWalk;
}
