import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../../arrival_gate/data/local/harbor_passage_store.dart';
import '../../../arrival_gate/domain/entities/harbor_passage_record.dart';
import '../../../shared/ui/coastin_empty_state.dart';
import '../../data/local/safety/shore_safety_store.dart';
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
  final ShoreSafetyStore _safetyStore = const ShoreSafetyStore();
  HarborPassageRecord? _passageRecord;
  ShoreSafetySnapshot _safetySnapshot = const ShoreSafetySnapshot(
    blockedHandles: {},
    reportedContentIds: {},
    followingHandles: {},
    approvedFollowerHandles: {},
  );
  bool _showVideos = true;

  @override
  void initState() {
    super.initState();
    ShoreSafetyStore.safetyRevision.addListener(_handleSafetyRevision);
    _restoreProfile();
  }

  @override
  void dispose() {
    ShoreSafetyStore.safetyRevision.removeListener(_handleSafetyRevision);
    super.dispose();
  }

  void _handleSafetyRevision() {
    _restoreProfile();
  }

  Future<void> _restoreProfile() async {
    final restored = await _passageStore.restoreSettledPassage();
    final safetySnapshot = await _safetyStore.restoreSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _passageRecord = restored;
      _safetySnapshot = safetySnapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    final record = _passageRecord;
    final displayName = record?.displayName.trim().isNotEmpty == true
        ? record!.displayName
        : 'Emilie';
    final signature = record?.signatureLine.trim().isNotEmpty == true
        ? record!.signatureLine.trim()
        : '';
    final countryLine = _profileCountryLine(record);

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
                          countryLine: countryLine,
                          signature: signature,
                          onSettingsTap: _openSettings,
                          onEditTap: _openEdit,
                        ),
                        const SizedBox(height: 18),
                        _ProfileStatsRow(
                          safetySnapshot: _safetySnapshot,
                          onOpen: _openNetworkPage,
                          onLikesTap: _showLikesLedger,
                        ),
                        const SizedBox(height: 16),
                        _WalletStrip(onTap: _openWallet),
                        const SizedBox(height: 18),
                        _MedalShelf(
                          postCount: _ProfileGrid.approvedPostCount,
                          videoCount: _ProfileGrid.approvedVideoCount,
                          photoCount: _ProfileGrid.approvedPhotoCount,
                        ),
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
    Navigator.of(
      context,
    ).push(CupertinoPageRoute<void>(builder: (_) => const MyCoastWalletPage()));
  }

  void _openNetworkPage(MyCoastNetworkHarbor harborLedger) {
    Navigator.of(context)
        .push(
          CupertinoPageRoute<void>(
            builder: (_) => MyCoastNetworkPage(harborLedger: harborLedger),
          ),
        )
        .then((_) => _restoreProfile());
  }

  void _showLikesLedger() {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const _CoastLikesDialog();
      },
    );
  }
}

class _CoastLikesDialog extends StatelessWidget {
  const _CoastLikesDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF7FFFD),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF8DEDE6).withValues(alpha: 0.72),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C6D7C).withValues(alpha: 0.16),
                blurRadius: 26,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF35D5DC), Color(0xFF2D67CE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D67CE).withValues(alpha: 0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    CoastinAssetRegistry.coinShell,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Coast likes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TidewashPalette.inkBlue,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'No public Coastin likes are recorded for this profile yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TidewashPalette.harborSlate,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF35D5DC), Color(0xFF2D67CE)],
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.none,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MyCoastHeader extends StatelessWidget {
  const _MyCoastHeader({
    required this.record,
    required this.displayName,
    required this.countryLine,
    required this.signature,
    required this.onSettingsTap,
    required this.onEditTap,
  });

  final HarborPassageRecord? record;
  final String displayName;
  final String countryLine;
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
                  if (countryLine.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.location_solid,
                          color: Color(0xFFFF62AC),
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            countryLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF48B9FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              shadows: [_profileShadow],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (signature.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      signature,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        shadows: [_profileShadow],
                      ),
                    ),
                  ],
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
    final hasLocalAvatar =
        avatarPath.isNotEmpty && File(avatarPath).existsSync();

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
  const _ProfileStatsRow({
    required this.safetySnapshot,
    required this.onOpen,
    required this.onLikesTap,
  });

  final ShoreSafetySnapshot safetySnapshot;
  final ValueChanged<MyCoastNetworkHarbor> onOpen;
  final VoidCallback onLikesTap;

  @override
  Widget build(BuildContext context) {
    final blockedHandles = safetySnapshot.blockedHandles;
    final followingCount = safetySnapshot.followingHandles
        .where((handle) => !blockedHandles.contains(handle))
        .length;
    final fansCount = safetySnapshot.approvedFollowerHandles
        .where((handle) => !blockedHandles.contains(handle))
        .length;
    final friendCount = safetySnapshot.followingHandles
        .where(
          (handle) =>
              safetySnapshot.approvedFollowerHandles.contains(handle) &&
              !blockedHandles.contains(handle),
        )
        .length;

    return Row(
      children: [
        _ProfileStatTile(
          countText: '$followingCount',
          label: 'Follow',
          onTap: () => onOpen(MyCoastNetworkHarbor.follow),
        ),
        _ProfileStatTile(
          countText: '$fansCount',
          label: 'Fans',
          onTap: () => onOpen(MyCoastNetworkHarbor.fans),
        ),
        _ProfileStatTile(
          countText: '$friendCount',
          label: 'Friends',
          onTap: () => onOpen(MyCoastNetworkHarbor.friend),
        ),
        _ProfileStatTile(countText: '0', label: 'Likes', onTap: onLikesTap),
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
  const _MedalShelf({
    required this.postCount,
    required this.videoCount,
    required this.photoCount,
  });

  final int postCount;
  final int videoCount;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    final medals = [
      _MedalGoal(
        unlockedAsset: CoastinAssetRegistry.medalNewbie,
        lockedAsset: CoastinAssetRegistry.medalPalmLocked,
        ledgerTitle: 'Newbie',
        currentCount: postCount,
        goalCount: 3,
        unitLabel: 'posts',
      ),
      _MedalGoal(
        unlockedAsset: CoastinAssetRegistry.summerMedal,
        lockedAsset: CoastinAssetRegistry.summerMedalLocked,
        ledgerTitle: 'Sun Keeper',
        currentCount: postCount,
        goalCount: 5,
        unitLabel: 'posts',
      ),
      _MedalGoal(
        unlockedAsset: CoastinAssetRegistry.medalSurfer,
        lockedAsset: CoastinAssetRegistry.medalBoardLocked,
        ledgerTitle: 'Pro Surfer',
        currentCount: videoCount,
        goalCount: 10,
        unitLabel: 'videos',
      ),
      _MedalGoal(
        unlockedAsset: CoastinAssetRegistry.medalPhotographer,
        lockedAsset: CoastinAssetRegistry.cameraMedalLocked,
        ledgerTitle: 'Photographer',
        currentCount: photoCount,
        goalCount: 20,
        unitLabel: 'photos',
      ),
    ];

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
              for (var index = 0; index < medals.length; index++) ...[
                Expanded(
                  child: _MedalTile(
                    asset: medals[index].asset,
                    ledgerTitle: medals[index].ledgerTitle,
                    progress: medals[index].progressLine,
                    onRuleTap: () => _showMedalRule(context, medals[index]),
                  ),
                ),
                if (index != medals.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MedalGoal {
  const _MedalGoal({
    required this.unlockedAsset,
    required this.lockedAsset,
    required this.ledgerTitle,
    required this.currentCount,
    required this.goalCount,
    required this.unitLabel,
  });

  final String unlockedAsset;
  final String lockedAsset;
  final String ledgerTitle;
  final int currentCount;
  final int goalCount;
  final String unitLabel;

  String get asset => currentCount >= goalCount ? unlockedAsset : lockedAsset;

  String get ruleLine {
    return switch (unitLabel) {
      'posts' => 'Publish $goalCount shoreline posts to light this badge.',
      'videos' => 'Publish $goalCount shoreline videos to light this badge.',
      'photos' => 'Publish $goalCount shoreline photos to light this badge.',
      _ => 'Complete $goalCount Coastin actions to light this badge.',
    };
  }

  String? get progressLine {
    if (currentCount <= 0) {
      return null;
    }
    final shownCount = currentCount > goalCount ? goalCount : currentCount;
    return '$shownCount/$goalCount $unitLabel';
  }
}

class _MedalTile extends StatelessWidget {
  const _MedalTile({
    required this.asset,
    required this.ledgerTitle,
    required this.progress,
    required this.onRuleTap,
  });

  final String asset;
  final String ledgerTitle;
  final String? progress;
  final VoidCallback onRuleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(asset, width: 52, height: 62, fit: BoxFit.contain),
        const SizedBox(height: 5),
        Text(
          ledgerTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: TidewashPalette.inkBlue,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (progress != null) ...[
          const SizedBox(height: 2),
          Text(
            progress!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8EA2A0),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ] else
          const SizedBox(height: 13),
        const SizedBox(height: 4),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onRuleTap,
          child: SizedBox(
            width: 46,
            height: 26,
            child: Center(
              child: Image.asset(
                CoastinAssetRegistry.coinTrailArrow,
                width: 34,
                height: 18,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showMedalRule(BuildContext context, _MedalGoal medalGoal) {
  return showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) {
      return _MedalRuleDialog(medalGoal: medalGoal);
    },
  );
}

class _MedalRuleDialog extends StatelessWidget {
  const _MedalRuleDialog({required this.medalGoal});

  final _MedalGoal medalGoal;

  @override
  Widget build(BuildContext context) {
    final remainingCount = medalGoal.goalCount - medalGoal.currentCount;
    final progressLine = medalGoal.currentCount >= medalGoal.goalCount
        ? 'This badge is already lit.'
        : remainingCount <= 0
        ? 'This badge is ready to light.'
        : '$remainingCount more ${medalGoal.unitLabel} needed.';

    return CupertinoPopupSurface(
      isSurfacePainted: false,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FFFD),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF91F2EA), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E8C9E).withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                medalGoal.asset,
                width: 70,
                height: 78,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 12),
              Text(
                medalGoal.ledgerTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TidewashPalette.inkBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                medalGoal.ruleLine,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TidewashPalette.harborSlate,
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                progressLine,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF109B96),
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF35D5DC), Color(0xFF2D67CE)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePostSwitch extends StatelessWidget {
  const _ProfilePostSwitch({required this.showVideos, required this.onChanged});

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
  static const List<String> _approvedVideoTiles = [];
  static const List<String> _approvedPostTiles = [];
  static int get approvedVideoCount => _approvedVideoTiles.length;
  static int get approvedPostCount => _approvedPostTiles.length;
  static int get approvedPhotoCount => _approvedPostTiles.length;

  @override
  Widget build(BuildContext context) {
    final assets = _approvedCoastTiles(showVideos);

    if (assets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40, bottom: 20),
        child: Center(child: CoastinEmptyState(width: 104)),
      );
    }

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

  List<String> _approvedCoastTiles(bool showVideos) {
    return showVideos ? _approvedVideoTiles : _approvedPostTiles;
  }
}

String _profileCountryLine(HarborPassageRecord? record) {
  final countryLine = record?.countryLine.trim() ?? '';
  if (countryLine.isEmpty) {
    return '';
  }
  final parts = countryLine.split('-');
  return parts.length > 1 ? parts.last.trim() : countryLine;
}

const Shadow _profileShadow = Shadow(
  color: Color(0x880A2231),
  blurRadius: 6,
  offset: Offset(0, 1),
);
