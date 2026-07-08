import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../shore_persona_catalog.dart';
import '../safety/shore_safety_store.dart';

enum ShoreSystemNoticeChannel {
  follow('follow'),
  comment('comment');

  const ShoreSystemNoticeChannel(this.storageKey);

  final String storageKey;

  static ShoreSystemNoticeChannel fromStorage(String value) {
    return ShoreSystemNoticeChannel.values.firstWhere(
      (channel) => channel.storageKey == value,
      orElse: () => ShoreSystemNoticeChannel.follow,
    );
  }
}

class ShoreSystemNotice {
  const ShoreSystemNotice({
    required this.noticeKey,
    required this.noticeChannel,
    required this.actorHandle,
    required this.noticeLine,
    required this.createdAt,
  });

  final String noticeKey;
  final ShoreSystemNoticeChannel noticeChannel;
  final String actorHandle;
  final String noticeLine;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return {
      'noticeKey': noticeKey,
      'noticeChannel': noticeChannel.storageKey,
      'actorHandle': actorHandle,
      'noticeLine': noticeLine,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ShoreSystemNotice? fromEncoded(String encoded) {
    try {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final createdAt =
          DateTime.tryParse(decoded['createdAt'] as String? ?? '') ??
          DateTime.now();
      final storedChannel =
          decoded['noticeChannel'] as String? ?? decoded['kind'] as String? ?? '';
      return ShoreSystemNotice(
        noticeKey: decoded['noticeKey'] as String? ?? '',
        noticeChannel: ShoreSystemNoticeChannel.fromStorage(storedChannel),
        actorHandle: decoded['actorHandle'] as String? ?? '',
        noticeLine: decoded['noticeLine'] as String? ?? '',
        createdAt: createdAt,
      );
    } catch (_) {
      return null;
    }
  }
}

class ShoreSystemNoticeStore {
  const ShoreSystemNoticeStore();

  static const String _noticeLedgerKey = 'coastin.systemNotices.ledger';
  static const String _loginFollowerArrivalFlagKey =
      'coastin.systemNotices.loginFollowerArrivals';

  static const ShoreSafetyStore _safetyStore = ShoreSafetyStore();

  Future<void> ensureLoginFollowerArrivals() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_loginFollowerArrivalFlagKey) ?? false) {
      return;
    }

    final snapshot = await _safetyStore.restoreSnapshot();
    final candidatePeople = ShorePersonaCatalog.people
        .where(
          (persona) =>
              !snapshot.blockedHandles.contains(persona.tideHandle) &&
              !snapshot.approvedFollowerHandles.contains(persona.tideHandle),
        )
        .toList();
    if (candidatePeople.isEmpty) {
      await prefs.setBool(_loginFollowerArrivalFlagKey, true);
      return;
    }

    final random = Random(DateTime.now().microsecondsSinceEpoch);
    candidatePeople.shuffle(random);
    final followerCount = min(candidatePeople.length, 2 + random.nextInt(2));
    final chosenPeople = candidatePeople.take(followerCount).toList();

    for (final persona in chosenPeople) {
      await recordIncomingFollow(persona.tideHandle);
    }

    await prefs.setBool(_loginFollowerArrivalFlagKey, true);
  }

  Future<List<ShoreSystemNotice>> restoreNotices() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedNotices = prefs.getStringList(_noticeLedgerKey) ?? [];
    final notices = [
      for (final encoded in encodedNotices)
        if (ShoreSystemNotice.fromEncoded(encoded) != null)
          ShoreSystemNotice.fromEncoded(encoded)!,
    ];
    notices.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return notices;
  }

  Future<void> recordIncomingFollow(String actorHandle) async {
    final snapshot = await _safetyStore.restoreSnapshot();
    await _safetyStore.approveFollower(actorHandle);
    if (snapshot.approvedFollowerHandles.contains(actorHandle)) {
      return;
    }
    await _appendNotice(
      ShoreSystemNotice(
        noticeKey: _noticeKey('follow', actorHandle),
        noticeChannel: ShoreSystemNoticeChannel.follow,
        actorHandle: actorHandle,
        noticeLine: 'started following your Coastin profile.',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> recordCommentNotice({
    required String actorHandle,
    required String noticeLine,
  }) async {
    await _appendNotice(
      ShoreSystemNotice(
        noticeKey: _noticeKey('comment', actorHandle),
        noticeChannel: ShoreSystemNoticeChannel.comment,
        actorHandle: actorHandle,
        noticeLine: noticeLine,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> clearNoticeLedger() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_noticeLedgerKey);
    await prefs.remove(_loginFollowerArrivalFlagKey);
  }

  Future<void> _appendNotice(ShoreSystemNotice notice) async {
    final prefs = await SharedPreferences.getInstance();
    final notices = prefs.getStringList(_noticeLedgerKey) ?? [];
    notices.add(jsonEncode(notice.toJson()));
    await prefs.setStringList(_noticeLedgerKey, notices);
  }

  String _noticeKey(String prefix, String actorHandle) {
    return '$prefix-$actorHandle-${DateTime.now().microsecondsSinceEpoch}';
  }
}
