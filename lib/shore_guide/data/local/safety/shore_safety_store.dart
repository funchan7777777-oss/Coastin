import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ShoreSafetyStore {
  const ShoreSafetyStore();

  static const String _blockedHandlesKey = 'coastin.safety.blockedHandles';
  static const String _reportedContentKey = 'coastin.safety.reportedContent';
  static const String _reportLedgerKey = 'coastin.safety.reportLedger';
  static const String _followingKey = 'coastin.relations.following';
  static const String _approvedFollowersKey =
      'coastin.relations.approvedFollowers';

  Future<ShoreSafetySnapshot> restoreSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return ShoreSafetySnapshot(
      blockedHandles: prefs.getStringList(_blockedHandlesKey)?.toSet() ?? {},
      reportedContentIds:
          prefs.getStringList(_reportedContentKey)?.toSet() ?? {},
      followingHandles: prefs.getStringList(_followingKey)?.toSet() ?? {},
      approvedFollowerHandles:
          prefs.getStringList(_approvedFollowersKey)?.toSet() ?? {},
    );
  }

  Future<bool> isBlocked(String handle) async {
    final snapshot = await restoreSnapshot();
    return snapshot.blockedHandles.contains(handle);
  }

  Future<bool> isMutual(String handle) async {
    final snapshot = await restoreSnapshot();
    return snapshot.isMutualWith(handle);
  }

  Future<void> follow(String handle) async {
    final prefs = await SharedPreferences.getInstance();
    final handles = prefs.getStringList(_followingKey)?.toSet() ?? {};
    handles.add(handle);
    await prefs.setStringList(_followingKey, handles.toList()..sort());
  }

  Future<void> unfollow(String handle) async {
    final prefs = await SharedPreferences.getInstance();
    final handles = prefs.getStringList(_followingKey)?.toSet() ?? {};
    handles.remove(handle);
    await prefs.setStringList(_followingKey, handles.toList()..sort());
  }

  Future<void> approveFollower(String handle) async {
    final prefs = await SharedPreferences.getInstance();
    final handles = prefs.getStringList(_approvedFollowersKey)?.toSet() ?? {};
    handles.add(handle);
    await prefs.setStringList(_approvedFollowersKey, handles.toList()..sort());
  }

  Future<void> removeApprovedFollower(String handle) async {
    final prefs = await SharedPreferences.getInstance();
    final handles = prefs.getStringList(_approvedFollowersKey)?.toSet() ?? {};
    handles.remove(handle);
    await prefs.setStringList(_approvedFollowersKey, handles.toList()..sort());
  }

  Future<void> blockHandle(String handle) async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList(_blockedHandlesKey)?.toSet() ?? {};
    blocked.add(handle);
    await prefs.setStringList(_blockedHandlesKey, blocked.toList()..sort());
  }

  Future<void> unblockHandle(String handle) async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList(_blockedHandlesKey)?.toSet() ?? {};
    blocked.remove(handle);
    await prefs.setStringList(_blockedHandlesKey, blocked.toList()..sort());
  }

  Future<void> reportContent({
    required String contentId,
    required String contentKind,
    required String reason,
    required String? ownerHandle,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenContent =
        prefs.getStringList(_reportedContentKey)?.toSet() ?? {};
    hiddenContent.add(contentId);
    await prefs.setStringList(
      _reportedContentKey,
      hiddenContent.toList()..sort(),
    );

    final ledger = prefs.getStringList(_reportLedgerKey) ?? [];
    ledger.add(
      jsonEncode({
        'contentId': contentId,
        'contentKind': contentKind,
        'reason': reason,
        'ownerHandle': ownerHandle ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      }),
    );
    await prefs.setStringList(_reportLedgerKey, ledger);
  }
}

class ShoreSafetySnapshot {
  const ShoreSafetySnapshot({
    required this.blockedHandles,
    required this.reportedContentIds,
    required this.followingHandles,
    required this.approvedFollowerHandles,
  });

  final Set<String> blockedHandles;
  final Set<String> reportedContentIds;
  final Set<String> followingHandles;
  final Set<String> approvedFollowerHandles;

  bool isVisibleContent(String contentId, String ownerHandle) {
    return !reportedContentIds.contains(contentId) &&
        !blockedHandles.contains(ownerHandle);
  }

  bool isFollowing(String handle) => followingHandles.contains(handle);

  bool isFollowedBy(String handle) => approvedFollowerHandles.contains(handle);

  bool isMutualWith(String handle) {
    return isFollowing(handle) && isFollowedBy(handle);
  }
}
