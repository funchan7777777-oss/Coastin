import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/harbor_passage_record.dart';

class HarborPassageStore {
  const HarborPassageStore();

  static const String _passageMarkerKey = 'coastin.passage.marker';
  static const String _displayNameKey = 'coastin.passage.displayName';
  static const String _mailCurrentKey = 'coastin.passage.mailCurrent';
  static const String _entryChannelKey = 'coastin.passage.entryChannel';
  static const String _settledAtIsoKey = 'coastin.passage.settledAtIso';
  static const String _avatarImagePathKey = 'coastin.passage.avatarImagePath';
  static const String _profileWakeKey = 'coastin.passage.profileWake';
  static const String _signatureLineKey = 'coastin.passage.signatureLine';

  Future<HarborPassageRecord?> restoreSettledPassage() async {
    final prefs = await SharedPreferences.getInstance();
    final record = HarborPassageRecord(
      passageMarker: prefs.getString(_passageMarkerKey) ?? '',
      displayName: prefs.getString(_displayNameKey) ?? '',
      mailCurrent: prefs.getString(_mailCurrentKey) ?? '',
      entryChannel: prefs.getString(_entryChannelKey) ?? '',
      settledAtIso: prefs.getString(_settledAtIsoKey) ?? '',
      avatarImagePath: prefs.getString(_avatarImagePathKey) ?? '',
      profileWake: prefs.getString(_profileWakeKey) ?? '',
      signatureLine: prefs.getString(_signatureLineKey) ?? '',
    );

    return record.canRestoreHarbor ? record : null;
  }

  Future<void> settlePassage(HarborPassageRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passageMarkerKey, record.passageMarker);
    await prefs.setString(_displayNameKey, record.displayName);
    await prefs.setString(_mailCurrentKey, record.mailCurrent);
    await prefs.setString(_entryChannelKey, record.entryChannel);
    await prefs.setString(_settledAtIsoKey, record.settledAtIso);
    await prefs.setString(_avatarImagePathKey, record.avatarImagePath);
    await prefs.setString(_profileWakeKey, record.profileWake);
    await prefs.setString(_signatureLineKey, record.signatureLine);
  }

  Future<void> clearSettledPassage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passageMarkerKey);
    await prefs.remove(_displayNameKey);
    await prefs.remove(_mailCurrentKey);
    await prefs.remove(_entryChannelKey);
    await prefs.remove(_settledAtIsoKey);
    await prefs.remove(_avatarImagePathKey);
    await prefs.remove(_profileWakeKey);
    await prefs.remove(_signatureLineKey);
  }
}
