import 'package:flutter/cupertino.dart';

import '../../../app/assets/coastin_asset_registry.dart';
import '../../../app/theme/tidewash_palette.dart';
import '../../data/local/wallet/shore_shell_wallet_store.dart';
import '../coastal_feed/coastal_feed_page.dart';
import '../moments/share_moments_page.dart';
import '../my_coast/my_coast_page.dart';
import '../sea_buddies/sea_buddies_page.dart';
import 'cerulean_tab_berth.dart';
import 'widgets/cerulean_trip_tabbar.dart';

class CeruleanDockShell extends StatefulWidget {
  const CeruleanDockShell({super.key});

  @override
  State<CeruleanDockShell> createState() => _CeruleanDockShellState();
}

class _CeruleanDockShellState extends State<CeruleanDockShell> {
  static const double _dockClearance = CeruleanTripTabbar.boardHeight + 20;
  final ShoreShellWalletStore _walletStore = const ShoreShellWalletStore();

  CeruleanTabBerth _currentBerth = CeruleanTabBerth.beaconMap;

  @override
  void initState() {
    super.initState();
    _prepareWelcomeGift();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
      child: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentBerth.index,
              children: [
                const ShareMomentsPage(bottomDockClearance: _dockClearance),
                const CoastalFeedPage(bottomDockClearance: _dockClearance),
                const SeaBuddiesPage(bottomDockClearance: _dockClearance),
                const MyCoastPage(bottomDockClearance: _dockClearance),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CeruleanTripTabbar(
              currentBerth: _currentBerth,
              onBerthChanged: (berth) {
                if (berth == _currentBerth) {
                  return;
                }
                setState(() => _currentBerth = berth);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _prepareWelcomeGift() async {
    final gift = await _walletStore.ensureWelcomeGift();
    if (!mounted || gift == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showCupertinoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _WelcomeShellTideDialog(shells: gift.shells),
      );
    });
  }
}

class _WelcomeShellTideDialog extends StatelessWidget {
  const _WelcomeShellTideDialog({required this.shells});

  final int shells;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 780),
        curve: Curves.easeOutBack,
        tween: Tween(begin: 0.72, end: 1),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: CupertinoPopupSurface(
          isSurfacePainted: false,
          child: Container(
            width: 326,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FFFC),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0xFFB9F6EF), width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F68D3).withValues(alpha: 0.26),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF35D5DC).withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1100),
                      curve: Curves.easeInOutCubic,
                      tween: Tween(begin: -0.08, end: 0.08),
                      builder: (context, turn, child) {
                        return Transform.rotate(angle: turn, child: child);
                      },
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFFFFF),
                              const Color(0xFFFFF0A8).withValues(alpha: 0.72),
                              const Color(0xFF35D5DC).withValues(alpha: 0.18),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            CoastinAssetRegistry.coinShell,
                            width: 72,
                            height: 72,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Welcome tide bonus',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TidewashPalette.inkBlue,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+$shells shells',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF2F68D3),
                        fontSize: 32,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'A starter cache for publishing Coastin updates and opening seaside guide tools.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TidewashPalette.harborSlate.withValues(
                          alpha: 0.78,
                        ),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 22),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF35D5DC), Color(0xFF2F68D3)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: const Text(
                          'Catch the tide',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
