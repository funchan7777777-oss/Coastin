import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/buddies/seeded_sea_buddy_deck.dart';
import '../../../data/local/safety/shore_safety_store.dart';
import '../../../data/local/shore_persona_catalog.dart';
import '../../../domain/entities/shoreline_persona.dart';
import '../../people/shore_persona_detail_page.dart';
import '../../sea_buddies/chat/sea_buddy_chat_page.dart';
import '../widgets/coast_person_row.dart';
import '../widgets/my_coast_top_bar.dart';
import '../widgets/my_coast_wash.dart';

enum MyCoastNetworkKind {
  blacklist('Blacklist'),
  follow('Follow'),
  fans('Fans'),
  friend('Friend');

  const MyCoastNetworkKind(this.title);

  final String title;
}

class MyCoastNetworkPage extends StatefulWidget {
  const MyCoastNetworkPage({super.key, required this.kind});

  final MyCoastNetworkKind kind;

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
    _restoreSafety();
  }

  @override
  Widget build(BuildContext context) {
    final visiblePeople = _peopleForKind(widget.kind, _snapshot);

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
                          title: widget.kind.title,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 26),
                        for (final persona in visiblePeople)
                          CoastPersonRow(
                            persona: persona,
                            placeRibbon: _placeForPersona(persona),
                            summaryLine:
                                'Breeze by shore, collect seaside romance today. Long coastline, slow down for coastal tiny joys.',
                            actionAsset: _actionAsset(persona),
                            onActionTap: () => _handleAction(persona),
                            onOpen: () => _openPersona(persona),
                          ),
                        if (visiblePeople.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 170),
                            child: Column(
                              children: [
                                Image.asset(
                                  CoastinAssetRegistry.bluewaterHomeMark,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No content',
                                  style: TextStyle(
                                    color: TidewashPalette.harborSlate
                                        .withValues(alpha: 0.3),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
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
    return switch (widget.kind) {
      MyCoastNetworkKind.blacklist => CoastinAssetRegistry.deletePill,
      MyCoastNetworkKind.follow => CoastinAssetRegistry.followedBadge,
      MyCoastNetworkKind.fans =>
        _snapshot.isFollowing(persona.tideHandle)
            ? CoastinAssetRegistry.followedBadge
            : CoastinAssetRegistry.followBadge,
      MyCoastNetworkKind.friend => CoastinAssetRegistry.chatPill,
    };
  }

  Future<void> _handleAction(ShorelinePersona persona) async {
    if (widget.kind == MyCoastNetworkKind.friend) {
      final thread = SeededSeaBuddyDeck.buddyThreads.firstWhere(
        (thread) => thread.buddyPersona.tideHandle == persona.tideHandle,
        orElse: () => ShorePersonaCatalog.threadForPersona(persona),
      );
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => SeaBuddyChatPage(thread: thread),
        ),
      );
      return;
    }
    if (widget.kind == MyCoastNetworkKind.blacklist) {
      await _safetyStore.unblockHandle(persona.tideHandle);
      await _restoreSafety();
      return;
    }
    if (widget.kind == MyCoastNetworkKind.fans) {
      if (_snapshot.isFollowing(persona.tideHandle)) {
        await _safetyStore.unfollow(persona.tideHandle);
      } else {
        await _safetyStore.follow(persona.tideHandle);
      }
      await _restoreSafety();
      return;
    }
    if (widget.kind == MyCoastNetworkKind.follow) {
      await _safetyStore.unfollow(persona.tideHandle);
      await _restoreSafety();
    }
  }

  void _openPersona(ShorelinePersona persona) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: persona,
          placeRibbon: _placeForPersona(persona),
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
}

List<ShorelinePersona> _peopleForKind(
  MyCoastNetworkKind kind,
  ShoreSafetySnapshot snapshot,
) {
  final people = ShorePersonaCatalog.people;
  bool contains(Set<String> handles, ShorelinePersona persona) {
    return handles.contains(persona.tideHandle);
  }

  return switch (kind) {
    MyCoastNetworkKind.blacklist =>
      people
          .where((persona) => contains(snapshot.blockedHandles, persona))
          .toList(),
    MyCoastNetworkKind.follow =>
      people
          .where((persona) => contains(snapshot.followingHandles, persona))
          .toList(),
    MyCoastNetworkKind.fans =>
      people
          .where(
            (persona) => contains(snapshot.approvedFollowerHandles, persona),
          )
          .toList(),
    MyCoastNetworkKind.friend =>
      people
          .where((persona) => snapshot.isMutualWith(persona.tideHandle))
          .toList(),
  };
}

String _placeForPersona(ShorelinePersona persona) {
  return persona.profileCurrent.isFeminine ? '23 - Australia' : 'Reef Rail';
}
