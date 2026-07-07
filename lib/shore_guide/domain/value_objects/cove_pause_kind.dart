enum CovePauseKind { boardwalk, overlook, swimBreak, marketStop, quietTable }

extension CovePauseKindWords on CovePauseKind {
  String get harborLabel {
    return switch (this) {
      CovePauseKind.boardwalk => 'Boardwalk',
      CovePauseKind.overlook => 'Lookout',
      CovePauseKind.swimBreak => 'Waterline',
      CovePauseKind.marketStop => 'Market',
      CovePauseKind.quietTable => 'Table',
    };
  }
}
