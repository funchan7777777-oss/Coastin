import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../data/local/buddies/seeded_sea_buddy_deck.dart';
import '../../domain/entities/buddies/sea_buddy_thread.dart';
import '../../domain/value_objects/shore_profile_current.dart';
import 'chat/sea_buddy_chat_page.dart';
import 'requests/sea_buddy_requests_page.dart';
import 'widgets/sea_buddy_wash.dart';

class SeaBuddiesPage extends StatefulWidget {
  const SeaBuddiesPage({super.key, required this.bottomDockClearance});

  final double bottomDockClearance;

  @override
  State<SeaBuddiesPage> createState() => _SeaBuddiesPageState();
}

class _SeaBuddiesPageState extends State<SeaBuddiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTide = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SeaBuddyThread> get _filteredThreads {
    final query = _searchTide.trim().toLowerCase();
    if (query.isEmpty) {
      return SeededSeaBuddyDeck.buddyThreads;
    }
    return SeededSeaBuddyDeck.buddyThreads.where((thread) {
      return thread.buddyPersona.displayHarborName.toLowerCase().contains(
            query,
          ) ||
          thread.placeRibbon.toLowerCase().contains(query) ||
          thread.previewLine.toLowerCase().contains(query);
    }).toList();
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
                      for (final thread in _filteredThreads) ...[
                        _SeaBuddyThreadRow(
                          thread: thread,
                          onTap: () => _openChat(thread),
                        ),
                        const SizedBox(height: 22),
                      ],
                      if (_filteredThreads.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 86),
                          child: _NoBuddyContent(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_filteredThreads.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: widget.bottomDockClearance + 16,
                child: const IgnorePointer(
                  child: _NoBuddyContent(compact: true),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openChat(SeaBuddyThread thread) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => SeaBuddyChatPage(thread: thread),
      ),
    );
  }

  void _openRequests() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => const SeaBuddyRequestsPage()),
    );
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

class _SeaBuddyThreadRow extends StatelessWidget {
  const _SeaBuddyThreadRow({required this.thread, required this.onTap});

  final SeaBuddyThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final genderGlyph =
        thread.buddyPersona.profileCurrent == ShoreProfileCurrent.feminine
        ? CoastinAssetRegistry.feminineTideGlyph
        : CoastinAssetRegistry.masculineTideGlyph;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  thread.buddyPersona.avatarAsset,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        thread.buddyPersona.displayHarborName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: TidewashPalette.inkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
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
                        thread.placeRibbon,
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
                  thread.previewLine,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                thread.lastHarborTime,
                style: const TextStyle(
                  color: Color(0xFF91A6A1),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7D87),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${thread.unreadCount}',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoBuddyContent extends StatelessWidget {
  const _NoBuddyContent({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: compact ? 0.78 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            CoastinAssetRegistry.bluewaterHomeMark,
            width: 58,
            height: 58,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 2),
          Text(
            'No content',
            style: TextStyle(
              color: TidewashPalette.harborSlate.withValues(alpha: 0.24),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
