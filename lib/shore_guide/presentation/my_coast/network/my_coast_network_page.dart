import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/buddies/seeded_sea_buddy_deck.dart';
import '../../../data/local/seeded_shore_moment_deck.dart';
import '../../../domain/entities/shoreline_persona.dart';
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
  late final List<ShorelinePersona> _people = _peopleForKind(widget.kind);
  final Set<String> _hiddenHandles = {};
  final Set<String> _followedHandles = {};

  @override
  Widget build(BuildContext context) {
    final visiblePeople = _people
        .where((persona) => !_hiddenHandles.contains(persona.tideHandle))
        .toList();

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
                            onOpen: () => _openPersonaNote(persona),
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
        _followedHandles.contains(persona.tideHandle)
            ? CoastinAssetRegistry.followedBadge
            : CoastinAssetRegistry.followBadge,
      MyCoastNetworkKind.friend => CoastinAssetRegistry.chatPill,
    };
  }

  void _handleAction(ShorelinePersona persona) {
    if (widget.kind == MyCoastNetworkKind.friend) {
      final thread = SeededSeaBuddyDeck.buddyThreads.first;
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => SeaBuddyChatPage(thread: thread),
        ),
      );
      return;
    }
    if (widget.kind == MyCoastNetworkKind.fans) {
      setState(() {
        if (!_followedHandles.add(persona.tideHandle)) {
          _followedHandles.remove(persona.tideHandle);
        }
      });
      return;
    }
    setState(() => _hiddenHandles.add(persona.tideHandle));
  }

  void _openPersonaNote(ShorelinePersona persona) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(persona.displayHarborName),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(persona.coastalStamp),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

List<ShorelinePersona> _peopleForKind(MyCoastNetworkKind kind) {
  final people = SeededShoreMomentDeck.shorelinePeople;
  return switch (kind) {
    MyCoastNetworkKind.blacklist => [people[24], people[12]],
    MyCoastNetworkKind.follow => [people[24]],
    MyCoastNetworkKind.fans => [people[24], people[6]],
    MyCoastNetworkKind.friend => [people[24]],
  };
}

String _placeForPersona(ShorelinePersona persona) {
  return persona.profileCurrent.isFeminine ? '23 - Australia' : 'Reef Rail';
}
