class HarborCredentialChecks {
  const HarborCredentialChecks._();

  static String? mailCurrentIssue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Please add your email address before continuing.';
    }
    final hasAtSign = trimmed.contains('@');
    final hasDomain =
        trimmed.split('@').length == 2 && trimmed.split('@').last.contains('.');
    if (!hasAtSign || !hasDomain) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? dockKeyIssue(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your password before continuing.';
    }
    if (value.trim().length < 6) {
      return 'Use at least 6 characters for the password.';
    }
    return null;
  }

  static String readableNameFromMail(String value) {
    final localPart = value.trim().split('@').first;
    if (localPart.isEmpty) {
      return 'Coastin Friend';
    }
    final pieces = localPart
        .split(RegExp(r'[._-]+'))
        .where((piece) => piece.trim().isNotEmpty)
        .map((piece) {
          final lower = piece.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        });
    return pieces.join(' ').trim().isEmpty
        ? 'Coastin Friend'
        : pieces.join(' ');
  }
}
