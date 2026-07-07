import '../value_objects/shore_profile_current.dart';

class ShorelinePersona {
  const ShorelinePersona({
    required this.tideHandle,
    required this.displayHarborName,
    required this.avatarAsset,
    required this.profileCurrent,
    required this.coastalStamp,
  });

  final String tideHandle;
  final String displayHarborName;
  final String avatarAsset;
  final ShoreProfileCurrent profileCurrent;
  final String coastalStamp;
}
