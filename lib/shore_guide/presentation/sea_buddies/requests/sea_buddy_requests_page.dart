import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../data/local/buddies/seeded_sea_buddy_deck.dart';
import '../../../data/local/safety/shore_safety_store.dart';
import '../../../domain/entities/buddies/sea_buddy_request.dart';
import '../../../domain/value_objects/shore_profile_current.dart';
import '../../people/shore_persona_detail_page.dart';
import '../widgets/sea_buddy_top_bar.dart';
import '../widgets/sea_buddy_wash.dart';

class SeaBuddyRequestsPage extends StatefulWidget {
  const SeaBuddyRequestsPage({super.key});

  @override
  State<SeaBuddyRequestsPage> createState() => _SeaBuddyRequestsPageState();
}

class _SeaBuddyRequestsPageState extends State<SeaBuddyRequestsPage> {
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
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFF7DA),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            const Positioned.fill(child: SeaBuddyWash()),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 34),
                    child: Column(
                      children: [
                        SeaBuddyTopBar(
                          title: 'Friend request',
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 24),
                        for (final request in _visibleRequests) ...[
                          _SeaRequestTile(
                            request: request,
                            isAccepted: _snapshot.isFollowedBy(
                              request.requestPersona.tideHandle,
                            ),
                            onAcceptTap: () => _acceptRequest(request),
                            onOpen: () => _openRequestProfile(request),
                          ),
                          const SizedBox(height: 22),
                        ],
                        if (_visibleRequests.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 170),
                            child: Text(
                              'No content',
                              style: TextStyle(
                                color: TidewashPalette.harborSlate.withValues(
                                  alpha: 0.3,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
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

  List<SeaBuddyRequest> get _visibleRequests {
    return SeededSeaBuddyDeck.buddyRequests
        .where(
          (request) => !_snapshot.blockedHandles.contains(
            request.requestPersona.tideHandle,
          ),
        )
        .toList();
  }

  Future<void> _acceptRequest(SeaBuddyRequest request) async {
    await _safetyStore.approveFollower(request.requestPersona.tideHandle);
    await _restoreSafety();
  }

  void _openRequestProfile(SeaBuddyRequest request) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: request.requestPersona,
          placeRibbon: request.placeRibbon,
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

class _SeaRequestTile extends StatelessWidget {
  const _SeaRequestTile({
    required this.request,
    required this.isAccepted,
    required this.onAcceptTap,
    required this.onOpen,
  });

  final SeaBuddyRequest request;
  final bool isAccepted;
  final VoidCallback onAcceptTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final persona = request.requestPersona;
    final genderGlyph = persona.profileCurrent == ShoreProfileCurrent.feminine
        ? CoastinAssetRegistry.feminineTideGlyph
        : CoastinAssetRegistry.masculineTideGlyph;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  persona.avatarAsset,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                right: -3,
                bottom: -2,
                child: Image.asset(genderGlyph, width: 17, height: 17),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        persona.displayHarborName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TidewashPalette.inkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onAcceptTap,
                      child: SizedBox(
                        width: 70,
                        height: 30,
                        child: Image.asset(
                          isAccepted
                              ? CoastinAssetRegistry.followedBadge
                              : CoastinAssetRegistry.followBadge,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ],
                ),
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
                        request.placeRibbon,
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
                const SizedBox(height: 10),
                Text(
                  request.requestLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TidewashPalette.harborSlate,
                    fontSize: 13,
                    height: 1.32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
