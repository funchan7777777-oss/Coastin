enum HarborAccessMode { returningCrew, newShoreline }

extension HarborAccessModeCopy on HarborAccessMode {
  String get credentialTrailLabel {
    return switch (this) {
      HarborAccessMode.returningCrew => 'Log in',
      HarborAccessMode.newShoreline => 'Sign up',
    };
  }
}
