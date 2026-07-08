import 'package:flutter/cupertino.dart';

import '../../../../app/assets/coastin_asset_registry.dart';
import '../../../../app/theme/tidewash_palette.dart';
import '../../../../shared/ui/coastin_empty_state.dart';
import '../../../data/local/buddies/sea_buddy_harbor_catalog.dart';
import '../../../data/local/buddies/shore_system_notice_store.dart';
import '../../../data/local/safety/shore_safety_store.dart';
import '../../../domain/entities/buddies/sea_buddy_follow_request.dart';
import '../../../domain/value_objects/coastin_country_label.dart';
import '../../../domain/value_objects/shore_profile_current.dart';
import '../../people/shore_persona_detail_page.dart';
import '../widgets/sea_buddy_top_bar.dart';
import '../widgets/sea_buddy_wash.dart';

class SeaBuddyFollowRequestsPage extends StatefulWidget {
  const SeaBuddyFollowRequestsPage({super.key});

  @override
  State<SeaBuddyFollowRequestsPage> createState() =>
      _SeaBuddyFollowRequestsPageState();
}

class _SeaBuddyFollowRequestsPageState
    extends State<SeaBuddyFollowRequestsPage> {
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  final ShoreSystemNoticeStore _noticeStore = const ShoreSystemNoticeStore();
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
                            isAccepted: _snapshot.isFollowing(
                              request.requestHarbor.tideHandle,
                            ),
                            onAcceptTap: () => _acceptRequest(request),
                            onOpen: () => _openRequestProfile(request),
                          ),
                          const SizedBox(height: 22),
                        ],
                        if (_visibleRequests.isEmpty)
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

  List<SeaBuddyFollowRequest> get _visibleRequests {
    return SeaBuddyHarborCatalog.buddyRequests
        .where(
          (request) => !_snapshot.blockedHandles.contains(
            request.requestHarbor.tideHandle,
          ),
        )
        .where(
          (request) => !_snapshot.isFollowing(request.requestHarbor.tideHandle),
        )
        .toList();
  }

  Future<void> _acceptRequest(SeaBuddyFollowRequest request) async {
    final handle = request.requestHarbor.tideHandle;
    await _noticeStore.recordIncomingFollow(handle);
    await _safetyStore.follow(handle);
    await _restoreSafety();
  }

  void _openRequestProfile(SeaBuddyFollowRequest request) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => ShorePersonaDetailPage(
          persona: request.requestHarbor,
          localApproachRibbon: request.localApproachRibbon,
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

  final SeaBuddyFollowRequest request;
  final bool isAccepted;
  final VoidCallback onAcceptTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final persona = request.requestHarbor;
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
                        coastinCountryForPersona(
                          request.requestHarbor,
                          localApproachRibbon: request.localApproachRibbon,
                        ),
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
                  request.approachNote,
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
