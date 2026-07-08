enum CovePauseBerth { boardwalk, overlook, swimBreak, marketStop, quietTable }

extension CovePauseBerthCopy on CovePauseBerth {
  String get harborLabel {
    return switch (this) {
      CovePauseBerth.boardwalk => 'Boardwalk',
      CovePauseBerth.overlook => 'Lookout',
      CovePauseBerth.swimBreak => 'Waterline',
      CovePauseBerth.marketStop => 'Market',
      CovePauseBerth.quietTable => 'Table',
    };
  }
}
