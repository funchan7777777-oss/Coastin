import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../../arrival_gate/data/local/harbor_passage_store.dart';
import '../../../arrival_gate/domain/entities/harbor_passage_record.dart';
import '../../data/local/feed/seeded_coastal_feed_deck.dart';
import '../../data/local/seeded_shore_moment_deck.dart';
import 'edit/my_coast_edit_page.dart';
import 'network/my_coast_network_page.dart';
import 'settings/my_coast_settings_page.dart';
import 'wallet/my_coast_wallet_page.dart';

class MyCoastPage extends StatefulWidget {
  const MyCoastPage({super.key, required this.bottomDockClearance});

  final double bottomDockClearance;

  @override
  State<MyCoastPage> createState() => _MyCoastPageState();
}

class _MyCoastPageState extends State<MyCoastPage> {
  final HarborPassageStore _passageStore = const HarborPassageStore();
  HarborPassageRecord? _passageRecord;
  bool _showVideos = true;

  @override
  void initState() {
    super.initState();
    _restoreProfile();
  }

  Future<void> _restoreProfile() async {
    final restored = await _passageStore.restoreSettledPassage();
    if (!mounted) {
      return;
    }
    setState(() => _passageRecord = restored);
  }

  @override
  Widget build(BuildContext context) {
    final record = _passageRecord;
    final displayName = record?.displayName.trim().isNotEmpty == true
        ? record!.displayName
        : 'Emilie';
    final signature = record?.signatureLine.trim().isNotEmpty == true
        ? record!.signatureLine
        : 'This hand brewed coffee is very fragrant and has a faint jasmine aroma~';

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE9FBF6),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                CoastinAssetRegistry.myCoastBackdrop,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      58,
                      22,
                      widget.bottomDockClearance + 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MyCoastHeader(
                          record: record,
                          displayName: displayName,
                          signature: signature,
                          onSettingsTap: _openSettings,
                          onEditTap: _openEdit,
                        ),
                        const SizedBox(height: 18),
                        _ProfileStatsRow(onOpen: _openNetworkPage),
                        const SizedBox(height: 16),
                        _WalletStrip(onTap: _openWallet),
                        const SizedBox(height: 18),
                        const _MedalShelf(),
                        const SizedBox(height: 22),
                        _ProfilePostSwitch(
                          showVideos: _showVideos,
                          onChanged: (showVideos) {
                            setState(() => _showVideos = showVideos);
                          },
                        ),
                        const SizedBox(height: 12),
                        _ProfileGrid(showVideos: _showVideos),
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

  Future<void> _openEdit() async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => MyCoastEditPage(initialRecord: _passageRecord),
      ),
    );
    await _restoreProfile();
  }

  void _openSettings() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => const MyCoastSettingsPage()),
    );
  }

  void _openWallet() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => const MyCoastWalletPage()),
    );
  }

  void _openNetworkPage(MyCoastNetworkKind kind) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => MyCoastNetworkPage(kind: kind)),
    );
  }
}

class _MyCoastHeader extends StatelessWidget {
  const _MyCoastHeader({
    required this.record,
    required this.displayName,
    required this.signature,
    required this.onSettingsTap,
    required this.onEditTap,
  });

  final HarborPassageRecord? record;
  final String displayName;
  final String signature;
  final VoidCallback onSettingsTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              CoastinAssetRegistry.myCoastWordmark,
              width: 132,
              height: 34,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSettingsTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Image.asset(
                  CoastinAssetRegistry.settingsHexBadge,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 44),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileAvatar(record: record),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            shadows: [_profileShadow],
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onEditTap,
                        child: SizedBox(
                          width: 68,
                          height: 30,
                          child: Image.asset(
                            CoastinAssetRegistry.editProfilePill,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        color: Color(0xFFFF62AC),
                        size: 15,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '23 - Australia',
                        style: TextStyle(
                          color: Color(0xFF48B9FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          shadows: [_profileShadow],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    signature,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      shadows: [_profileShadow],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.record});

  final HarborPassageRecord? record;

  @override
  Widget build(BuildContext context) {
    final avatarPath = record?.avatarImagePath ?? '';
    final hasLocalAvatar = avatarPath.isNotEmpty && File(avatarPath).existsSync();

    return Container(
      width: 106,
      height: 106,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.76),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: hasLocalAvatar
            ? Image.file(File(avatarPath), fit: BoxFit.cover)
            : Image.asset(
                CoastinAssetRegistry.milaCoastlinePortrait,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow({required this.onOpen});

  final ValueChanged<MyCoastNetworkKind> onOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProfileStatTile(
          countText: '32',
          label: 'Follow',
          onTap: () => onOpen(MyCoastNetworkKind.follow),
        ),
        _ProfileStatTile(
          countText: '1.2w',
          label: 'Fans',
          onTap: () => onOpen(MyCoastNetworkKind.fans),
        ),
        _ProfileStatTile(
          countText: '18',
          label: 'Friends',
          onTap: () => onOpen(MyCoastNetworkKind.friend),
        ),
        _ProfileStatTile(
          countText: '8.6w',
          label: 'Likes',
          onTap: () => onOpen(MyCoastNetworkKind.fans),
        ),
      ],
    );
  }
}

class _ProfileStatTile extends StatelessWidget {
  const _ProfileStatTile({
    required this.countText,
    required this.label,
    required this.onTap,
  });

  final String countText;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Text(
              countText,
              style: const TextStyle(
                color: TidewashPalette.inkBlue,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: TidewashPalette.harborSlate,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletStrip extends StatelessWidget {
  const _WalletStrip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Image.asset(
        CoastinAssetRegistry.walletInlinePlate,
        width: double.infinity,
        height: 60,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _MedalShelf extends StatelessWidget {
  const _MedalShelf();

  static const _medals = [
    (CoastinAssetRegistry.medalNewbie, 'Newbie', '3/3 posts'),
    (CoastinAssetRegistry.summerMedalLocked, 'Summer Lover', '1/5 posts'),
    (CoastinAssetRegistry.medalSurfer, 'Pro Surfer', '1/10 videos'),
    (CoastinAssetRegistry.cameraMedalLocked, 'Photographer', '1/20 photos'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My medal',
            style: TextStyle(
              color: TidewashPalette.inkBlue,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var index = 0; index < _medals.length; index++) ...[
                Expanded(
                  child: _MedalTile(
                    asset: _medals[index].$1,
                    title: _medals[index].$2,
                    progress: _medals[index].$3,
                  ),
                ),
                if (index != _medals.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MedalTile extends StatelessWidget {
  const _MedalTile({
    required this.asset,
    required this.title,
    required this.progress,
  });

  final String asset;
  final String title;
  final String progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(asset, width: 52, height: 62, fit: BoxFit.contain),
        const SizedBox(height: 5),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: TidewashPalette.inkBlue,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          progress,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF8EA2A0),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Image.asset(
          CoastinAssetRegistry.topicArrowPill,
          width: 34,
          height: 18,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _ProfilePostSwitch extends StatelessWidget {
  const _ProfilePostSwitch({
    required this.showVideos,
    required this.onChanged,
  });

  final bool showVideos;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(true),
          child: Image.asset(
            showVideos
                ? CoastinAssetRegistry.videosTabActive
                : CoastinAssetRegistry.videosTabResting,
            width: 92,
            height: 34,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 18),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(false),
          child: Image.asset(
            showVideos
                ? CoastinAssetRegistry.postsTabResting
                : CoastinAssetRegistry.postsTabActive,
            width: 92,
            height: 34,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _ProfileGrid extends StatelessWidget {
  const _ProfileGrid({required this.showVideos});

  final bool showVideos;

  @override
  Widget build(BuildContext context) {
    final assets = showVideos
        ? const [
            CoastinAssetRegistry.sunwearMood1,
            CoastinAssetRegistry.sunwearMood2,
            CoastinAssetRegistry.sunwearMood3,
            CoastinAssetRegistry.tideplayArc4,
            CoastinAssetRegistry.harborBite2,
            CoastinAssetRegistry.sunwearMood8,
          ]
        : SeededCoastalFeedDeck.coastalDispatches
            .take(6)
            .map((post) => post.frameAssets.first)
            .toList();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                assets[index],
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              if (showVideos)
                Center(
                  child: Image.asset(
                    CoastinAssetRegistry.playRoundBadge,
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

const Shadow _profileShadow = Shadow(
  color: Color(0x880A2231),
  blurRadius: 6,
  offset: Offset(0, 1),
);
