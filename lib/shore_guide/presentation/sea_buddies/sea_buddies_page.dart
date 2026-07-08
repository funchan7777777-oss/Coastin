import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../../shared/ui/coastin_empty_state.dart';
import '../../data/local/buddies/sea_buddy_message_store.dart';
import '../../data/local/buddies/shore_system_notice_store.dart';
import '../../data/local/shore_persona_catalog.dart';
import '../../data/local/safety/shore_safety_store.dart';
import '../../domain/entities/buddies/sea_buddy_signal_note.dart';
import '../../domain/entities/buddies/sea_buddy_harbor_thread.dart';
import '../../domain/value_objects/coastin_country_label.dart';
import '../../domain/value_objects/shore_profile_current.dart';
import '../people/shore_persona_detail_page.dart';
import 'chat/sea_buddy_chat_page.dart';
import 'requests/sea_buddy_follow_requests_page.dart';
import 'widgets/sea_buddy_wash.dart';

class SeaBuddiesPage extends StatefulWidget {
  const SeaBuddiesPage({super.key, required this.bottomDockClearance});

  final double bottomDockClearance;

  @override
  State<SeaBuddiesPage> createState() => _SeaBuddiesPageState();
}

class _SeaBuddiesPageState extends State<SeaBuddiesPage> {
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  final SeaBuddyMessageStore _messageStore = const SeaBuddyMessageStore();
  final ShoreSystemNoticeStore _noticeStore = const ShoreSystemNoticeStore();
  final TextEditingController _searchController = TextEditingController();
  String _searchTide = '';
  List<ShoreSystemNotice> _systemNotices = const [];
  Map<String, SeaBuddySignalNote> _latestBuddySignals = const {};
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
    _searchController.dispose();
    super.dispose();
  }

  void _handleSafetyRevision() {
    _restoreSafety();
  }

  List<SeaBuddyHarborThread> get _visibleMutualHarborThreads {
    final query = _searchTide.trim().toLowerCase();
    final buddyThreads = ShorePersonaCatalog.people
        .where((persona) {
          final handle = persona.tideHandle;
          return _snapshot.isMutualWith(handle) &&
              !_snapshot.blockedHandles.contains(handle);
        })
        .map(ShorePersonaCatalog.harborThreadForPersona)
        .toList();
    if (query.isEmpty) {
      return buddyThreads;
    }
    return buddyThreads.where((buddyThread) {
      final savedPreview = _latestBuddySignals[buddyThread.harborThreadMarker]?.signalText ?? '';
      return buddyThread.buddyHarbor.displayHarborName.toLowerCase().contains(
            query,
          ) ||
          buddyThread.localApproachRibbon.toLowerCase().contains(query) ||
          buddyThread.buddyHarbor.coastalStamp.toLowerCase().contains(query) ||
          savedPreview.toLowerCase().contains(query);
    }).toList();
  }

  List<ShoreSystemNotice> get _visibleSystemNotices {
    final query = _searchTide.trim().toLowerCase();
    return _systemNotices.where((notice) {
      if (_snapshot.blockedHandles.contains(notice.actorHandle)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final persona = ShorePersonaCatalog.findByHandle(notice.actorHandle);
      final noticeText =
          '${persona?.displayHarborName ?? ''} ${notice.noticeLine}';
      return noticeText.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleMutualHarborThreads = _visibleMutualHarborThreads;
    final visibleBuddyThreads = visibleMutualHarborThreads;
    final visibleNotices = _visibleSystemNotices;

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
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    60,
                    22,
                    widget.bottomDockClearance + 28,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _SeaBuddyHeader(onAddTap: _openRequests),
                      const SizedBox(height: 26),
                      _SeaSearchField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchTide = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      if (visibleMutualHarborThreads.isNotEmpty) ...[
                        _MutualBuddySection(
                          buddyThreads: visibleMutualHarborThreads,
                          onBuddyTap: _showMutualBuddyActions,
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (visibleNotices.isNotEmpty) ...[
                        _SeaSystemNoticeSection(
                          notices: visibleNotices,
                          onPersonaTap: _openNoticePersona,
                        ),
                        const SizedBox(height: 24),
                      ],
                      for (final buddyThread in visibleBuddyThreads) ...[
                        _SeaBuddyHarborThreadRow(
                          buddyThread: buddyThread,
                          lastNote: _latestBuddySignals[buddyThread.harborThreadMarker],
                          onTap: () => _openChat(buddyThread),
                          onPersonaTap: () => _openPersona(buddyThread),
                        ),
                        const SizedBox(height: 22),
                      ],
                      if (visibleBuddyThreads.isEmpty && visibleNotices.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 86),
                          child: _NoBuddyContent(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(SeaBuddyHarborThread buddyThread) {
    Navigator.of(context)
        .push(
          CupertinoPageRoute<void>(
            builder: (_) => SeaBuddyChatPage(buddyThread: buddyThread),
          ),
        )
        .then((_) => _restoreSafety());
  }

  void _openPersona(SeaBuddyHarborThread buddyThread) {
    Navigator.of(context)
        .push(
          CupertinoPageRoute<void>(
            builder: (_) => ShorePersonaDetailPage(
              persona: buddyThread.buddyHarbor,
              localApproachRibbon: buddyThread.localApproachRibbon,
            ),
          ),
        )
        .then((_) => _restoreSafety());
  }

  void _openNoticePersona(ShoreSystemNotice notice) {
    final persona = ShorePersonaCatalog.findByHandle(notice.actorHandle);
    if (persona == null) {
      return;
    }
    final buddyThread = ShorePersonaCatalog.harborThreadForPersona(persona);
    Navigator.of(context)
        .push(
          CupertinoPageRoute<void>(
            builder: (_) => ShorePersonaDetailPage(
              persona: persona,
              localApproachRibbon: buddyThread.localApproachRibbon,
            ),
          ),
        )
        .then((_) => _restoreSafety());
  }

  void _openRequests() {
    Navigator.of(context)
        .push(
          CupertinoPageRoute<void>(
            builder: (_) => const SeaBuddyFollowRequestsPage(),
          ),
        )
        .then((_) => _restoreSafety());
  }

  void _showMutualBuddyActions(SeaBuddyHarborThread buddyThread) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(buddyThread.buddyHarbor.displayHarborName),
          message: Text(
            'Mutual follow - ${coastinCountryForPersona(buddyThread.buddyHarbor, localApproachRibbon: buddyThread.localApproachRibbon)}',
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _openChat(buddyThread);
              },
              child: const Text('Chat'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop();
                await _safetyStore.unfollow(buddyThread.buddyHarbor.tideHandle);
                await _restoreSafety();
              },
              child: const Text('Unfollow'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Future<void> _restoreSafety() async {
    final snapshot = await _safetyStore.restoreSnapshot();
    final notices = await _noticeStore.restoreNotices();
    final latestSignals = await _messageStore.restoreLatestSignals();
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = snapshot;
      _systemNotices = notices;
      _latestBuddySignals = latestSignals;
    });
  }
}

class _SeaBuddyHeader extends StatelessWidget {
  const _SeaBuddyHeader({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          CoastinAssetRegistry.seaBuddiesWordmark,
          width: 164,
          height: 28,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onAddTap,
          child: SizedBox(
            width: 54,
            height: 40,
            child: Image.asset(
              CoastinAssetRegistry.addBuddyBadge,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}

class _SeaSearchField extends StatelessWidget {
  const _SeaSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      onChanged: onChanged,
      placeholder: 'Search for the specified person ...',
      prefix: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Icon(CupertinoIcons.search, color: Color(0xFFB8C7C6), size: 20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5EFE8)),
      ),
      style: const TextStyle(
        color: TidewashPalette.inkBlue,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MutualBuddySection extends StatelessWidget {
  const _MutualBuddySection({required this.buddyThreads, required this.onBuddyTap});

  final List<SeaBuddyHarborThread> buddyThreads;
  final ValueChanged<SeaBuddyHarborThread> onBuddyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9F4EF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1BAFC4).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF35D5DC), Color(0xFF2D67CE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.person_2_fill,
                  color: Color(0xFFFFFFFF),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Mutual buddies',
                style: TextStyle(
                  color: TidewashPalette.inkBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 106,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: buddyThreads.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final buddyThread = buddyThreads[index];
                return _MutualBuddyChip(
                  buddyThread: buddyThread,
                  onTap: () => onBuddyTap(buddyThread),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MutualBuddyChip extends StatelessWidget {
  const _MutualBuddyChip({required this.buddyThread, required this.onTap});

  final SeaBuddyHarborThread buddyThread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final persona = buddyThread.buddyHarbor;
    final genderGlyph = persona.profileCurrent == ShoreProfileCurrent.feminine
        ? CoastinAssetRegistry.feminineTideGlyph
        : CoastinAssetRegistry.masculineTideGlyph;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 82,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: Image.asset(
                    persona.avatarAsset,
                    width: 54,
                    height: 54,
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
            const SizedBox(height: 8),
            Text(
              persona.displayHarborName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TidewashPalette.inkBlue,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              coastinCountryForPersona(
                buddyThread.buddyHarbor,
                localApproachRibbon: buddyThread.localApproachRibbon,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8FA7A4),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeaSystemNoticeSection extends StatelessWidget {
  const _SeaSystemNoticeSection({
    required this.notices,
    required this.onPersonaTap,
  });

  final List<ShoreSystemNotice> notices;
  final ValueChanged<ShoreSystemNotice> onPersonaTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9F4EF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1BAFC4).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF35D5DC), Color(0xFF2D67CE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.bell_solid,
                  color: Color(0xFFFFFFFF),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Coast signals',
                style: TextStyle(
                  color: TidewashPalette.inkBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final notice in notices) ...[
            _SeaSystemNoticeRow(
              notice: notice,
              onPersonaTap: () => onPersonaTap(notice),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SeaSystemNoticeRow extends StatelessWidget {
  const _SeaSystemNoticeRow({required this.notice, required this.onPersonaTap});

  final ShoreSystemNotice notice;
  final VoidCallback onPersonaTap;

  @override
  Widget build(BuildContext context) {
    final persona = ShorePersonaCatalog.findByHandle(notice.actorHandle);
    if (persona == null) {
      return const SizedBox.shrink();
    }
    final isFollow = notice.noticeChannel == ShoreSystemNoticeChannel.follow;
    final badgeColor = isFollow
        ? const Color(0xFF2F69CF)
        : const Color(0xFF35CED7);
    final badgeIcon = isFollow
        ? CupertinoIcons.person_crop_circle_badge_plus
        : CupertinoIcons.text_bubble_fill;
    final actionLine = isFollow ? 'New follower' : 'New comment';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPersonaTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  persona.avatarAsset,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFFFFF),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    badgeIcon,
                    color: const Color(0xFFFFFFFF),
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPersonaTap,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _noticeAge(notice.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF8FA7A4),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  actionLine,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notice.noticeLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TidewashPalette.harborSlate,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _noticeAge(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) {
      return 'now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }
    return '${createdAt.month}/${createdAt.day}';
  }
}

class _SeaBuddyHarborThreadRow extends StatelessWidget {
  const _SeaBuddyHarborThreadRow({
    required this.buddyThread,
    required this.lastNote,
    required this.onTap,
    required this.onPersonaTap,
  });

  final SeaBuddyHarborThread buddyThread;
  final SeaBuddySignalNote? lastNote;
  final VoidCallback onTap;
  final VoidCallback onPersonaTap;

  @override
  Widget build(BuildContext context) {
    final genderGlyph =
        buddyThread.buddyHarbor.profileCurrent == ShoreProfileCurrent.feminine
        ? CoastinAssetRegistry.feminineTideGlyph
        : CoastinAssetRegistry.masculineTideGlyph;
    final savedPreview = lastNote == null
        ? 'Mutual connection. Start a local chat when you are ready.'
        : lastNote!.sentFromViewerHarbor
        ? 'You: ${lastNote!.signalText}'
        : lastNote!.signalText;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPersonaTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: Image.asset(
                    buddyThread.buddyHarbor.avatarAsset,
                    width: 56,
                    height: 56,
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onPersonaTap,
                        child: Text(
                          buddyThread.buddyHarbor.displayHarborName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: TidewashPalette.inkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      CupertinoIcons.location_solid,
                      size: 14,
                      color: Color(0xFFFF64AB),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        coastinCountryForPersona(
                          buddyThread.buddyHarbor,
                          localApproachRibbon: buddyThread.localApproachRibbon,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFF64AB),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  savedPreview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TidewashPalette.harborSlate,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (lastNote != null)
            const Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: Color(0xFF72CAD0),
              size: 19,
            ),
        ],
      ),
    );
  }
}

class _NoBuddyContent extends StatelessWidget {
  const _NoBuddyContent();

  @override
  Widget build(BuildContext context) {
    return const CoastinEmptyState(width: 72);
  }
}
