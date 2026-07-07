enum ProfileWakeChoice { male, female }

extension ProfileWakeChoiceCopy on ProfileWakeChoice {
  String get label {
    return switch (this) {
      ProfileWakeChoice.male => 'Male',
      ProfileWakeChoice.female => 'Female',
    };
  }

  String get storageValue {
    return switch (this) {
      ProfileWakeChoice.male => 'male',
      ProfileWakeChoice.female => 'female',
    };
  }
}
