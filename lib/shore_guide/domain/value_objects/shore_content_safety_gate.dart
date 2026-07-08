enum ShoreContentSurface {
  profileName,
  profileNote,
  publicCaption,
  publicComment,
  privateMessage,
}

class ShoreContentSafetyGate {
  const ShoreContentSafetyGate._();

  static ShoreContentSafetyDecision inspect(
    String rawText, {
    required ShoreContentSurface surface,
  }) {
    final text = rawText.trim();
    if (text.isEmpty) {
      return const ShoreContentSafetyDecision.allowed();
    }

    final maxLength = surface.maxLength;
    if (text.length > maxLength) {
      return ShoreContentSafetyDecision.blocked(
        title: surface.reviewTitle,
        message:
            'Please keep this ${surface.copyLabel} within $maxLength characters so it stays readable inside Coastin.',
      );
    }

    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final hasPrivateContact =
        _emailPattern.hasMatch(normalized) ||
        _phonePattern.hasMatch(normalized) ||
        _offPlatformPattern.hasMatch(normalized);
    if (hasPrivateContact) {
      return ShoreContentSafetyDecision.blocked(
        title: surface.reviewTitle,
        message:
            'Please keep conversations inside Coastin and remove private contact details or outside-app handles before continuing.',
      );
    }

    for (final rule in _unsafeTextRules) {
      if (rule.pattern.hasMatch(normalized)) {
        return ShoreContentSafetyDecision.blocked(
          title: surface.reviewTitle,
          message: surface.blockMessage,
        );
      }
    }

    return const ShoreContentSafetyDecision.allowed();
  }

  static final RegExp _emailPattern = RegExp(
    r'\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}\b',
  );
  static final RegExp _phonePattern = RegExp(r'(?:\+?\d[\s.-]?){7,}');
  static final RegExp _offPlatformPattern = RegExp(
    r'\b(?:whatsapp|telegram|snapchat|kik|onlyfans|wechat|line id)\b',
  );

  static final List<_ShoreUnsafeTextRule> _unsafeTextRules = [
    _ShoreUnsafeTextRule(RegExp(r'\b(?:nude|naked|porn|nsfw)\b')),
    _ShoreUnsafeTextRule(
      RegExp(r'\b(?:escort|hookup|sugar daddy|sugar baby)\b'),
    ),
    _ShoreUnsafeTextRule(RegExp(r'\b(?:kill|bomb|weapon|rape|self harm)\b')),
    _ShoreUnsafeTextRule(RegExp(r'\b(?:doxx|stalk|harass)\b')),
    _ShoreUnsafeTextRule(RegExp(r'\b(?:cocaine|meth|fentanyl)\b')),
  ];
}

class ShoreContentSafetyDecision {
  const ShoreContentSafetyDecision.allowed()
    : isAllowed = true,
      title = '',
      message = '';

  const ShoreContentSafetyDecision.blocked({
    required this.title,
    required this.message,
  }) : isAllowed = false;

  final bool isAllowed;
  final String title;
  final String message;
}

class _ShoreUnsafeTextRule {
  const _ShoreUnsafeTextRule(this.pattern);

  final RegExp pattern;
}

extension _ShoreContentSurfaceCopy on ShoreContentSurface {
  int get maxLength {
    return switch (this) {
      ShoreContentSurface.profileName => 28,
      ShoreContentSurface.profileNote => 120,
      ShoreContentSurface.publicCaption => 180,
      ShoreContentSurface.publicComment => 160,
      ShoreContentSurface.privateMessage => 220,
    };
  }

  String get copyLabel {
    return switch (this) {
      ShoreContentSurface.profileName => 'nickname',
      ShoreContentSurface.profileNote => 'profile note',
      ShoreContentSurface.publicCaption => 'shoreline caption',
      ShoreContentSurface.publicComment => 'comment',
      ShoreContentSurface.privateMessage => 'message',
    };
  }

  String get reviewTitle {
    return switch (this) {
      ShoreContentSurface.profileName => 'Nickname needs review',
      ShoreContentSurface.profileNote => 'Profile note needs review',
      ShoreContentSurface.publicCaption => 'Caption needs review',
      ShoreContentSurface.publicComment => 'Comment needs review',
      ShoreContentSurface.privateMessage => 'Message needs review',
    };
  }

  String get blockMessage {
    return switch (this) {
      ShoreContentSurface.profileName =>
        'Please use a respectful Coastin nickname that feels appropriate for shoreline conversations.',
      ShoreContentSurface.profileNote =>
        'Please keep your profile note respectful, lawful, and focused on coastal interests.',
      ShoreContentSurface.publicCaption =>
        'Please keep Coastin posts lawful, respectful, and focused on shoreline moments. Remove unsafe, abusive, or off-topic wording before sharing.',
      ShoreContentSurface.publicComment =>
        'Please keep comments respectful and useful for the shoreline discussion. Remove unsafe, abusive, or off-topic wording before sending.',
      ShoreContentSurface.privateMessage =>
        'Please keep Coastin messages respectful and safe. Remove unsafe, abusive, or off-topic wording before sending.',
    };
  }
}
