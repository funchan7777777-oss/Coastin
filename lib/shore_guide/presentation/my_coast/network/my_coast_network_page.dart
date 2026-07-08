import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/coastin_empty_state.dart';
import '../../../data/local/buddies/sea_buddy_harbor_catalog.dart';
import '../../../data/local/safety/shore_safety_store.dart';
import '../../../data/local/shore_persona_catalog.dart';
import '../../../domain/entities/shoreline_persona.dart';
import '../../../domain/value_objects/coastin_country_label.dart';
import '../../people/shore_persona_detail_page.dart';
import '../../sea_buddies/chat/sea_buddy_chat_page.dart';
import '../widgets/coast_person_row.dart';
import '../widgets/my_coast_top_bar.dart';
import '../widgets/my_coast_wash.dart';

enum MyCoastNetworkHarbor {
  blacklist('Blacklist'),
  follow('Follow'),
  fans('Fans'),
  friend('Friend');

  const MyCoastNetworkHarbor(this.ledgerTitle);

  final String ledgerTitle;
}

class MyCoastNetworkPage extends StatefulWidget {
  const MyCoastNetworkPage({super.key, required this.harborLedger});

  final MyCoastNetworkHarbor harborLedger;

  @override
  State<MyCoastNetworkPage> createState() => _MyCoastNetworkPageState();
}

class _MyCoastNetworkPageState extends State<MyCoastNetworkPage> {
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  ShoreSafetySnapshot _snapshot = const ShoreSafetySnapshot(
    blockedHandles: {},
    reportedContentIds: {},
    followingHandles: {},
    approvedFollowerHandles: {},
  );

  @override
  void initState() {
    super.initState();
    ShoreSafetyStore.safetyRevision.addListener(_handleSafetyRevision);
    _restoreSafety();
  }

  @override
  void dispose() {
    ShoreSafetyStore.safetyRevision.removeListener(_handleSafetyRevision);
    super.dispose();
  }

  void _handleSafetyRevision() {
    _restoreSafety();
  }

  @override
  Widget build(BuildContext context) {
    final visiblePeople = _peopleForHarborLedger(
      widget.harborLedger,
      _snapshot,
    );
    final blockedEntries = widget.harborLedger == MyCoastNetworkHarbor.blacklist
        ? _blockedEntries(_snapshot)
        : const <_BlockedHarborEntry>[];
    final hasContent = widget.harborLedger == MyCoastNetworkHarbor.blacklist
        ? blockedEntries.isNotEmpty
        : visiblePeople.isNotEmpty;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFF7DA),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            const Positioned.fill(child: MyCoastWash()),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 34),
                    child: Column(
                      children: [
                        MyCoastTopBar(
                          title: widget.harborLedger.ledgerTitle,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 26),
                        if (widget.harborLedger ==
                            MyCoastNetworkHarbor.blacklist)
                          for (final entry in blockedEntries)
                            _BlockedHarborRow(
                              entry: entry,
                              onUnblock: () => _unblockHandle(entry.handle),
                              onOpen: entry.persona == null
                                  ? null
                                  : () => _openPersona(entry.persona!),
                            )
                        else
                          for (final persona in visiblePeople)
                            CoastPersonRow(
                              persona: persona,
                              localApproachRibbon: _placeForPersona(persona),
                              summaryLine: persona.coastalStamp,
                              actionAsset: _actionAsset(persona),
                              onActionTap: () => _handleAction(persona),
                              onOpen: () => _openPersona(persona),
                            ),
                        if (!hasContent)
                          const Padding(
                            padding: EdgeInsets.only(top: 170),
                            child: CoastinEmptyState(width: 72),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _actionAsset(ShorelinePersona persona) {
    return switch (widget.harborLedger) {
      MyCoastNetworkHarbor.blacklist => CoastinAssetRegistry.deletePill,
      MyCoastNetworkHarbor.follow => CoastinAssetRegistry.followedBadge,
      MyCoastNetworkHarbor.fans =>
        _snapshot.isFollowing(persona.tideHandle)
            ? CoastinAssetRegistry.followedBadge
            : CoastinAssetRegistry.followBadge,
      MyCoastNetworkHarbor.friend => CoastinAssetRegistry.chatPill,
    };
  }

  Future<void> _handleAction(ShorelinePersona persona) async {
    if (widget.harborLedger == MyCoastNetworkHarbor.friend) {
      final buddyThread = SeaBuddyHarborCatalog.buddyThreads.firstWhere(
        (buddyThread) =>
            buddyThread.buddyHarbor.tideHandle == persona.tideHandle,
        orElse: () => ShorePersonaCatalog.harborThreadForPersona(persona),
      );
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => SeaBuddyChatPage(buddyThread: buddyThread),
        ),
      );
      return;
    }
    if (widget.harborLedger == MyCoastNetworkHarbor.blacklist) {
      await _unblockHandle(persona.tideHandle);
      return;
    }
    if (widget.harborLedger == MyCoastNetworkHarbor.fans) {
      if (_snapshot.isFollowing(persona.tideHandle)) {
        await _safetyStore.unfollow(persona.tideHandle);
      } else {
        await _safetyStore.follow(persona.tideHandle);
      }
      await _restoreSafety();
      return;
    }
    if (widget.harborLedger == MyCoastNetworkHarbor.follow) {
      await _safetyStore.unfollow(persona.tideHandle);
      await _restoreSafety();
    }
  }

  void _openPersona(ShorelinePersona persona) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: persona,
          localApproachRibbon: _placeForPersona(persona),
        ),
      ),
    );
  }

  Future<void> _restoreSafety() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    if (!mounted) {
      return;
    }
    setState(() => _snapshot = snapshot);
  }

  Future<void> _unblockHandle(String handle) async {
    await _safetyStore.unblockHandle(handle);
    await _restoreSafety();
  }
}

class _BlockedHarborEntry {
  const _BlockedHarborEntry({required this.handle, required this.persona});

  final String handle;
  final ShorelinePersona? persona;
}

class _BlockedHarborRow extends StatelessWidget {
  const _BlockedHarborRow({
    required this.entry,
    required this.onUnblock,
    required this.onOpen,
  });

  final _BlockedHarborEntry entry;
  final VoidCallback onUnblock;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final persona = entry.persona;
    final displayName = persona?.displayHarborName ?? entry.handle;
    final localApproachRibbon = persona == null
        ? ''
        : _placeForPersona(persona);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (persona == null)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.person_crop_circle_badge_xmark,
                  color: TidewashPalette.harborSlate,
                  size: 28,
                ),
              )
            else
              ClipOval(
                child: Image.asset(
                  persona.avatarAsset,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TidewashPalette.inkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (localApproachRibbon.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.location_solid,
                          color: Color(0xFFFF62AC),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            localApproachRibbon,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFF62AC),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    'Blocked from Coastin interactions on this device.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TidewashPalette.harborSlate,
                      fontSize: 13,
                      height: 1.32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onUnblock,
              child: Container(
                width: 78,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFFF7D82)),
                ),
                child: const Text(
                  'Unblock',
                  style: TextStyle(
                    color: Color(0xFFFF284F),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<ShorelinePersona> _peopleForHarborLedger(
  MyCoastNetworkHarbor harborLedger,
  ShoreSafetySnapshot snapshot,
) {
  final people = ShorePersonaCatalog.people;
  bool contains(Set<String> handles, ShorelinePersona persona) {
    return handles.contains(persona.tideHandle);
  }

  return switch (harborLedger) {
    MyCoastNetworkHarbor.blacklist =>
      people
          .where((persona) => contains(snapshot.blockedHandles, persona))
          .toList(),
    MyCoastNetworkHarbor.follow =>
      people
          .where(
            (persona) =>
                contains(snapshot.followingHandles, persona) &&
                !contains(snapshot.blockedHandles, persona),
          )
          .toList(),
    MyCoastNetworkHarbor.fans =>
      people
          .where(
            (persona) =>
                contains(snapshot.approvedFollowerHandles, persona) &&
                !contains(snapshot.blockedHandles, persona),
          )
          .toList(),
    MyCoastNetworkHarbor.friend =>
      people
          .where(
            (persona) =>
                snapshot.isMutualWith(persona.tideHandle) &&
                !contains(snapshot.blockedHandles, persona),
          )
          .toList(),
  };
}

List<_BlockedHarborEntry> _blockedEntries(ShoreSafetySnapshot snapshot) {
  final sortedHandles = snapshot.blockedHandles.toList()..sort();
  return [
    for (final handle in sortedHandles)
      _BlockedHarborEntry(
        handle: handle,
        persona: ShorePersonaCatalog.findByHandle(handle),
      ),
  ];
}

String _placeForPersona(ShorelinePersona persona) {
  return coastinCountryForPersona(persona);
}
