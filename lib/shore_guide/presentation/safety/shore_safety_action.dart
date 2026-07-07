enum ShoreSafetyOutcome { reported, blocked }

enum ShoreSafetyContentKind {
  moment('video moment'),
  post('post'),
  comment('comment'),
  profile('profile');

  const ShoreSafetyContentKind(this.label);

  final String label;
}
