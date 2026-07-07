enum ShorelineBoardFocus { dayflow, waterline, pauses }

extension ShorelineBoardFocusWords on ShorelineBoardFocus {
  String get switcherLabel {
    return switch (this) {
      ShorelineBoardFocus.dayflow => 'Dayflow',
      ShorelineBoardFocus.waterline => 'Tide',
      ShorelineBoardFocus.pauses => 'Pauses',
    };
  }
}
