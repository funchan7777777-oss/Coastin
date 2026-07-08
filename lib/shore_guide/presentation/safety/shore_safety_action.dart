enum ShoreSafetyOutcome { reported, blocked }

enum ShoreSafetyContentChannel {
  moment('video moment'),
  post('post'),
  comment('comment'),
  profile('profile');

  const ShoreSafetyContentChannel(this.label);

  final String label;
}
